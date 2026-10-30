import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/smart_queue.dart';
import '../../models/party.dart';
import '../../models/track.dart';
import '../../services/bpm_service.dart';
import '../../services/relay_client.dart';
import '../../services/soundcloud_service.dart';
import 'party_player.dart';
import 'party_state.dart';

typedef PartyPlayerFactory = PartyPlayer Function({
  required Future<Track?> Function() onNeedNext,
  required void Function(Track) onStarted,
  required void Function(Track, Object) onFailed,
});

/// The host phone is the party's single source of truth: queue, votes, bans
/// and playback all live here. The relay only carries messages.
class PartyCubit extends Cubit<PartyState> {
  static const maxQueuedPerGuest = 3;
  static const snapshotQueueLimit = 50;
  static const _knownTracksMax = 500;

  final RelayClient _relay;
  final SoundCloudService _sc;
  final BpmService? _bpm;
  late final PartyPlayer _player;
  final DateTime Function() _now;

  String? _token;
  StreamSubscription<RelayEvent>? _relaySub;
  Timer? _publishDebounce;
  Timer? _heartbeat;
  int _entrySeq = 0;
  QueueEntry? _nextEntry;

  /// Queue ran dry mid-party: the next added track should start on its own.
  bool _starved = false;

  /// Tracks we've shown guests in search results. Proposals may only name
  /// these ids, so guests can't inject arbitrary tracks or URLs.
  final Map<String, Track> _known = {};

  PartyCubit(
    this._relay,
    this._sc, {
    BpmService? bpm,
    required PartyPlayerFactory playerFactory,
    DateTime Function()? now,
  })  : _bpm = bpm,
        _now = now ?? DateTime.now,
        super(const PartyState()) {
    _player = playerFactory(
      onNeedNext: _takeNext,
      onStarted: _onStarted,
      onFailed: (t, e) => _toast('Nejde přehrát „${t.title}“ – přeskakuju'),
    );
  }

  PartyPlayer get player => _player;

  // ── Session lifecycle ──────────────────────────────────────────────────────

  Future<void> start(String name) async {
    emit(state.copyWith(phase: PartyPhase.starting, name: name.trim().isEmpty ? 'Party' : name.trim()));
    try {
      final s = await _relay.createSession();
      _token = s.token;
      emit(state.copyWith(phase: PartyPhase.live, code: s.code, joinUrl: _relay.joinUrl(s.code)));
      _relaySub = _relay
          .hostEvents(s.code, s.token, onConnection: (c) {
            if (!isClosed) emit(state.copyWith(relayConnected: c));
            if (c) _schedulePublish();
          })
          .listen(_onRelayEvent, onError: (Object e) {
            if (!isClosed) emit(state.copyWith(phase: PartyPhase.error, message: e.toString()));
          });
      _heartbeat = Timer.periodic(const Duration(seconds: 10), (_) => _schedulePublish());
      _publish();
    } catch (e) {
      emit(state.copyWith(phase: PartyPhase.error, message: 'Relay nedostupný: $e'));
    }
  }

  Future<void> end() async {
    final code = state.code, token = _token;
    await _teardown();
    if (code != null && token != null) {
      unawaited(_relay.endSession(code, token).catchError((_) {}));
    }
    emit(const PartyState());
  }

  Future<void> _teardown() async {
    _heartbeat?.cancel();
    _publishDebounce?.cancel();
    await _relaySub?.cancel();
    _relaySub = null;
    await _player.stop();
  }

  // ── Guest messages ─────────────────────────────────────────────────────────

  void _onRelayEvent(RelayEvent ev) {
    if (ev.type == 'guest') handleGuestMessage(ev.data);
  }

  @visibleForTesting
  Future<void> handleGuestMessage(Map<String, dynamic> msg) async {
    final guestId = msg['guestId'] as String?;
    if (guestId == null || state.banned.contains(guestId)) return;
    _touchGuest(guestId, msg['name'] as String?);

    switch (msg['type']) {
      case 'search':
        await _guestSearch(guestId, msg);
      case 'propose':
        await _guestPropose(guestId, msg['trackId'] as String?);
      case 'vote':
        _vote(guestId, msg['entryId'] as String?, (msg['value'] as num?)?.toInt() ?? 0);
      case 'veto':
        if (state.guests[guestId]?.isCoDj ?? false) {
          final id = msg['entryId'] as String?;
          if (id != null) veto(id);
        }
    }
    _schedulePublish();
  }

  void _touchGuest(String id, String? rawName) {
    var name = (rawName ?? '').trim();
    if (name.isEmpty) name = 'Host';
    if (name.length > 32) name = name.substring(0, 32);
    final existing = state.guests[id];
    final guest = existing == null
        ? PartyGuest(id: id, name: name, lastSeen: _now())
        : existing.copyWith(name: name, lastSeen: _now());
    emit(state.copyWith(guests: {...state.guests, id: guest}));
  }

