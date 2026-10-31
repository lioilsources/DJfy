import '../../core/smart_queue.dart';
import '../../models/party.dart';
import '../../models/track.dart';

enum PartyPhase { idle, starting, live, error }

class PartyState {
  final PartyPhase phase;
  final String name;
  final String? code;
  final String? joinUrl;
  final bool relayConnected;
  final Map<String, PartyGuest> guests;
  final Set<String> banned;
  final List<QueueEntry> queue;

  /// [queue] ranked by [SmartQueue]; recomputed on every change.
  final List<ScoredEntry> ranked;
  final Track? nowPlaying;
  final QueueEntry? nowPlayingEntry;
  final List<Track> history;
  final bool isPlaying;
  final bool autoDj;
  final MoodLock? moodLock;
  final String? message;

  /// The next track is being loaded for a change the host is waiting on.
  final bool loadingNext;

  /// Crossfade in progress; [nowPlaying] flips to `to` halfway through.
  final ({Track from, Track to})? transition;

  const PartyState({
    this.phase = PartyPhase.idle,
    this.name = 'Party',
    this.code,
    this.joinUrl,
    this.relayConnected = false,
    this.guests = const {},
    this.banned = const {},
    this.queue = const [],
    this.ranked = const [],
    this.nowPlaying,
    this.nowPlayingEntry,
    this.history = const [],
    this.isPlaying = false,
    this.autoDj = false,
    this.moodLock,
    this.message,
    this.loadingNext = false,
    this.transition,
  });

  Set<String> get coDjs =>
      {for (final g in guests.values) if (g.isCoDj) g.id};

  PartyState copyWith({
    PartyPhase? phase,
    String? name,
    String? code,
    String? joinUrl,
    bool? relayConnected,
    Map<String, PartyGuest>? guests,
    Set<String>? banned,
    List<QueueEntry>? queue,
    List<ScoredEntry>? ranked,
    Track? nowPlaying,
    bool clearNowPlaying = false,
    QueueEntry? nowPlayingEntry,
    bool clearNowPlayingEntry = false,
    List<Track>? history,
    bool? isPlaying,
    bool? autoDj,
    MoodLock? moodLock,
    bool clearMoodLock = false,
    String? message,
    bool? loadingNext,
    ({Track from, Track to})? transition,
    bool clearTransition = false,
  }) =>
      PartyState(
        phase: phase ?? this.phase,
        name: name ?? this.name,
        code: code ?? this.code,
        joinUrl: joinUrl ?? this.joinUrl,
        relayConnected: relayConnected ?? this.relayConnected,
        guests: guests ?? this.guests,
        banned: banned ?? this.banned,
        queue: queue ?? this.queue,
        ranked: ranked ?? this.ranked,
        nowPlaying: clearNowPlaying ? null : (nowPlaying ?? this.nowPlaying),
        nowPlayingEntry: clearNowPlaying || clearNowPlayingEntry ? null : (nowPlayingEntry ?? this.nowPlayingEntry),
        history: history ?? this.history,
        isPlaying: isPlaying ?? this.isPlaying,
        autoDj: autoDj ?? this.autoDj,
        moodLock: clearMoodLock ? null : (moodLock ?? this.moodLock),
        message: message,
        loadingNext: loadingNext ?? this.loadingNext,
        transition: clearTransition ? null : (transition ?? this.transition),
      );
}
