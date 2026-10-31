import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/smart_queue.dart';
import '../../models/deck_config.dart';
import '../../models/track.dart';
import '../deck/deck_cubit.dart';
import '../deck/deck_registry.dart';
import '../deck/deck_state.dart';
import '../mixer/mixer_cubit.dart';

/// What the player asks of, and reports to, the party.
class PartyPlayerEvents {
  /// Best track to play next, ignoring [excludeId]. Must not change the queue:
  /// a track only leaves it through [onStarted], [onFailed] or [onSkipped].
  final Track? Function(String? excludeId) peekNext;

  /// [track] is now what the room hears.
  final void Function(Track track) onStarted;

  /// [track] can't be loaded (dead stream, geo-block…).
  final void Function(Track track, Object error) onFailed;

  /// The host skipped [track] while it was still loading.
  final void Function(Track track) onSkipped;

  /// The host asked for the next track but there is none.
  final void Function() onQueueEmpty;

  /// The last track played out and nothing follows.
  final void Function() onEnded;

  final void Function(bool playing) onPlayState;
  final void Function(bool loading) onLoading;

  /// A crossfade from [from] to [to] began; both null when it finished.
  final void Function(Track? from, Track? to) onTransition;

  const PartyPlayerEvents({
    required this.peekNext,
    required this.onStarted,
    required this.onFailed,
    required this.onSkipped,
    required this.onQueueEmpty,
    required this.onEnded,
    required this.onPlayState,
    required this.onLoading,
    required this.onTransition,
  });
}

enum _Kind { user, trackEnded, autoMix }

class _Fade {
  final int from, to;
  final Track track;
  final double tempoRatio;
  final bool long;
  bool committed = false;
  bool hurried = false;

  _Fade(this.from, this.to, this.track, this.tempoRatio, {required this.long});
}

/// Plays the party queue on decks 1 and 2, which take turns being on air, so
/// the vinyl, the seek bar and the crossfader always show the real audio.
///
/// Every change of track runs through [_transition]. A newer one cancels the
/// one in progress (a user action is never dropped), and the queue only
/// changes once a track is actually on air.
///
/// * Next and "play now" cut over [cutFade]; a second Next during a load
///   discards that track, and Next during a crossfade finishes it quickly.
/// * Auto-DJ off → the next track starts when the current one ends. It is
///   preloaded [preloadLead] ahead, so there is hardly a gap.
/// * Auto-DJ on → equal-power crossfade over [crossfade], "now playing" flips
///   halfway through. When both BPMs are known and within ±[maxPitch], the
///   incoming deck is tempo-matched and then glides back to its own speed.
class PartyPlayer {
  static const deckA = 1;
  static const deckB = 2;
  static const maxPitch = 0.08;

  /// A stream that isn't playable by then is skipped (dead link, geo-block…).
  static const loadTimeout = Duration(seconds: 15);
  static const preloadLead = Duration(seconds: 45);
  static const _fadeStep = Duration(milliseconds: 50);

  final DeckRegistry _decks;
  final MixerCubit _mixer;
  final PartyPlayerEvents _events;

  bool autoDj = false;
  Duration crossfade = const Duration(seconds: 8);
  Duration cutFade = const Duration(seconds: 1);

  bool _prepared = false;
  final List<StreamSubscription<void>> _subs = [];

  int _active = deckA;
  Track? _current;
  bool _activeEnded = false;
  bool _lastPlaying = false;
  bool _reportedLoading = false;

  /// Bumped by each transition and by [stop]; older async work bails out.
  int _gen = 0;
  bool _transitioning = false;
  Track? _loading;
  bool _hostIsWaiting = false;
  _Fade? _fade;

  /// What's on, or being loaded onto, the idle deck.
  Track? _idleTrack;
  Future<bool>? _idleLoad;
  int _loadSeq = 0;

  PartyPlayer(this._decks, this._mixer, this._events);

  Track? get current => _current;
  bool get isPlaying => _current != null && liveDeck.state.isPlaying;
  DeckCubit get liveDeck => _deck(_active);
  Duration get position => _current == null ? Duration.zero : liveDeck.state.config.position;
  Duration get duration => _current == null ? Duration.zero : liveDeck.state.config.duration;

  int get _idle => _active == deckA ? deckB : deckA;

  /// Where the next track goes; with nothing on air, that's the live deck.
  int get _target => _current == null ? _active : _idle;
  DeckCubit _deck(int id) => _decks.deck(id);
  double _side(int deck) => deck == deckA ? 0 : 1;

