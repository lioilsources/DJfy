import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart' as soloud;
import 'package:just_audio/just_audio.dart';

import '../models/deck_config.dart';
import '../models/fx.dart';

/// Per-deck DSP state — only present when a progressive URL was loaded into
/// SoLoud (i.e. [DeckConfig.hasDsp] == true).
class _DspDeck {
  final soloud.AudioSource source;
  soloud.SoundHandle handle;

  _DspDeck({required this.source, required this.handle});
}

/// Pure x/y → filter-parameter math for the FX pad, extracted so it can be
/// unit-tested without an audio engine.
class FxParamMapper {
  FxParamMapper._();

  /// Hi-Lo dead zone: |x - 0.5| <= 0.05 → filter bypassed.
  static const hiLoDeadZone = 0.05;

  /// Low-pass cutoff for the left half of the pad (x in [0, 0.45)).
  /// Sweeps exponentially 16 kHz → 60 Hz as x moves from center to left edge.
  static double hiLoLpFrequency(double x) =>
      16000 * math.pow(60 / 16000, (0.45 - x) / 0.45).toDouble();

  /// High-pass cutoff for the right half (x in (0.55, 1]).
  /// Sweeps exponentially 20 Hz → 8 kHz as x moves from center to right edge.
  static double hiLoHpFrequency(double x) =>
      20 * math.pow(8000 / 20, (x - 0.55) / 0.45).toDouble();

  static double hiLoResonance(double y) => 1 + y * 7;

  /// Echo delay bucket in beats: {1/4, 1/2, 3/4, 1}.
  static double echoBeats(double x) => switch ((x * 4).floor().clamp(0, 3)) {
        0 => 0.25,
        1 => 0.5,
        2 => 0.75,
        _ => 1.0,
      };

  static double echoWet(double y) => y * 0.8;
  static double echoDecay(double y) => 0.3 + y * 0.6;

  /// 8-bit samplerate crush, exponential 22 kHz → 800 Hz.
  static double eightBitSamplerate(double x) =>
      22000 * math.pow(800 / 22000, x).toDouble();

  /// Roll slice length in beats: {1/2, 1/4, 1/8, 1/16}.
  static double rollBeats(double x) => switch ((x * 4).floor().clamp(0, 3)) {
        0 => 0.5,
        1 => 0.25,
        2 => 0.125,
        _ => 0.0625,
      };

  /// Beatskip bucket: {-4, -2, -1, +1, +2, +4} beats.
  static int beatskipBeats(double x) => switch ((x * 6).floor().clamp(0, 5)) {
        0 => -4,
        1 => -2,
        2 => -1,
        3 => 1,
        4 => 2,
        _ => 4,
      };
}

/// Unified audio engine managing per-deck playback.
///
/// * **Progressive MP3 URL** → played via `flutter_soloud` for real-time DSP
///   (3-band EQ kills + Pacemaker-style FX). Position/duration are polled via
///   a periodic [Timer].
/// * **HLS URL** (or any `.m3u8` / `hls` URL) → played via `just_audio` as
///   before, but without DSP. EQ/FX controls are disabled in that case.
class AudioEngine {
  static final instance = AudioEngine._();
  AudioEngine._();

  // ── just_audio players (HLS streaming + fallback) ──────────────────────────
  final Map<int, AudioPlayer> _players = {};

  AudioPlayer playerFor(int deckId) =>
      _players.putIfAbsent(deckId, AudioPlayer.new);

  // ── flutter_soloud DSP decks (progressive MP3) ──────────────────────────────
  final Map<int, _DspDeck> _dsp = {};
  final Map<int, Timer> _timers = {};
  final Map<int, StreamController<Duration>> _posCtrl = {};
  final Map<int, StreamController<Duration?>> _durCtrl = {};
  final Map<int, StreamController<PlayerState>> _stateCtrl = {};

  // ── Volume: user slider × crossfader gain, applied on both paths ───────────
  final Map<int, double> _baseVolume = {};
  final Map<int, double> _xfGain = {};