  Future<void> _guestSearch(String guestId, Map<String, dynamic> msg) async {
    final q = (msg['q'] as String? ?? '').trim();
    final reqId = msg['reqId'];
    if (q.length < 2 || q.length > 80) return;
    final results = await searchTracks(q);
    _send(guestId, {
      'type': 'searchResults',
      'reqId': reqId,
      'results': [for (final t in results) trackToWire(t)],
    });
  }

  /// Search shared by host UI and guests; remembers results for proposals.
  Future<List<Track>> searchTracks(String q) async {
    final results = await _sc.searchTracks(q, limit: 12);
    for (final t in results) {
      _known.remove(t.id);
      _known[t.id] = t;
    }
    while (_known.length > _knownTracksMax) {
      _known.remove(_known.keys.first);
    }
    return results;
  }

  Future<void> _guestPropose(String guestId, String? trackId) async {
    final track = trackId == null ? null : _known[trackId];
    if (track == null) {
      _send(guestId, _toastMsg('Skladba nenalezena, zkus ji vyhledat znovu'));
      return;
    }
    if (state.nowPlaying?.id == track.id) {
      _send(guestId, _toastMsg('Tohle právě hraje 🎶'));
      return;
    }
    final existing = state.queue.where((e) => e.track.id == track.id).firstOrNull;
    if (existing != null) {
      _vote(guestId, existing.id, 1);
      _send(guestId, _toastMsg('Už je ve frontě – přidán tvůj 👍'));
      return;
    }
    final mine = state.queue.where((e) => e.proposedBy == guestId).length;
    if (mine >= maxQueuedPerGuest) {
      _send(guestId, _toastMsg('Máš ve frontě už $maxQueuedPerGuest skladby, počkej až zahrají'));
      return;
    }
    final name = state.guests[guestId]?.name ?? 'Host';
    final entry = await _addEntry(track, proposedBy: guestId, proposedByName: name);
    final blocked = state.ranked.firstWhere((s) => s.entry.id == entry.id).blocked;
    _send(
      guestId,
      _toastMsg(blocked
          ? 'Přidáno, ale je mimo mood lock (${state.moodLock}) – rozhodne hostitel'
          : 'Přidáno do fronty ✅'),
    );
  }

  void _vote(String guestId, String? entryId, int value) {
    if (entryId == null) return;
    final v = value.clamp(-1, 1);
    _updateQueue([
      for (final e in state.queue)
        if (e.id == entryId)
          e.copyWith(votes: {...e.votes}..removeWhere((k, _) => k == guestId)..addAll({if (v != 0) guestId: v}))
        else
          e,
    ]);
  }

  // ── Host actions ───────────────────────────────────────────────────────────

  Future<void> addTrack(Track track) async {
    if (state.queue.any((e) => e.track.id == track.id)) return;
    await _addEntry(track, proposedByName: 'Hostitel');
  }

  Future<QueueEntry> _addEntry(Track track, {String? proposedBy, required String proposedByName}) async {
    final enriched = await _withBpm(track);
    final entry = QueueEntry(
      id: 'e${++_entrySeq}',
      track: enriched,
      proposedBy: proposedBy,
      proposedByName: proposedByName,
      addedAt: _now(),
    );
    _updateQueue([...state.queue, entry]);
    if (_starved) {
      _starved = false;
      unawaited(_player.skip());
    }
    return entry;
  }

  Future<Track> _withBpm(Track t) async {
    if (t.bpm != null || _bpm == null) return t;
    try {
      final bpm = await _bpm.getBpm(t.artist, t.title);
      return bpm == null ? t : t.copyWith(bpm: bpm);
    } catch (_) {
      return t;
    }
  }

  void veto(String entryId) {
    _updateQueue(state.queue.where((e) => e.id != entryId).toList());
  }

  void pin(String entryId) {
    _updateQueue([
      for (final e in state.queue)
        if (e.id == entryId) (e.pinnedAt == null ? e.copyWith(pinnedAt: _now()) : e.copyWith(clearPin: true)) else e,
    ]);
  }

  Future<void> playNow(String entryId) async {
    final entry = state.queue.where((e) => e.id == entryId).firstOrNull;
    if (entry == null) return;
    _pushHistory();
    _nextEntry = entry;
    _updateQueue(state.queue.where((e) => e.id != entryId).toList());
    await _player.playNow(entry.track);
  }

  Future<void> ban(String guestId) async {
    emit(state.copyWith(banned: {...state.banned, guestId}));
    // Their unplayed proposals leave with them.
    _updateQueue(state.queue.where((e) => e.proposedBy != guestId).toList());
    final code = state.code, token = _token;
    if (code != null && token != null) {
      unawaited(_relay.ban(code, token, guestId).catchError((_) {}));
    }
  }