  /// Takes over decks 1/2: stops whatever they were playing.
  Future<void> prepare() async {
    _decks.ensureFirst(const [deckA, deckB]);
    await Future.wait([_deck(deckA).eject(), _deck(deckB).eject()]);
    _active = deckA;
    _mixer.setCrossfade(_side(deckA));
    _prepared = true;
    _updateRoles();
    for (final id in const [deckA, deckB]) {
      _subs
        ..add(_deck(id).stream.listen((_) => _onDeckChanged(id)))
        ..add(_deck(id).completed.listen((_) => _onCompleted(id)));
    }
  }

  void _updateRoles() {
    _deck(_active).setPartyRole(PartyDeckRole.live);
    _deck(_idle).setPartyRole(PartyDeckRole.next);
    _decks.setLive(_active);
  }

  // ── Host actions ───────────────────────────────────────────────────────────

  /// Hard-starts [track] now (host "play now").
  Future<void> playNow(Track track) => _transition(_Kind.user, track: track);

  Future<void> togglePause() async {
    if (_current == null) return;
    if (_fade != null) {
      _gen++;
      _settleFade();
      _transitioning = false;
    }
    await (isPlaying ? liveDeck.pause() : liveDeck.play());
  }

  /// Next: cut to the top of the queue, whatever is going on right now.
  Future<void> skip() async {
    final fade = _fade;
    if (fade != null && fade.long && !fade.hurried) {
      fade.hurried = true;
      return;
    }
    final loading = _loading;
    if (loading != null && _hostIsWaiting) {
      if (_events.peekNext(loading.id) == null) return;
      _events.onSkipped(loading);
    }
    await _transition(_Kind.user);
  }

  // ── Deck events ────────────────────────────────────────────────────────────

  void _onDeckChanged(int id) {
    if (id != _active) return;
    _reportPlaying();
    if (_current == null || _transitioning || !isPlaying) return;

    final config = liveDeck.state.config;
    if (config.duration <= Duration.zero) return;
    final remaining = config.duration - config.position;
    if (remaining <= preloadLead) _preload();
    if (autoDj && remaining <= crossfade && _events.peekNext(null) != null) {
      unawaited(_transition(_Kind.autoMix));
    }
  }

  void _onCompleted(int id) {
    if (id != _active || _current == null) return;
    _activeEnded = true;
    if (!_transitioning) unawaited(_transition(_Kind.trackEnded));
  }

  void _reportPlaying() {
    final playing = isPlaying;
    if (playing == _lastPlaying) return;
    _lastPlaying = playing;
    _events.onPlayState(playing);
  }

