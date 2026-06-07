import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart' as soloud;
import 'package:just_audio/just_audio.dart';

import '../models/deck_config.dart';

/// Per-deck DSP state — only present when a progressive URL was loaded into
/// SoLoud (i.e. [DeckConfig.hasDsp] == true).
class _DspDeck {
  final soloud.AudioSource source;
  soloud.SoundHandle handle;

  _DspDeck({required this.source, required this.handle});
}

/// Unified audio engine managing per-deck playback.
///
/// * **Progressive MP3 URL** → played via `flutter_soloud` for real-time EQ
///   stem approximation. Position/duration are polled via a periodic [Timer].
/// * **HLS URL** (or any `.m3u8` / `hls` URL) → played via `just_audio` as
///   before, but without DSP. Stem filter buttons are disabled in that case.
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

  // ── Init ────────────────────────────────────────────────────────────────────
  static Future<void> initSoLoud() async {
    await soloud.SoLoud.instance.init();
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  /// Loads a track onto a deck.
  ///
  /// If [progressiveUrl] is provided and non-null, the deck is run through
  /// SoLoud with a 3-band EQ. Otherwise, it falls back to just_audio HLS.
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
  }

  Future<bool> _loadViaSoLoud(int deckId, String url) async {
    try {
      final source = await soloud.SoLoud.instance.loadUrl(url);
      final handle = await soloud.SoLoud.instance.play(source, paused: true);

      // Activate 8-band EQ on this source (all bands at 1.0 = pass-through)
      source.filters.equalizerFilter.activate();

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
    final dsp = _dsp[deckId];
    if (dsp != null) {
      soloud.SoLoud.instance.setVolume(dsp.handle, volume);
    } else {
      await playerFor(deckId).setVolume(volume);
    }
  }

  // ── Stem filters ──────────────────────────────────────────────────────────

  /// Drums ≈ bands 1–3 (≈32, 64, 125 Hz)
  /// Melody ≈ bands 4–6 (≈250, 500, 1000 Hz)
  /// Vocals ≈ bands 7–8 (≈2000, 4000 Hz)
  void setStemActive(int deckId, StemType stem, bool active) {
    final dsp = _dsp[deckId];
    if (dsp == null) return;
    final eq = dsp.source.filters.equalizerFilter;
    final target = active ? 1.0 : 0.0;
    const fade = Duration(milliseconds: 80);

    switch (stem) {
      case StemType.drums:
        eq.band1().fadeFilterParameter(to: target, time: fade);
        eq.band2().fadeFilterParameter(to: target, time: fade);
        eq.band3().fadeFilterParameter(to: target, time: fade);
      case StemType.melody:
        eq.band4().fadeFilterParameter(to: target, time: fade);
        eq.band5().fadeFilterParameter(to: target, time: fade);
        eq.band6().fadeFilterParameter(to: target, time: fade);
      case StemType.vocals:
        eq.band7().fadeFilterParameter(to: target, time: fade);
        eq.band8().fadeFilterParameter(to: target, time: fade);
    }
  }

  bool hasDsp(int deckId) => _dsp.containsKey(deckId);

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