  // ── Init ────────────────────────────────────────────────────────────────────
  static Future<void> initSoLoud() async {
    await soloud.SoLoud.instance.init();
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  /// Loads a track onto a deck.
  ///
  /// If [progressiveUrl] is provided and non-null, the deck is run through
  /// SoLoud with EQ + FX filters. Otherwise, it falls back to just_audio HLS.
  ///
  /// Returns true if DSP (SoLoud) was activated, false for HLS fallback.
  Future<bool> loadTrack(
    int deckId,
    String hlsUrl, {
    String? progressiveUrl,
  }) async {
    // Tear down any existing SoLoud state for this deck
    _disposeDsp(deckId);

    if (progressiveUrl != null && progressiveUrl.isNotEmpty) {
      return _loadViaSoLoud(deckId, progressiveUrl);
    } else {
      await _loadViaJustAudio(deckId, hlsUrl);
      return false;
    }
  }

  Future<void> _loadViaJustAudio(int deckId, String url) async {
    final player = playerFor(deckId);
    await player.stop();
    // Detect HLS vs progressive: just_audio handles both, but use the right
    // source type so it doesn't try to parse an MP3 as an HLS playlist.
    final isHls = url.contains('.m3u8') || url.contains('hls');
    if (isHls) {
      await player.setAudioSource(HlsAudioSource(Uri.parse(url)));
    } else {
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    }
    await player.setVolume(_effectiveVolume(deckId));
  }

  Future<bool> _loadViaSoLoud(int deckId, String url) async {
    try {
      final source = await soloud.SoLoud.instance.loadUrl(url);

      // Filters must be activated BEFORE play(): filter instances are cloned
      // onto the voice at play time; a later activate() never reaches it.
      final f = source.filters;
      f.equalizerFilter.activate();
      f.biquadFilter.activate();
      f.echoFilter.activate();
      f.freeverbFilter.activate();
      f.lofiFilter.activate();

      final handle = await soloud.SoLoud.instance.play(
        source,
        paused: true,
        volume: _effectiveVolume(deckId),
      );

      // Neutralize per-voice params before the first unpause. Every call needs
      // `soundHandle:` — without it the value goes to the (inactive) global
      // filter chain and is silently dropped.
      f.biquadFilter.wet(soundHandle: handle).value = 0;
      f.biquadFilter.frequency(soundHandle: handle).value = 16000;
      // Echo buffer size is fixed from `delay` at the first audio-process
      // callback and can never grow afterwards — reserve 1 s of headroom now.
      f.echoFilter.wet(soundHandle: handle).value = 0;
      f.echoFilter.delay(soundHandle: handle).value = 1.0;
      f.echoFilter.decay(soundHandle: handle).value = 0.5;
      f.freeverbFilter.wet(soundHandle: handle).value = 0; // default is 1!
      f.lofiFilter.wet(soundHandle: handle).value = 0; // default is 1!

      _dsp[deckId] = _DspDeck(source: source, handle: handle);
      _startPositionPolling(deckId, source);
      debugPrint('[AudioEngine] deck $deckId → SoLoud DSP (progressive)');
      return true;
    } catch (e) {
      debugPrint('[AudioEngine] SoLoud load failed ($e), no DSP for deck $deckId');
      return false;
    }
  }

  // ── Playback ─────────────────────────────────────────────────────────────

  Future<void> play(int deckId) async {
    final dsp = _dsp[deckId];
    if (dsp != null) {
      soloud.SoLoud.instance.setPause(dsp.handle, false);
      _emitState(deckId, playing: true);
    } else {
      await playerFor(deckId).play();
    }
  }

  Future<void> pause(int deckId) async {
    final dsp = _dsp[deckId];
    if (dsp != null) {
      soloud.SoLoud.instance.setPause(dsp.handle, true);
      _emitState(deckId, playing: false);
    } else {
      await playerFor(deckId).pause();
    }
  }

  Future<void> seekTo(int deckId, Duration position) async {
    final dsp = _dsp[deckId];
    if (dsp != null) {
      soloud.SoLoud.instance.seek(dsp.handle, position);
    } else {
      await playerFor(deckId).seek(position);
    }
  }

  Future<void> setSpeed(int deckId, double speed) async {
    final dsp = _dsp[deckId];
    if (dsp != null) {
      soloud.SoLoud.instance.setRelativePlaySpeed(dsp.handle, speed);
    } else {
      await playerFor(deckId).setSpeed(speed);
    }
  }

  Future<void> setVolume(int deckId, double volume) async {
    _baseVolume[deckId] = volume;
    await _applyVolume(deckId);
  }

  /// Crossfader gain (0–1), multiplied with the user volume slider.
  /// Works on both the SoLoud and just_audio paths.
  Future<void> setCrossfadeGain(int deckId, double gain) async {
    _xfGain[deckId] = gain;
    await _applyVolume(deckId);
  }

  double _effectiveVolume(int deckId) =>
      (_baseVolume[deckId] ?? 0.8) * (_xfGain[deckId] ?? 1.0);

  Future<void> _applyVolume(int deckId) async {
    final volume = _effectiveVolume(deckId);
    final dsp = _dsp[deckId];
    if (dsp != null) {
      soloud.SoLoud.instance.setVolume(dsp.handle, volume);
    } else {
      await playerFor(deckId).setVolume(volume);
    }
  }

  // ── EQ kills (LOW / MID / HIGH) ────────────────────────────────────────────

  /// SoLoud's EqFilter bands are sqrt-warped FFT bands — band k covers
  /// (k/8)²…((k+1)/8)² of Nyquist. At 44.1 kHz:
  ///   low  = band1     (0–344 Hz)
  ///   mid  = bands 2–3 (344 Hz–3.1 kHz)
  ///   high = bands 4–8 (3.1–22 kHz)
  void setEqBand(int deckId, EqBand band, bool active) {
    final dsp = _dsp[deckId];
    if (dsp == null) return;
    final eq = dsp.source.filters.equalizerFilter;
    final h = dsp.handle;
    final target = active ? 1.0 : 0.0;
    const fade = Duration(milliseconds: 80);

    final params = switch (band) {
      EqBand.low => [eq.band1(soundHandle: h)],
      EqBand.mid => [eq.band2(soundHandle: h), eq.band3(soundHandle: h)],
      EqBand.high => [
          eq.band4(soundHandle: h),
          eq.band5(soundHandle: h),
          eq.band6(soundHandle: h),
          eq.band7(soundHandle: h),
          eq.band8(soundHandle: h),
        ],
    };
    for (final p in params) {
      p.fadeFilterParameter(to: target, time: fade);
    }
  }

  bool hasDsp(int deckId) => _dsp.containsKey(deckId);

  // ── FX (Pacemaker-style pad) ───────────────────────────────────────────────

  /// Applies a continuous FX with pad coordinates x, y ∈ [0, 1].
  /// [beatDuration] is used by echo for beat-synced delays.
  ///
  /// Roll and beatskip are seek-based and live in DeckCubit, not here.
  void setFx(
    int deckId,
    FxType type,
    double x,
    double y, {
    Duration? beatDuration,
    bool engage = false,
  }) {
    final dsp = _dsp[deckId];
    if (dsp == null) return;
    final f = dsp.source.filters;
    final h = dsp.handle;
    const engageFade = Duration(milliseconds: 40);

    // `FilterParam` is not exported from the package root (`show FilterType`),
    // so the common param surface is only reachable dynamically.
    void apply(dynamic param, double value) {
      if (engage) {
        param.fadeFilterParameter(to: value, time: engageFade);
      } else {
        param.value = value;
      }
    }

    try {
      switch (type) {
        case FxType.hiLo:
          final centered = (x - 0.5).abs() <= FxParamMapper.hiLoDeadZone;
          if (centered) {
            f.biquadFilter.wet(soundHandle: h).value = 0;
            return;
          }
          final isLp = x < 0.5;
          f.biquadFilter.type(soundHandle: h).value = isLp ? 0 : 1;
          apply(
            f.biquadFilter.frequency(soundHandle: h),
            isLp
                ? FxParamMapper.hiLoLpFrequency(x)
                : FxParamMapper.hiLoHpFrequency(x),
          );
          f.biquadFilter.resonance(soundHandle: h).value =
              FxParamMapper.hiLoResonance(y);
          apply(f.biquadFilter.wet(soundHandle: h), 1);
        case FxType.echo:
          final beat = beatDuration ?? const Duration(milliseconds: 500);
          final delay = (FxParamMapper.echoBeats(x) *
                  beat.inMicroseconds /
                  1e6)
              .clamp(0.001, 1.0);
          f.echoFilter.delay(soundHandle: h).value = delay;
          f.echoFilter.decay(soundHandle: h).value =
              FxParamMapper.echoDecay(y);
          apply(f.echoFilter.wet(soundHandle: h), FxParamMapper.echoWet(y));
        case FxType.reverb:
          f.freeverbFilter.roomSize(soundHandle: h).value = x;
          apply(f.freeverbFilter.wet(soundHandle: h), y);
        case FxType.eightBit:
          f.lofiFilter.samplerate(soundHandle: h).value =
              FxParamMapper.eightBitSamplerate(x);
          f.lofiFilter.bitdepth(soundHandle: h).value = 5;
          apply(f.lofiFilter.wet(soundHandle: h), y);
        case FxType.roll:
        case FxType.beatskip:
          break;
      }
    } catch (e) {
      debugPrint('[AudioEngine] setFx($type) failed: $e');
    }
  }

  /// Deactivates a continuous FX (fades wet to 0, resets sweep params).
  void clearFx(int deckId, FxType type) {
    final dsp = _dsp[deckId];
    if (dsp == null) return;
    final f = dsp.source.filters;
    final h = dsp.handle;
    const fade = Duration(milliseconds: 50);

    try {
      switch (type) {
        case FxType.hiLo:
          f.biquadFilter
              .wet(soundHandle: h)
              .fadeFilterParameter(to: 0, time: fade);
          f.biquadFilter.frequency(soundHandle: h).value = 16000;
        case FxType.echo:
          f.echoFilter
              .wet(soundHandle: h)
              .fadeFilterParameter(to: 0, time: fade);
        case FxType.reverb:
          f.freeverbFilter
              .wet(soundHandle: h)
              .fadeFilterParameter(to: 0, time: fade);
        case FxType.eightBit:
          f.lofiFilter
              .wet(soundHandle: h)
              .fadeFilterParameter(to: 0, time: fade);
        case FxType.roll:
        case FxType.beatskip:
          break;
      }
    } catch (e) {
      debugPrint('[AudioEngine] clearFx($type) failed: $e');
    }
  }

  /// Synchronous position read (bypasses the 200 ms poll) — used to anchor
  /// the BeatClock for roll/beatskip.
  Duration positionSync(int deckId) {
    final dsp = _dsp[deckId];
    if (dsp != null) {
      return soloud.SoLoud.instance.getPosition(dsp.handle);
    }
    return playerFor(deckId).position;
  }

  // ── Streams (just_audio proxy or SoLoud polled) ───────────────────────────

  Stream<Duration> positionStream(int deckId) {
    if (_dsp.containsKey(deckId)) {
      return _posCtrl
          .putIfAbsent(deckId, StreamController<Duration>.broadcast)
          .stream;
    }
    return playerFor(deckId).positionStream;
  }

  Stream<Duration?> durationStream(int deckId) {
    if (_dsp.containsKey(deckId)) {
      return _durCtrl
          .putIfAbsent(deckId, StreamController<Duration?>.broadcast)
          .stream;
    }
    return playerFor(deckId).durationStream;
  }

  Stream<PlayerState> playerStateStream(int deckId) {
    if (_dsp.containsKey(deckId)) {
      return _stateCtrl
          .putIfAbsent(deckId, StreamController<PlayerState>.broadcast)
          .stream;
    }
    return playerFor(deckId).playerStateStream;
  }

  Duration? currentDuration(int deckId) {
    final dsp = _dsp[deckId];
    if (dsp != null) {
      return soloud.SoLoud.instance.getLength(dsp.source);
    }
    return playerFor(deckId).duration;
  }

  // ── Position polling (SoLoud doesn't push streams) ───────────────────────

  void _startPositionPolling(int deckId, soloud.AudioSource source) {
    _timers[deckId]?.cancel();

    _ensureDurCtrl(deckId).add(soloud.SoLoud.instance.getLength(source));

    _timers[deckId] = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final dsp = _dsp[deckId];
      if (dsp == null) return;

      final pos = soloud.SoLoud.instance.getPosition(dsp.handle);
      _ensurePosCtrl(deckId).add(pos);

      final dur = soloud.SoLoud.instance.getLength(source);
      if (dur > Duration.zero) {
        _ensureDurCtrl(deckId).add(dur);
      }

      // Detect natural end-of-track
      final isValid = soloud.SoLoud.instance.getIsValidVoiceHandle(dsp.handle);
      if (!isValid) {
        _emitState(deckId, playing: false);
        _timers[deckId]?.cancel();
        _timers.remove(deckId);
      }
    });
  }

  void _emitState(int deckId, {required bool playing}) {
    _ensureStateCtrl(deckId).add(
      PlayerState(
        playing,
        playing ? ProcessingState.ready : ProcessingState.ready,
      ),
    );
  }

  StreamController<Duration> _ensurePosCtrl(int deckId) =>
      _posCtrl.putIfAbsent(deckId, StreamController<Duration>.broadcast);

  StreamController<Duration?> _ensureDurCtrl(int deckId) =>
      _durCtrl.putIfAbsent(deckId, StreamController<Duration?>.broadcast);

  StreamController<PlayerState> _ensureStateCtrl(int deckId) =>
      _stateCtrl.putIfAbsent(
          deckId, StreamController<PlayerState>.broadcast);

  // ── Dispose ────────────────────────────────────────────────────────────────

  void _disposeDsp(int deckId) {
    _timers.remove(deckId)?.cancel();
    final dsp = _dsp.remove(deckId);
    if (dsp != null) {
      soloud.SoLoud.instance.stop(dsp.handle);
      soloud.SoLoud.instance.disposeSource(dsp.source);
    }
    _posCtrl.remove(deckId)?.close();
    _durCtrl.remove(deckId)?.close();
    _stateCtrl.remove(deckId)?.close();
  }

  void dispose(int deckId) {
    _disposeDsp(deckId);
    _players.remove(deckId)?.dispose();
  }

  void disposeAll() {
    for (final id in [..._dsp.keys, ..._players.keys]) {
      dispose(id);
    }
  }
}
