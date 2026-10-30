import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/smart_queue.dart';
import '../../models/track.dart';
import '../../services/audio_engine.dart';
import '../../services/soundcloud_service.dart';

/// Plays the party queue on two internal engine decks, separate from the
/// manual DJ decks (ids 1–6).
///
/// * Auto-DJ off → gapless: the next track starts when the current one ends.
/// * Auto-DJ on → equal-power crossfade over [crossfade]; when both BPMs are
///   known and within ±[maxPitch], the incoming deck is tempo-matched during
///   the fade and then glides back to its original speed.
class PartyPlayer {
  static const deckA = 201;
  static const deckB = 202;
  static const maxPitch = 0.08;
  static const _tick = Duration(milliseconds: 250);

  final AudioEngine _engine;
  final SoundCloudService _sc;

  /// Asked for the next track when the current one is about to end.
  final Future<Track?> Function() onNeedNext;

  /// Fired when a new track actually becomes "now playing".
  final void Function(Track track) onStarted;

  /// Fired when a track can't be loaded (dead stream, geo-block…).
  final void Function(Track track, Object error) onFailed;

  bool autoDj = false;
  Duration crossfade = const Duration(seconds: 8);

  int _active = deckA;
  Track? _current;
  Timer? _timer;
  bool _transitioning = false;
  bool _playing = false;
  Duration _lastPos = Duration.zero;
  int _stalledTicks = 0;

  final _progress = StreamController<({Duration position, Duration duration})>.broadcast();
  Stream<({Duration position, Duration duration})> get progress => _progress.stream;

  PartyPlayer(
    this._engine,
    this._sc, {
    required this.onNeedNext,
    required this.onStarted,
    required this.onFailed,
  });

  Track? get current => _current;
  bool get isPlaying => _playing;
  int get _idle => _active == deckA ? deckB : deckA;

  Duration get position => _current == null ? Duration.zero : _engine.positionSync(_active);
  Duration get duration => _engine.currentDuration(_active) ?? Duration.zero;

  /// Hard-starts [track] now (host "play now", or first track of the night).
  Future<bool> playNow(Track track) async {
    _transitioning = true;
    try {
      final deck = _idle;
      if (!await _load(deck, track)) return false;
      await _engine.pause(_active);
      await _engine.setCrossfadeGain(deck, 1);
      await _engine.play(deck);
      _swapTo(deck, track);
      return true;
    } finally {
      _transitioning = false;
    }
  }

  Future<void> togglePause() async {
    if (_current == null) return;
    if (_playing) {
      await _engine.pause(_active);
      _playing = false;
    } else {
      await _engine.play(_active);
      _playing = true;
    }
  }

  /// Skip: mix (Auto-DJ) or cut to the next track immediately.
  Future<void> skip() => _advance(force: true);

  Future<bool> _load(int deck, Track track) async {
    try {
      final scId = track.scId;
      if (scId == null) throw StateError('Track has no SoundCloud id');
      final streams = await _sc.streamsFor(scId);
      final url = streams.fallback;
      if (url == null) throw StateError('No stream for "${track.title}"');
      await _engine.setCrossfadeGain(deck, 0);
      await _engine.setSpeed(deck, 1);
      await _engine.loadTrack(deck, url, progressiveUrl: streams.progressive);
      return true;
    } catch (e) {
      debugPrint('[Party] load failed: $e');
      onFailed(track, e);
      return false;
    }
  }

  void _swapTo(int deck, Track track) {
    _active = deck;
    _current = track;
    _playing = true;
    _lastPos = Duration.zero;
    _stalledTicks = 0;
    _timer ??= Timer.periodic(_tick, (_) => _poll());
    onStarted(track);
  }

  void _poll() {
    if (_current == null) return;
    final pos = position;
    final dur = duration;
    _progress.add((position: pos, duration: dur));
    if (_transitioning || !_playing || dur <= Duration.zero) return;

    // SoLoud drops the voice at the natural end, and position stops moving;
    // treat 2 s without progress near the end as "finished".
    _stalledTicks = pos == _lastPos ? _stalledTicks + 1 : 0;
    _lastPos = pos;
    final remaining = dur - pos;
    final lead = autoDj ? crossfade : const Duration(milliseconds: 300);
    final ended = _stalledTicks >= 8 && remaining < const Duration(seconds: 5);
    if (remaining <= lead || ended) _advance();
  }

  Future<void> _advance({bool force = false}) async {
    if (_transitioning) return;
    _transitioning = true;
    try {
      // Up to 3 tries so one dead stream doesn't stop the party.
      for (var attempt = 0; attempt < 3; attempt++) {
        final next = await onNeedNext();
        if (next == null) {
          if (!force) return;
          await _engine.pause(_active);
          _playing = false;
          return;
        }
        final deck = _idle;
        if (!await _load(deck, next)) continue;
        if (autoDj && _current != null) {
          await _mix(from: _active, to: deck, fromTrack: _current!, toTrack: next);
        } else {
          await _engine.pause(_active);
          await _engine.setCrossfadeGain(deck, 1);
          await _engine.play(deck);
          _swapTo(deck, next);
        }
        return;
      }
    } finally {
      _transitioning = false;
    }
  }

  Future<void> _mix({
    required int from,
    required int to,
    required Track fromTrack,
    required Track toTrack,
  }) async {
    final ratio = _tempoRatio(fromTrack.bpm, toTrack.bpm);
    if (ratio != 1) await _engine.setSpeed(to, ratio);
    await _engine.play(to);
    _swapTo(to, toTrack);

    const steps = 32;
    final stepDur = crossfade ~/ steps;
    for (var i = 1; i <= steps; i++) {
      final x = i / steps;
      await _engine.setCrossfadeGain(from, math.cos(x * math.pi / 2));
      await _engine.setCrossfadeGain(to, math.sin(x * math.pi / 2));
      await Future.delayed(stepDur);
    }
    await _engine.pause(from);

    // Glide back to the track's own tempo so pitch isn't shifted all song.
    if (ratio != 1) {
      for (var i = 1; i <= 20; i++) {
        if (_active != to) break;
        await _engine.setSpeed(to, ratio + (1 - ratio) * i / 20);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  /// Speed for the incoming deck so its tempo matches the outgoing one.
  @visibleForTesting
  static double tempoRatio(int? fromBpm, int? toBpm) => _tempoRatio(fromBpm, toBpm);

  static double _tempoRatio(int? fromBpm, int? toBpm) {
    if (fromBpm == null || toBpm == null || toBpm == 0) return 1;
    if (SmartQueue.bpmDistance(fromBpm, toBpm) > maxPitch) return 1;
    // Match in the closest of half/same/double time.
    final candidates = [fromBpm / toBpm, fromBpm / (toBpm * 2), fromBpm * 2 / toBpm];
    final best = candidates.reduce((a, b) => (a - 1).abs() < (b - 1).abs() ? a : b);
    return (best - 1).abs() <= maxPitch ? best : 1;
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _current = null;
    _playing = false;
    _engine.dispose(deckA);
    _engine.dispose(deckB);
  }

  Future<void> dispose() async {
    await stop();
    await _progress.close();
  }
}
