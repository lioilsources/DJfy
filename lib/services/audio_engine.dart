import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:djfy_decoder/djfy_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart' as soloud;
import 'package:just_audio/just_audio.dart';

import '../core/track_analysis.dart';
import '../models/deck_config.dart';
import '../models/fx.dart';
import 'scratch_voice.dart';

/// Per-deck DSP state — only present when a progressive URL was loaded into
/// SoLoud (i.e. [DeckConfig.hasDsp] == true).
class _DspDeck {
  final soloud.AudioSource source;
  soloud.SoundHandle handle;

  /// Set when the deck plays decoded PCM: scratchable, backwards included.
  final ScratchVoice? voice;

  /// Waveform and onsets of the decoded track, computed in the background.
  final Future<TrackAnalysis?>? analysis;

  _DspDeck({required this.source, required this.handle, this.voice, this.analysis});
}

/// A newer load for the same deck took over while this one was downloading.
class LoadSuperseded implements Exception {
  @override
  String toString() => 'load superseded';
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
/// * **Progressive MP3 URL** → downloaded, decoded to PCM and played by a
///   [ScratchVoice] (our own playhead into a SoLoud buffer stream): real
///   scratching, sample-accurate loops, and SoLoud's filters for EQ/FX.
///   If decoding fails, SoLoud plays the file itself (DSP, no reverse).
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

  // ── Platter rate: a held record is muted, not paused ───────────────────────
  final Map<int, double> _scratchGain = {};
  final Map<int, double> _sentSpeed = {};

  /// Slowest and fastest speed the players take; neither plays backwards.
  static const minRate = 0.05;
  static const maxRate = 4.0;

  // ── Init ────────────────────────────────────────────────────────────────────
  /// 512 frames ≈ 11.6 ms per mix at 44.1 kHz; the default 2048 adds ~46 ms
  /// between a finger on the platter and the sound (spike, handoff 05).
  static const mixerBufferFrames = 512;

  static Future<void> initSoLoud() async {
    await soloud.SoLoud.instance.init(bufferSize: mixerBufferFrames);
  }

  /// Decoded tracks take ~10 MB a minute; cap how many decks hold one.
  static const maxVoices = 4;
  static const _maxDownloadBytes = 40 << 20;
  static const _downloadTimeout = Duration(seconds: 20);

  final Map<int, int> _loadSeq = {};

  // ── Load ────────────────────────────────────────────────────────────────────

  /// Loads a track onto a deck.
  ///
  /// If [progressiveUrl] is a real progressive MP3, the deck is run through
  /// SoLoud with EQ + FX filters. Otherwise, or when SoLoud fails, it falls
  /// back to just_audio on [hlsUrl].
  ///
  /// Returns true if DSP (SoLoud) was activated, false for the just_audio
  /// fallback. Throws if the fallback can't load either.
  Future<bool> loadTrack(
    int deckId,
    String hlsUrl, {
    String? progressiveUrl,
  }) async {
    // Tear down any existing SoLoud state for this deck
    _disposeDsp(deckId);
    final seq = _loadSeq[deckId] = (_loadSeq[deckId] ?? 0) + 1;

    if (progressiveUrl != null && progressiveUrl.isNotEmpty && !isHlsUrl(progressiveUrl)) {
      final voices = _dsp.values.where((d) => d.voice != null).length;
      if (voices < maxVoices && await _loadViaVoice(deckId, progressiveUrl, seq)) return true;
      if (_loadSeq[deckId] != seq) throw LoadSuperseded();
      if (await _loadViaSoLoud(deckId, progressiveUrl)) return true;
    }
    await _loadViaJustAudio(deckId, hlsUrl);
    return false;
  }

  /// SoundCloud's "progressive" CDN URL is sometimes an HLS playlist
  /// (`…/playlist/…`), which SoLoud can't decode — it hangs instead.
  static bool isHlsUrl(String url) => url.contains('.m3u8') || url.contains('hls') || url.contains('/playlist');

  static const _soloudLoadTimeout = Duration(seconds: 10);

  Future<void> _loadViaJustAudio(int deckId, String url) async {
    final player = playerFor(deckId);
    await player.stop();
    // Detect HLS vs progressive: just_audio handles both, but use the right
    // source type so it doesn't try to parse an MP3 as an HLS playlist.
    if (isHlsUrl(url)) {
      await player.setAudioSource(HlsAudioSource(Uri.parse(url)));
    } else {
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    }
    await player.setVolume(_effectiveVolume(deckId));
  }