  void toggleCoDj(String guestId) {
    final g = state.guests[guestId];
    if (g == null) return;
    emit(state.copyWith(guests: {...state.guests, guestId: g.copyWith(isCoDj: !g.isCoDj)}));
    _send(guestId, _toastMsg(g.isCoDj ? 'Už nejsi co-DJ' : 'Hostitel tě povýšil na co-DJ 🎧'));
    _rerank();
  }

  void setMoodLock(MoodLock? lock) {
    emit(lock == null ? state.copyWith(clearMoodLock: true) : state.copyWith(moodLock: lock));
    _rerank();
  }

  void setAutoDj(bool on) {
    _player.autoDj = on;
    emit(state.copyWith(autoDj: on));
    _schedulePublish();
  }

  Future<void> skip() => _player.skip();

  Future<void> togglePlay() async {
    if (_player.current == null) {
      await _player.skip(); // nothing loaded yet: start the top of the queue
    } else {
      await _player.togglePause();
    }
    emit(state.copyWith(isPlaying: _player.isPlaying));
    _schedulePublish();
  }

  // ── Player callbacks ───────────────────────────────────────────────────────

  Future<Track?> _takeNext() async {
    final next = state.ranked.where((s) => !s.blocked).firstOrNull;
    if (next == null) {
      _starved = state.nowPlaying != null;
      if (_starved) emit(state.copyWith(isPlaying: false));
      return null;
    }
    _pushHistory();
    _nextEntry = next.entry;
    _updateQueue(state.queue.where((e) => e.id != next.entry.id).toList());
    return next.entry.track;
  }

  void _pushHistory() {
    final cur = state.nowPlaying;
    if (cur != null) emit(state.copyWith(history: [cur, ...state.history.take(49)]));
  }

  void _onStarted(Track track) {
    final entry = _nextEntry?.track.id == track.id ? _nextEntry : null;
    _nextEntry = null;
    emit(state.copyWith(nowPlaying: track, nowPlayingEntry: entry, isPlaying: true));
    _rerank(); // BPM compatibility is relative to the new current track
  }

  // ── Ranking & publishing ───────────────────────────────────────────────────

  void _updateQueue(List<QueueEntry> queue) {
    emit(state.copyWith(queue: queue));
    _rerank();
  }

  void _rerank() {
    emit(state.copyWith(
      ranked: SmartQueue.rank(
        state.queue,
        current: state.nowPlaying,
        history: state.history,
        moodLock: state.moodLock,
        coDjs: state.coDjs,
        now: _now(),
      ),
    ));
    _schedulePublish();
  }

  void _schedulePublish() {
    _publishDebounce?.cancel();
    _publishDebounce = Timer(const Duration(milliseconds: 250), _publish);
  }

  @visibleForTesting
  Map<String, dynamic> buildSnapshot() {
    final np = state.nowPlaying;
    return {
      'v': 1,
      'name': state.name,
      'code': state.code,
      'updatedAt': _now().millisecondsSinceEpoch,
      'guests': state.guests.length,
      'coDjs': state.coDjs.toList(),
      'isPlaying': _player.isPlaying,
      'autoDj': state.autoDj,
      'nowPlaying': np == null
          ? null
          : {
              ...trackToWire(np),
              'proposedByName': state.nowPlayingEntry?.proposedByName,
              'positionMs': _player.position.inMilliseconds,
              'durationMs': _player.duration.inMilliseconds,
            },
      'moodLock': state.moodLock?.toJson(),
      'rules': {'maxQueuedPerGuest': maxQueuedPerGuest},
      'queue': [
        for (final s in state.ranked.take(snapshotQueueLimit))
          {
            'entryId': s.entry.id,
            'track': trackToWire(s.entry.track),
            'proposedBy': s.entry.proposedBy,
            'proposedByName': s.entry.proposedByName,
            'up': s.entry.upVotes,
            'down': s.entry.downVotes,
            'pinned': s.entry.pinnedAt != null,
            'blocked': s.blocked,
            'reasons': s.reasons,
          },
      ],
    };
  }

  Future<void> _publish() async {
    final code = state.code, token = _token;
    if (code == null || token == null || isClosed) return;
    try {
      await _relay.publishSnapshot(code, token, buildSnapshot());
    } catch (e) {
      debugPrint('[Party] publish failed: $e');
    }
  }

  void _send(String guestId, Map<String, dynamic> data) {
    final code = state.code, token = _token;
    if (code == null || token == null) return;
    unawaited(_relay.sendToGuest(code, token, guestId, data).catchError((_) {}));
  }

  Map<String, dynamic> _toastMsg(String text) => {'type': 'toast', 'text': text};

  void _toast(String text) {
    if (!isClosed) emit(state.copyWith(message: text));
  }

  @override
  Future<void> close() async {
    await _teardown();
    await _player.dispose();
    return super.close();
  }
}