  void _reportLoading() {
    final loading = _loading != null;
    if (loading == _reportedLoading) return;
    _reportedLoading = loading;
    _events.onLoading(loading);
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  /// Keeps the idle deck on the current top of the queue; votes can change it.
  void _preload() {
    final next = _events.peekNext(null);
    if (next != null) unawaited(_loadIdle(next));
  }

  Future<bool> _loadIdle(Track track) {
    if (_idleTrack?.id == track.id) return _idleLoad!;
    _idleTrack = track;
    return _idleLoad = _load(_deck(_target), track, ++_loadSeq);
  }

  Future<bool> _load(DeckCubit deck, Track track, int seq) async {
    final sw = Stopwatch()..start();
    try {
      await deck.loadTrack(track, streaming: true).timeout(loadTimeout);
      if (seq != _loadSeq) return false;
      await deck.setSpeed(1);
      debugPrint('[Party] "${track.title}" ready on deck ${deck.deckId} in ${sw.elapsedMilliseconds} ms');
      return seq == _loadSeq;
    } catch (e) {
      if (seq != _loadSeq) return false;
      debugPrint('[Party] load failed after ${sw.elapsedMilliseconds} ms: $e');
      _idleTrack = null;
      _idleLoad = null;
      unawaited(deck.eject());
      _events.onFailed(track, e);
      return false;
    }
  }

  // ── Transitions ────────────────────────────────────────────────────────────

  Future<void> _transition(_Kind kind, {Track? track}) async {
    final gen = ++_gen;
    _settleFade();
    _transitioning = true;
    _hostIsWaiting = kind == _Kind.user;
    try {
      // Up to 3 tries so one dead stream doesn't stop the party.
      for (var attempt = 0; attempt < 3; attempt++) {
        final next = track ?? _events.peekNext(null);
        if (next == null) break;
        _loading = next;
        _reportLoading();
        final loaded = await _loadIdle(next);
        if (gen != _gen) return;
        if (!loaded) {
          if (track != null) break;
          continue;
        }
        _loading = null;
        _reportLoading();
        await _start(next, kind, gen);
        return;
      }
      if (gen != _gen) return;
      if (_activeEnded) {
        _ended();
      } else if (kind == _Kind.user) {
        _events.onQueueEmpty();
      }
    } finally {
      if (gen == _gen) {
        _transitioning = false;
        _loading = null;
        _reportLoading();
      }
    }
  }

  Future<void> _start(Track next, _Kind kind, int gen) async {
    final from = _active, to = _target;
    final fromTrack = _current;
    if (fromTrack == null || !isPlaying || _activeEnded) {
      // Nothing audible to fade from.
      _mixer.setCrossfade(_side(to));
      await _deck(to).play();
      if (gen != _gen) return;
      _commit(to, next);
      if (fromTrack != null) unawaited(_deck(from).eject());
      return;
    }

    final mix = kind == _Kind.autoMix;
    final ratio = mix ? _tempoRatio(fromTrack.bpm, next.bpm) : 1.0;
    if (ratio != 1) await _deck(to).setSpeed(ratio);
    if (gen != _gen) return;
    await _deck(to).play();
    if (gen != _gen) return;

    final fade = _fade = _Fade(from, to, next, ratio, long: mix);
    _events.onTransition(fromTrack, next);
    if (!mix) _commitFade(fade);

    final start = _mixer.state.crossfade, end = _side(to);
    final stepMs = _fadeStep.inMilliseconds;
    var rate = stepMs / math.max(1, (mix ? crossfade : cutFade).inMilliseconds);
    var hurried = false;
    var progress = 0.0;
    while (progress < 1) {
      await Future.delayed(_fadeStep);
      if (gen != _gen) return;
      if (fade.hurried && !hurried) {
        hurried = true;
        rate = math.max(rate, (1 - progress) * stepMs / cutFade.inMilliseconds);
      }
      progress = math.min(1, progress + rate);
      _mixer.setCrossfade(start + (end - start) * progress);
      if (progress >= 0.5) _commitFade(fade);
    }
    _settleFade();
  }

  void _commitFade(_Fade fade) {
    if (fade.committed) return;
    fade.committed = true;
    _commit(fade.to, fade.track);
  }

  void _commit(int deck, Track track) {
    _active = deck;
    _current = track;
    _activeEnded = false;
    _idleTrack = null;
    _idleLoad = null;
    _updateRoles();
    _events.onStarted(track);
    _reportPlaying();
  }

  /// Ends a crossfade right now: the incoming deck stays, the old one empties.
  void _settleFade() {
    final fade = _fade;
    if (fade == null) return;
    _fade = null;
    _mixer.setCrossfade(_side(fade.to));
    _commitFade(fade);
    unawaited(_deck(fade.from).eject());
    _events.onTransition(null, null);
    if (fade.tempoRatio != 1) unawaited(_glide(fade.to, fade.tempoRatio));
  }

  /// Back to the track's own tempo so pitch isn't shifted all song.
  Future<void> _glide(int deck, double ratio) async {
    for (var i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_active != deck || _current == null) return;
      await _deck(deck).setSpeed(ratio + (1 - ratio) * i / 20);
    }
  }

  void _ended() {
    final deck = liveDeck, idle = _deck(_idle);
    _current = null;
    _activeEnded = false;
    _idleTrack = null;
    _idleLoad = null;
    _loadSeq++;
    unawaited(deck.eject());
    unawaited(idle.eject());
    _reportPlaying();
    _events.onEnded();
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

  /// Ends the party: silence, and the decks are free again. The live deck keeps
  /// its track, so the host can carry on by hand.
  Future<void> stop() async {
    _gen++;
    _loadSeq++;
    _transitioning = false;
    _loading = null;
    _reportedLoading = false;
    _lastPlaying = false;
    _fade = null;
    _current = null;
    _activeEnded = false;
    _idleTrack = null;
    _idleLoad = null;
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    if (!_prepared || _decks.isClosed) return;
    _prepared = false;
    _decks.setLive(null);
    for (final id in const [deckA, deckB]) {
      _deck(id).setPartyRole(null);
    }
    await _deck(_active).pause();
    await _deck(_idle).eject();
    _mixer.recenter();
  }

  Future<void> dispose() => stop();
}