  Future<bool> _loadViaVoice(int deckId, String url, int seq) async {
    try {
      final sw = Stopwatch()..start();
      final bytes = await _download(url).timeout(_downloadTimeout);
      final downloaded = sw.elapsedMilliseconds;
      final pcm = await decodeMp3(bytes);
      if (_loadSeq[deckId] != seq) throw LoadSuperseded();
      if (pcm == null) {
        debugPrint('[AudioEngine] deck $deckId: not a decodable MP3');
        return false;
      }
      final voice = await ScratchVoice.start(
        pcm,
        volume: _effectiveVolume(deckId),
        prepareFilters: _activateFilters,
        onEnded: () => _emitState(deckId, playing: false, completed: true),
      );
      if (_loadSeq[deckId] != seq) {
        await voice.dispose();
        throw LoadSuperseded();
      }
      _neutralizeFilters(voice.source, voice.handle);
      _dsp[deckId] = _DspDeck(source: voice.source, handle: voice.handle, voice: voice, analysis: _analyze(pcm));
      _startPositionPolling(deckId, voice.source);
      debugPrint('[AudioEngine] deck $deckId → scratch voice (${pcm.duration.inSeconds} s, '
          'download $downloaded ms, decode ${sw.elapsedMilliseconds - downloaded} ms)');
      return true;
    } on LoadSuperseded {
      rethrow;
    } catch (e) {
      debugPrint('[AudioEngine] scratch voice failed ($e), deck $deckId');
      return false;
    }
  }

  /// Reads the PCM from another isolate; [pcm] stays referenced until the
  /// future completes, so its native memory can't be freed underneath.
  static Future<TrackAnalysis?> _analyze(DecodedPcm pcm) async {
    final address = pcm.address, length = pcm.samples.length;
    final channels = pcm.channels, rate = pcm.sampleRate;
    try {
      return await Isolate.run(
        () => TrackAnalysis.of(DecodedPcm.view(address, length), channels: channels, sampleRate: rate),
      );
    } catch (e) {
      debugPrint('[AudioEngine] analysis failed: $e');
      return null;
    } finally {
      pcm.samples.length; // keep alive
    }
  }

  /// Waveform and onsets of a PCM deck's track; null for other decks.
  Future<TrackAnalysis?> analysis(int deckId) => _dsp[deckId]?.analysis ?? Future.value();

