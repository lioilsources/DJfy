import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/beat_clock.dart';
import '../../models/deck_config.dart';
import '../../models/fx.dart';
import '../../models/track.dart';
import '../../services/audio_engine.dart';
import '../../services/soundcloud_service.dart';
import 'deck_state.dart';

class DeckCubit extends Cubit<DeckState> {
  final int deckId;
  final AudioEngine _engine;
  final BeatClock _beatClock = BeatClock();
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;

  // Roll state: while held, we keep re-seeking to _rollAnchor every slice,
  // and track where playback *would* be so release stays on the phrase grid.
  Timer? _rollTimer;
  Duration _rollAnchor = Duration.zero;
  double _rollBeats = 0;
  Stopwatch? _rollStopwatch;

  // Beatskip: remember the last bucket so dragging only skips on change.
  int? _beatskipBucket;

  // Throttle continuous FX updates to ~one per frame.
  Stopwatch? _fxThrottle;

  // Jog wheel: accumulated target position while the finger spins the deck.
  Duration? _jogPos;
  Stopwatch? _jogThrottle;

  /// One full revolution of the jog wheel = 1.8 s of track (33⅓ RPM vinyl).
  static const jogSecondsPerRevolution = 1.8;

  DeckCubit(this.deckId, this._engine)
      : super(DeckIdle(DeckConfig(id: deckId))) {
    _subscribeStreams();
  }

  void _subscribeStreams() {
    _positionSub = _engine.positionStream(deckId).listen((pos) {
      _beatClock.anchor(pos);
      final cfg = state.config.copyWith(position: pos);
      if (state is DeckReady) emit(DeckReady(cfg));
    });
    _durationSub = _engine.durationStream(deckId).listen((dur) {
      if (dur == null) return;
      final cfg = state.config.copyWith(duration: dur);
      if (state is DeckReady) emit(DeckReady(cfg));
      if (state is DeckLoading) emit(DeckLoading(cfg));
    });
    _stateSub = _engine.playerStateStream(deckId).listen((ps) {
      final playing = ps.playing;
      _beatClock
        ..playing = playing
        ..anchor(_engine.positionSync(deckId));
      final cfg = state.config.copyWith(isPlaying: playing);
      if (state is DeckReady) emit(DeckReady(cfg));
    });
  }

  Future<void> loadTrack(Track track) async {
    if (track.soundcloudStreamUrl == null) {
      emit(DeckError(state.config, 'Žádný stream URL'));
      return;
    }
    _endFxGesture();
    final loadingConfig = state.config.copyWith(track: track);
    emit(DeckLoading(loadingConfig));
    debugPrint('[Deck $deckId] loading: ${track.soundcloudStreamUrl}');

    // Resolve progressive URL in parallel with loading — it's a best-effort
    // call; failure just means no DSP EQ/FX on this track.
    String? progressiveUrl;
    try {
      final sc = GetIt.I.get<SoundCloudService>();
      if (track.scId != null) {
        progressiveUrl =
            await sc.resolveProgressiveUrl(track.scId!.toString());
      }
    } catch (e) {
      debugPrint('[Deck $deckId] progressive URL resolution failed: $e');
    }

    try {
      final hasDsp = await _engine.loadTrack(
        deckId,
        track.soundcloudStreamUrl!,
        progressiveUrl: progressiveUrl,
      );
      // Re-subscribe streams — SoLoud decks use different stream sources
      _cancelStreams();
      _subscribeStreams();

      _beatClock
        ..bpm = track.bpm?.toDouble()
        ..speed = state.config.speed
        ..playing = false
        ..anchor(Duration.zero);

      final dur = _engine.currentDuration(deckId) ?? Duration.zero;
      debugPrint('[Deck $deckId] load OK, hasDsp=$hasDsp, duration=${dur.inSeconds}s');
      emit(DeckReady(state.config.copyWith(duration: dur, hasDsp: hasDsp)));
    } catch (e) {
      debugPrint('[Deck $deckId] load FAILED: $e');
      emit(DeckError(loadingConfig, e.toString()));
    }
  }

