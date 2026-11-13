import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;

import '../../core/beat_clock.dart';
import '../../core/platter.dart';
import '../../models/deck_config.dart';
import '../../models/fx.dart';
import '../../models/track.dart';
import '../../services/audio_engine.dart';
import '../../services/soundcloud_service.dart';
import 'deck_state.dart';

class DeckCubit extends Cubit<DeckState> {
  final int deckId;
  final AudioEngine _engine;
  final SoundCloudService? _sc;
  final BeatClock _beatClock = BeatClock();
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;

  /// Bumped by every load and [eject]; superseded loads must not touch state.
  int _loadGen = 0;

  final _completed = StreamController<void>.broadcast();
  bool _atEnd = false;

  /// Fires once each time the loaded track plays to its end.
  Stream<void> get completed => _completed.stream;

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

  // Platter: the record under the finger. Ticks only while something moves.
  final Platter _platter = Platter();
  Timer? _platterTimer;
  final Stopwatch _platterClock = Stopwatch();
  int _lastTickUs = 0;
  double? _sentRate;
  bool _braking = false;

  /// Track position under the finger while the record is touched.
  Duration? _touchTarget;
  Duration _slipFrom = Duration.zero;
  final Stopwatch _slipClock = Stopwatch();
  bool _playingAtTouch = false;
  Stopwatch? _seekThrottle;
  Stopwatch? _emitThrottle;

  /// Audio further than this from the finger is pulled back with a seek.
  static const _maxDrift = Duration(milliseconds: 60);

  DeckCubit(this.deckId, this._engine, {SoundCloudService? soundCloud})
      : _sc = soundCloud,
        super(DeckIdle(DeckConfig(id: deckId))) {
    _subscribeStreams();
  }