  static Future<Uint8List> _download(String url) async {
    final client = HttpClient();
    try {
      final res = await (await client.getUrl(Uri.parse(url))).close();
      if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(url));
      final out = BytesBuilder(copy: false);
      await for (final chunk in res) {
        out.add(chunk);
        if (out.length > _maxDownloadBytes) throw const HttpException('track too large');
      }
      return out.takeBytes();
    } finally {
      client.close(force: true);
    }
  }

  /// Filters must be activated BEFORE play(): filter instances are cloned
  /// onto the voice at play time; a later activate() never reaches it.
  static void _activateFilters(soloud.AudioSource source) {
    final f = source.filters;
    f.equalizerFilter.activate();
    f.biquadFilter.activate();
    f.echoFilter.activate();
    f.freeverbFilter.activate();
    f.lofiFilter.activate();
  }

  /// Neutralize per-voice params before anything is heard. Every call needs
  /// `soundHandle:` — without it the value goes to the (inactive) global
  /// filter chain and is silently dropped.
  static void _neutralizeFilters(soloud.AudioSource source, soloud.SoundHandle handle) {
    final f = source.filters;
    f.biquadFilter.wet(soundHandle: handle).value = 0;
    f.biquadFilter.frequency(soundHandle: handle).value = 16000;
    // Echo buffer size is fixed from `delay` at the first audio-process
    // callback and can never grow afterwards — reserve 1 s of headroom now.
    f.echoFilter.wet(soundHandle: handle).value = 0;
    f.echoFilter.delay(soundHandle: handle).value = 1.0;
    f.echoFilter.decay(soundHandle: handle).value = 0.5;
    f.freeverbFilter.wet(soundHandle: handle).value = 0; // default is 1!
    f.lofiFilter.wet(soundHandle: handle).value = 0; // default is 1!
  }

  Future<bool> _loadViaSoLoud(int deckId, String url) async {
    try {
      // loadUrl downloads the whole file before returning; don't let a slow
      // CDN stall the deck — just_audio can stream it instead.
      final pending = soloud.SoLoud.instance.loadUrl(url);
      final source = await pending.timeout(_soloudLoadTimeout, onTimeout: () {
        pending.then(soloud.SoLoud.instance.disposeSource, onError: (_) {});
        throw TimeoutException('SoLoud loadUrl', _soloudLoadTimeout);
      });

      _activateFilters(source);

      final handle = await soloud.SoLoud.instance.play(
        source,
        paused: true,
        volume: _effectiveVolume(deckId),
      );

      _neutralizeFilters(source, handle);

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

  /// Starts playback and returns right away. just_audio's own `play()` future
  /// only completes when the track ends or is paused, so awaiting it would
  /// stall the caller for the whole song.
  Future<void> play(int deckId) async {
    final dsp = _dsp[deckId];
    if (dsp?.voice case final voice?) {
      voice.playing = true;
      _emitState(deckId, playing: true);
    } else if (dsp != null) {
      soloud.SoLoud.instance.setPause(dsp.handle, false);
      _emitState(deckId, playing: true);
    } else {
      unawaited(playerFor(deckId).play().catchError((Object e) {
        debugPrint('[AudioEngine] deck $deckId play failed: $e');
      }));
    }
  }

  Future<void> pause(int deckId) async {
    final dsp = _dsp[deckId];
    if (dsp?.voice case final voice?) {
      voice.playing = false;
      _emitState(deckId, playing: false);
    } else if (dsp != null) {
      soloud.SoLoud.instance.setPause(dsp.handle, true);
      _emitState(deckId, playing: false);
    } else {
      await playerFor(deckId).pause();
    }
  }

  /// Stops the deck and drops its loaded track, keeping the player for reuse.
  Future<void> stop(int deckId) async {
    _loadSeq[deckId] = (_loadSeq[deckId] ?? 0) + 1; // cancels a download in flight
    _disposeDsp(deckId);
    await playerFor(deckId).stop();
  }

  Future<void> seekTo(int deckId, Duration position) async {
    final dsp = _dsp[deckId];
    if (dsp?.voice case final voice?) {
      voice.seek(position);
    } else if (dsp != null) {
      soloud.SoLoud.instance.seek(dsp.handle, position);
    } else {
      await playerFor(deckId).seek(position);
    }
  }

  Future<void> setSpeed(int deckId, double speed) async {
    _sentSpeed[deckId] = speed;
    final dsp = _dsp[deckId];
    if (dsp?.voice case final voice?) {
      voice.rate = speed;
    } else if (dsp != null) {
      soloud.SoLoud.instance.setRelativePlaySpeed(dsp.handle, speed);
    } else {
      await playerFor(deckId).setSpeed(speed);
    }
  }

  /// Follows the platter: [rate] is signed, 1 = normal. Neither engine plays
  /// backwards or at 0, so below [minRate] the deck is muted (it keeps
  /// reporting "playing", the way a held record still turns under the motor)
  /// and the caller seeks to move it back.
  Future<void> setRate(int deckId, double rate) async {
    if (_dsp[deckId]?.voice case final voice?) {
      voice.rate = rate; // the voice plays any rate, and fades out when still
      return;
    }
    final still = rate.abs() < minRate;
    final gain = still ? 0.0 : 1.0;
    if ((_scratchGain[deckId] ?? 1) != gain) {
      _scratchGain[deckId] = gain;
      await _applyVolume(deckId);
    }
    final speed = rate.abs().clamp(minRate, maxRate);
    if (speed == _sentSpeed[deckId]) return;
    _sentSpeed[deckId] = speed;
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
      (_baseVolume[deckId] ?? 0.8) * (_xfGain[deckId] ?? 1.0) * (_scratchGain[deckId] ?? 1.0);

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

  /// The deck plays decoded PCM: it can go backwards and follow a finger.
  bool canReverse(int deckId) => _dsp[deckId]?.voice != null;

  /// A finger holds the record at [at], moving at [rate]; null lets go.
  /// Only for [canReverse] decks.
  void follow(int deckId, Duration? at, double rate) => _dsp[deckId]?.voice?.follow(at, rate);

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
    if (dsp?.voice case final voice?) return voice.position;
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
    if (dsp?.voice case final voice?) return voice.duration;
    if (dsp != null) {
      return soloud.SoLoud.instance.getLength(dsp.source);
    }
    return playerFor(deckId).duration;
  }

  // ── Position polling (SoLoud doesn't push streams) ───────────────────────

  void _startPositionPolling(int deckId, soloud.AudioSource source) {
    _timers[deckId]?.cancel();

    _ensureDurCtrl(deckId).add(currentDuration(deckId));

    _timers[deckId] = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final dsp = _dsp[deckId];
      if (dsp == null) return;
      if (dsp.voice case final voice?) {
        _ensurePosCtrl(deckId).add(voice.position); // the end comes from the voice
        return;
      }

      final pos = soloud.SoLoud.instance.getPosition(dsp.handle);
      _ensurePosCtrl(deckId).add(pos);

      final dur = soloud.SoLoud.instance.getLength(source);
      if (dur > Duration.zero) {
        _ensureDurCtrl(deckId).add(dur);
      }

      // Detect natural end-of-track
      final isValid = soloud.SoLoud.instance.getIsValidVoiceHandle(dsp.handle);
      if (!isValid) {
        _emitState(deckId, playing: false, completed: true);
        _timers[deckId]?.cancel();
        _timers.remove(deckId);
      }
    });
  }

  void _emitState(int deckId, {required bool playing, bool completed = false}) {
    _ensureStateCtrl(deckId).add(
      PlayerState(
        playing,
        completed ? ProcessingState.completed : ProcessingState.ready,
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
    _sentSpeed.remove(deckId);
    _timers.remove(deckId)?.cancel();
    final dsp = _dsp.remove(deckId);
    if (dsp?.voice case final voice?) {
      unawaited(voice.dispose());
    } else if (dsp != null) {
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