  Future<void> togglePlayPause() async {
    if (state is! DeckReady) return;
    if (state.config.isPlaying) {
      await _engine.pause(deckId);
    } else {
      await _engine.play(deckId);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _engine.seekTo(deckId, position);
    _beatClock.anchor(position);
  }

  Future<void> setSpeed(double speed) async {
    await _engine.setSpeed(deckId, speed);
    _beatClock
      ..anchor(_engine.positionSync(deckId))
      ..speed = speed;
    emit(DeckReady(state.config.copyWith(speed: speed)));
  }

  Future<void> setVolume(double volume) async {
    await _engine.setVolume(deckId, volume);
    emit(DeckReady(state.config.copyWith(volume: volume)));
  }

  void toggleEqBand(EqBand band) {
    if (state is! DeckReady || !state.config.hasDsp) return;
    final current = state.config.eqBands[band] ?? true;
    final newActive = !current;
    _engine.setEqBand(deckId, band, newActive);
    final newBands = Map<EqBand, bool>.from(state.config.eqBands)
      ..[band] = newActive;
    emit(DeckReady(state.config.copyWith(eqBands: newBands)));
  }

  // ── FX pad ─────────────────────────────────────────────────────────────────

  bool get _fxUsable => state is DeckReady && state.config.hasDsp;

  bool fxAvailable(FxType type) =>
      _fxUsable && (!type.needsBpm || state.config.track?.bpm != null);

  void selectFx(FxType type) {
    if (state is! DeckReady) return;
    if (state.config.fxActive) _endFxGesture();
    emit(DeckReady(state.config.copyWith(selectedFx: type, fxActive: false)));
  }

  void fxStart(double x, double y) {
    final type = state.config.selectedFx;
    if (!fxAvailable(type)) return;
    _fxThrottle = Stopwatch()..start();

    switch (type) {
      case FxType.roll:
        _startRoll(x);
      case FxType.beatskip:
        _beatskipBucket = FxParamMapper.beatskipBeats(x);
        _skipBeats(_beatskipBucket!);
      default:
        _engine.setFx(deckId, type, x, y,
            beatDuration: _beatClock.beatDuration, engage: true);
    }
    emit(DeckReady(state.config.copyWith(fxActive: true, fxX: x, fxY: y)));
  }

  void fxUpdate(double x, double y) {
    if (state is! DeckReady || !state.config.fxActive) return;
    if (_fxThrottle != null && _fxThrottle!.elapsedMilliseconds < 16) return;
    _fxThrottle?.reset();
    final type = state.config.selectedFx;

    switch (type) {
      case FxType.roll:
        final beats = FxParamMapper.rollBeats(x);
        if (beats != _rollBeats) {
          _rollBeats = beats;
          _restartRollTimer();
        }
      case FxType.beatskip:
        final bucket = FxParamMapper.beatskipBeats(x);
        if (bucket != _beatskipBucket) {
          _beatskipBucket = bucket;
          _skipBeats(bucket);
        }
      default:
        _engine.setFx(deckId, type, x, y,
            beatDuration: _beatClock.beatDuration);
    }
    emit(DeckReady(state.config.copyWith(fxX: x, fxY: y)));
  }

  void fxEnd() {
    if (state is! DeckReady || !state.config.fxActive) return;
    _endFxGesture();
    emit(DeckReady(state.config.copyWith(fxActive: false)));
  }

  void _endFxGesture() {
    final type = state.config.selectedFx;
    if (type == FxType.roll && _rollTimer != null) {
      _stopRoll();
    } else if (type == FxType.beatskip) {
      _beatskipBucket = null;
    } else if (state.config.fxActive) {
      _engine.clearFx(deckId, type);
    }
  }

  // ── Roll ───────────────────────────────────────────────────────────────────

  void _startRoll(double x) {
    _rollBeats = FxParamMapper.rollBeats(x);
    _rollAnchor =
        _beatClock.quantizeToBeat(_engine.positionSync(deckId));
    if (_rollAnchor < Duration.zero) _rollAnchor = Duration.zero;
    _rollStopwatch = Stopwatch()..start();
    _engine.seekTo(deckId, _rollAnchor);
    _restartRollTimer();
  }

  /// Self-correcting scheduler: each fire is timed against the roll's own
  /// stopwatch (absolute wall-time targets), so Timer jitter never
  /// accumulates the way it would with Timer.periodic.
  void _restartRollTimer() {
    _rollTimer?.cancel();
    final sliceWallUs =
        (_beatClock.wallBeatDuration.inMicroseconds * _rollBeats).round();
    if (sliceWallUs <= 0) return;

    void scheduleNext() {
      final elapsed = _rollStopwatch!.elapsedMicroseconds;
      final nextTarget = ((elapsed ~/ sliceWallUs) + 1) * sliceWallUs;
      _rollTimer = Timer(Duration(microseconds: nextTarget - elapsed), () {
        if (_rollStopwatch == null) return;
        _engine.seekTo(deckId, _rollAnchor);
        scheduleNext();
      });
    }

    scheduleNext();
  }

  /// On release, jump to where the track would be had it kept playing, so
  /// the phrase stays locked to the grid (Pacemaker behavior).
  void _stopRoll() {
    _rollTimer?.cancel();
    _rollTimer = null;
    final sw = _rollStopwatch;
    _rollStopwatch = null;
    if (sw == null) return;
    final virtualPos = _rollAnchor +
        Duration(
          microseconds:
              (sw.elapsedMicroseconds * _beatClock.speed).round(),
        );
    final dur = state.config.duration;
    final target = virtualPos > dur && dur > Duration.zero ? dur : virtualPos;
    _engine.seekTo(deckId, target);
    _beatClock.anchor(target);
  }

  // ── Jog wheel (vinyl scratching) ───────────────────────────────────────────

  void jogStart() {
    if (state is! DeckReady) return;
    _jogPos = _engine.positionSync(deckId);
    _jogThrottle = Stopwatch()..start();
  }

  /// [deltaRadians] of wheel rotation since the last call; clockwise seeks
  /// forward, counter-clockwise back.
  void jogBy(double deltaRadians) {
    final pos = _jogPos;
    if (pos == null || state is! DeckReady) return;

    final deltaUs =
        deltaRadians / (2 * math.pi) * jogSecondsPerRevolution * 1e6;
    var target = pos + Duration(microseconds: deltaUs.round());
    if (target < Duration.zero) target = Duration.zero;
    final dur = state.config.duration;
    if (dur > Duration.zero && target > dur) target = dur;
    _jogPos = target;

    // Optimistic position so the vinyl follows the finger between 200 ms polls.
    emit(DeckReady(state.config.copyWith(position: target)));

    if (_jogThrottle != null && _jogThrottle!.elapsedMilliseconds < 33) return;
    _jogThrottle?.reset();
    _engine.seekTo(deckId, target);
  }

  void jogEnd() {
    final target = _jogPos;
    _jogPos = null;
    _jogThrottle = null;
    if (target == null) return;
    _engine.seekTo(deckId, target);
    _beatClock.anchor(target);
  }

  // ── Beatskip ───────────────────────────────────────────────────────────────

  void _skipBeats(int beats) {
    final current = _engine.positionSync(deckId);
    final delta = Duration(
      microseconds: _beatClock.beatDuration.inMicroseconds * beats,
    );
    var target = current + delta;
    if (target < Duration.zero) target = Duration.zero;
    final dur = state.config.duration;
    if (dur > Duration.zero && target > dur) target = dur;
    _engine.seekTo(deckId, target);
    _beatClock.anchor(target);
  }

  void _cancelStreams() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
  }

  @override
  Future<void> close() {
    _rollTimer?.cancel();
    _rollStopwatch = null;
    _cancelStreams();
    _engine.dispose(deckId);
    return super.close();
  }
}