  SoundCloudService get _soundCloud => _sc ?? GetIt.I.get<SoundCloudService>();

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
      final atEnd = ps.processingState == ProcessingState.completed;
      if (atEnd && !_atEnd) _completed.add(null);
      _atEnd = atEnd;
      _beatClock
        ..playing = playing
        ..anchor(_engine.positionSync(deckId));
      // Play/pause from outside (track end, party, another control): keep the
      // motor in step, except while a finger holds the record.
      if (_platter.mode == PlatterMode.motor && !_braking && _platter.motorOn != playing) {
        _platter.setMotor(playing);
      }
      final cfg = state.config.copyWith(isPlaying: playing);
      if (state is DeckReady) emit(DeckReady(cfg));
    });
  }

  /// Loads [track] onto the deck.
  ///
  /// [streaming] resolves the stream from the track's SoundCloud id and plays
  /// it through just_audio: it starts fast but has no DSP, and failures are
  /// rethrown so the caller can move on. Without it, failures only show on the
  /// deck. A newer load or [eject] silently supersedes this one.
  Future<void> loadTrack(Track track, {bool streaming = false}) async {
    if (!streaming && track.soundcloudStreamUrl == null) {
      emit(DeckError(state.config, 'Žádný stream URL'));
      return;
    }
    final gen = ++_loadGen;
    _endFxGesture();
    _resetPlatter();
    final loadingConfig = state.config.copyWith(
      track: track,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
    emit(DeckLoading(loadingConfig));
    _atEnd = false;
    debugPrint('[Deck $deckId] loading: ${track.title}');

    try {
      final String url;
      String? progressiveUrl;
      if (streaming) {
        final streams = await _soundCloud.streamsFor(track.scId ?? (throw StateError('Track has no SoundCloud id')));
        if (gen != _loadGen || isClosed) return;
        url = streams.fallback ?? (throw StateError('No stream for "${track.title}"'));
        progressiveUrl = streams.progressive; // PCM if it's ready in time: scratch + FX at the party
      } else {
        url = track.soundcloudStreamUrl!;
        progressiveUrl = await _resolveProgressive(track);
        if (gen != _loadGen || isClosed) return;
      }

      final hasDsp = await _engine.loadTrack(deckId, url, progressiveUrl: progressiveUrl, streaming: streaming);
      if (gen != _loadGen || isClosed) return;
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
      _beatClock.offset = Duration.zero;
      emit(DeckReady(state.config.copyWith(
        duration: dur,
        hasDsp: hasDsp,
        clearWaveform: true,
        beatOffset: Duration.zero,
      )));
      unawaited(_applyAnalysis(gen, track));
    } catch (e) {
      if (gen != _loadGen || isClosed) return;
      debugPrint('[Deck $deckId] load FAILED: $e');
      emit(DeckError(state.config, e.toString()));
      if (streaming) rethrow;
    }
  }

  /// Waveform and beat grid once the background analysis is done.
  Future<void> _applyAnalysis(int gen, Track track) async {
    final analysis = await _engine.analysis(deckId);
    if (analysis == null || gen != _loadGen || isClosed || state is! DeckReady) return;
    final offset = track.bpm == null ? null : analysis.beatOffset(track.bpm!.toDouble());
    if (offset != null) _beatClock.offset = offset;
    emit(DeckReady(state.config.copyWith(waveform: analysis.peaks, beatOffset: offset)));
  }

  /// TAP: the beat is now. Sets the grid phase for roll, beatskip and loops.
  void tapBeat() {
    if (state is! DeckReady || state.config.track?.bpm == null) return;
    final offset = _beatClock.phaseAt(displayPosition);
    _beatClock.offset = offset;
    emit(DeckReady(state.config.copyWith(beatOffset: offset)));
  }

  /// Beat length in track time, for drawing the grid.
  Duration get beatDuration => _beatClock.beatDuration;

  // Best-effort: failure just means no DSP EQ/FX on this track.
  Future<String?> _resolveProgressive(Track track) async {
    try {
      if (track.scId == null) return null;
      return await _soundCloud.resolveProgressiveUrl(track.scId!.toString());
    } catch (e) {
      debugPrint('[Deck $deckId] progressive URL resolution failed: $e');
      return null;
    }
  }

  Future<void> play() async {
    _braking = false;
    _platter.setMotor(true);
    _sendRate(_platter.rate, force: true);
    await _engine.play(deckId);
  }

  Future<void> pause() async {
    _braking = false;
    _platter.setMotor(false);
    await _engine.pause(deckId);
  }

  /// Stops the deck and empties it, cancelling a load in progress.
  Future<void> eject() async {
    final gen = ++_loadGen;
    _atEnd = false;
    _resetPlatter();
    await _engine.stop(deckId);
    if (gen != _loadGen || isClosed) return;
    _cancelStreams();
    _subscribeStreams();
    final c = state.config;
    emit(DeckIdle(DeckConfig(id: deckId, volume: c.volume, partyRole: c.partyRole, slip: c.slip)));
  }

  /// Party takeover: changes the deck's role without touching its playback.
  void setPartyRole(PartyDeckRole? role) {
    final c = state.config.copyWith(partyRole: role, clearPartyRole: role == null);
    emit(switch (state) {
      DeckIdle() => DeckIdle(c),
      DeckLoading() => DeckLoading(c),
      DeckReady() => DeckReady(c),
      DeckError(:final message) => DeckError(c, message),
    });
  }

  Future<void> togglePlayPause() async {
    if (state is! DeckReady) return;
    if (state.config.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _engine.seekTo(deckId, position);
    _beatClock.anchor(position);
  }

  Future<void> setSpeed(double speed) async {
    _platter.speed = speed;
    if (_platter.mode == PlatterMode.motor && !_braking) {
      _platter.setMotor(_platter.motorOn);
      _sendRate(_platter.motorOn ? _platter.rate : speed);
    }
    if (isClosed) return;
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
      _fxUsable &&
      (!type.needsBpm || state.config.track?.bpm != null) &&
      (!type.needsPcm || _engine.canReverse(deckId));

  /// A finger is on the pad (a latched FX stays on without one).
  bool _fxTouching = false;

  /// Brake or spin actually stopped the record: release spins it back up.
  bool _fxStopped = false;

  void selectFx(FxType type) {
    if (state is! DeckReady) return;
    if (state.config.fxActive) _endFxGesture();
    emit(DeckReady(state.config.copyWith(selectedFx: type, fxActive: false, fxLatched: false)));
  }

  /// Latch: the effect keeps going with the last x/y after the finger lifts.
  void toggleFxLatch() {
    if (state is! DeckReady || !state.config.selectedFx.latchable) return;
    final latched = !state.config.fxLatched;
    emit(DeckReady(state.config.copyWith(fxLatched: latched)));
    if (!latched && state.config.fxActive && !_fxTouching) fxEnd();
  }

  void fxStart(double x, double y) {
    final type = state.config.selectedFx;
    if (!fxAvailable(type)) return;
    _fxTouching = true;
    // Latched and running: touching again just moves it.
    if (state.config.fxActive && state.config.fxLatched) {
      fxUpdate(x, y);
      return;
    }
    _fxThrottle = Stopwatch()..start();

    switch (type) {
      case FxType.roll:
        _startRoll(x);
      case FxType.beatskip:
        _beatskipBucket = FxParamMapper.beatskipBeats(x);
        _skipBeats(_beatskipBucket!);
      case FxType.brake:
        _fxStopped = state.config.isPlaying;
        brake(FxParamMapper.brakeSeconds(x));
      case FxType.spin:
        _fxStopped = state.config.isPlaying;
        backspin(FxParamMapper.spinStrength(y), FxParamMapper.spinSeconds(x));
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
      case FxType.brake:
      case FxType.spin:
        break; // decided at touch-down; the release spins it back up
      default:
        _engine.setFx(deckId, type, x, y,
            beatDuration: _beatClock.beatDuration);
    }
    emit(DeckReady(state.config.copyWith(fxX: x, fxY: y)));
  }

  void fxEnd() {
    _fxTouching = false;
    if (state is! DeckReady || !state.config.fxActive) return;
    if (state.config.fxLatched && state.config.selectedFx.latchable) return;
    _endFxGesture(resume: true);
    emit(DeckReady(state.config.copyWith(fxActive: false)));
  }

  /// [resume]: the finger let go of brake/spin, so the motor starts again
  /// (not when a new track or another effect ends the gesture).
  void _endFxGesture({bool resume = false}) {
    final type = state.config.selectedFx;
    if (type == FxType.roll && _rollStopwatch != null) {
      _stopRoll();
    } else if (type == FxType.beatskip) {
      _beatskipBucket = null;
    } else if (type == FxType.brake || type == FxType.spin) {
      if (resume && _fxStopped) _spinUp();
      _fxStopped = false;
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
    if (!_engine.canReverse(deckId)) _engine.seekTo(deckId, _rollAnchor);
    _restartRollTimer();
  }

  Duration get _rollSlice =>
      Duration(microseconds: (_beatClock.beatDuration.inMicroseconds * _rollBeats).round());

  /// Self-correcting scheduler: each fire is timed against the roll's own
  /// stopwatch (absolute wall-time targets), so Timer jitter never
  /// accumulates the way it would with Timer.periodic.
  void _restartRollTimer() {
    _rollTimer?.cancel();
    if (_engine.canReverse(deckId)) {
      // The voice loops sample-accurately: no timer jitter, no seek clicks.
      _engine.loop(deckId, _rollAnchor, _rollSlice);
      return;
    }
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
    if (_engine.canReverse(deckId)) _engine.endLoop(deckId);
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

  // ── Platter (vinyl scratching) ─────────────────────────────────────────────

  /// The NEXT deck of a party only waits for its track; nothing to scratch.
  bool get canScratch => state is DeckReady && state.config.partyRole != PartyDeckRole.next;

  /// Where the record is: under the finger, or extrapolated between polls.
  Duration get displayPosition => _touchTarget ?? _beatClock.estimatedPosition;

  /// Record angle for the platter painter, consistent with scratching.
  double get platterAngle =>
      displayPosition.inMicroseconds / 1e6 / Platter.secondsPerRevolution * 2 * math.pi;

  /// Nothing left to animate: a ticker can stop once the deck isn't playing.
  bool get platterIdle => _platterTimer == null;

  /// A finger lands on the record: it stops right away (vinyl mode).
  void platterTouch() {
    if (!canScratch) return;
    _braking = false;
    final pos = _engine.positionSync(deckId);
    _touchTarget = pos;
    _slipFrom = pos;
    _slipClock
      ..reset()
      ..start();
    _playingAtTouch = state.config.isPlaying;
    _platter.touch();
    _sendRate(0);
    if (_engine.canReverse(deckId)) {
      _engine.follow(deckId, pos, 0); // the voice sounds under the finger even when paused
    } else if (!_playingAtTouch) {
      unawaited(_engine.play(deckId)); // a paused record still sounds under the finger
    }
    _seekThrottle = Stopwatch()..start();
    _emitThrottle = Stopwatch()..start();
    _runPlatter();
  }

  /// The finger turned the record by [radians] over [seconds].
  void platterDrag(double radians, double seconds) {
    final target = _touchTarget;
    if (target == null || state is! DeckReady) return;
    _platter.drag(radians, seconds);
    _touchTarget = _clampPosition(target + Platter.trackTime(radians));
    _followFinger();
    if (_emitThrottle!.elapsedMilliseconds >= 33) {
      _emitThrottle!.reset();
      emit(DeckReady(state.config.copyWith(position: _touchTarget)));
    }
  }

  void platterRelease() {
    final target = _touchTarget;
    if (target == null) return;
    _touchTarget = null;
    _seekThrottle = null;
    _emitThrottle = null;
    _platter.release();
    final reversible = _engine.canReverse(deckId);
    if (reversible) _engine.follow(deckId, null, 0); // it already sits under the finger
    if (!_playingAtTouch) {
      _platter.setMotor(false);
      if (!reversible) {
        unawaited(_engine.pause(deckId));
        _seek(target);
      }
    } else if (state.config.slip) {
      // Slip: the track went on underneath; carry on where it would be.
      final elapsed = _slipClock.elapsedMicroseconds * _platter.speed;
      _seek(_clampPosition(_slipFrom + Duration(microseconds: elapsed.round())));
      _platter.setMotor(true);
      _sendRate(_platter.rate);
    } else if (!reversible) {
      _seek(target);
    }
    _runPlatter();
  }

  /// Coasts to a stop over [seconds], like cutting the motor of a turntable.
  void brake([double seconds = 1]) {
    if (state is! DeckReady || !state.config.isPlaying || _touchTarget != null) return;
    _braking = true;
    _platter.brake(seconds);
    _runPlatter();
  }

  /// Backspin: the record is thrown backwards and coasts to a stop (PCM decks).
  void backspin(double strength, double seconds) {
    if (state is! DeckReady || !state.config.isPlaying || _touchTarget != null) return;
    if (!_engine.canReverse(deckId)) return;
    _braking = true;
    _platter.backspin(strength, seconds);
    _runPlatter();
  }

  /// Motor on again from wherever the record is (after brake or spin).
  void _spinUp() {
    if (state is! DeckReady) return;
    _braking = false;
    _platter.spinUp();
    _sendRate(_platter.rate, force: true);
    unawaited(_engine.play(deckId));
    _runPlatter();
  }

  /// Pitch bend while a nudge button is held: −1, 0 or +1.
  void nudge(int direction) {
    _platter.nudge = direction.sign;
    if (_platter.motorOn) _runPlatter();
  }

  void toggleSlip() {
    if (state is! DeckReady) return;
    emit(DeckReady(state.config.copyWith(slip: !state.config.slip)));
  }

  void _runPlatter() {
    if (_platterTimer != null) return;
    _platterClock
      ..reset()
      ..start();
    _lastTickUs = 0;
    _platterTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tickPlatter());
  }

  void _tickPlatter() {
    final now = _platterClock.elapsedMicroseconds;
    _platter.tick((now - _lastTickUs) / 1e6);
    _lastTickUs = now;
    if (_touchTarget != null) {
      _followFinger();
      return;
    }
    if (_braking && !_platter.motorOn) {
      _braking = false;
      _sendRate(0);
      unawaited(pause());
    } else {
      _sendRate(_platter.rate);
    }
    if (_platter.settled) {
      _sendRate(_platter.rate, force: true); // small last steps fall under the threshold
      _stopPlatter();
    }
  }

  /// Keeps the audio on the finger. A PCM deck follows it directly; on the
  /// others the rate follows the finger's speed and a seek pulls the audio
  /// back when it drifts (or plays forwards while the finger goes backwards,
  /// which those players can't do).
  void _followFinger() {
    final target = _touchTarget!;
    final rate = _platter.rate;
    if (_engine.canReverse(deckId)) {
      _engine.follow(deckId, target, rate); // plays backwards too, no seeks
      return;
    }
    _sendRate(rate);
    final drift = (_engine.positionSync(deckId) - target).abs();
    final backwards = rate <= -AudioEngine.minRate;
    if (drift > _maxDrift || (backwards && drift > const Duration(milliseconds: 10))) {
      if (_seekThrottle == null || _seekThrottle!.elapsedMilliseconds >= 33) {
        _seekThrottle?.reset();
        _seek(target);
      }
    }
  }

  void _sendRate(double rate, {bool force = false}) {
    final sent = _sentRate;
    if (!force && sent != null && (rate - sent).abs() < 0.002) return;
    _sentRate = rate;
    unawaited(_engine.setRate(deckId, rate));
    _beatClock
      ..anchor(_engine.positionSync(deckId))
      ..speed = math.max(rate.abs(), AudioEngine.minRate);
  }

  void _seek(Duration target) {
    unawaited(_engine.seekTo(deckId, target));
    _beatClock.anchor(target);
  }

  Duration _clampPosition(Duration pos) {
    if (pos < Duration.zero) return Duration.zero;
    final dur = state.config.duration;
    return dur > Duration.zero && pos > dur ? dur : pos;
  }

  void _stopPlatter() {
    _platterTimer?.cancel();
    _platterTimer = null;
    _platterClock.stop();
  }

  void _resetPlatter() {
    _stopPlatter();
    _touchTarget = null;
    _braking = false;
    _sentRate = null;
    _platter
      ..release()
      ..nudge = 0
      ..setMotor(false);
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
    _stopPlatter();
    _rollTimer?.cancel();
    _rollStopwatch = null;
    _cancelStreams();
    _completed.close();
    _engine.dispose(deckId);
    return super.close();
  }
}
