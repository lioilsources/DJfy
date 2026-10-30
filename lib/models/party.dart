import 'track.dart';

/// A guest connected through the relay. Identity is a random id the guest's
/// browser generated — no accounts.
class PartyGuest {
  final String id;
  final String name;
  final bool isCoDj;
  final DateTime lastSeen;

  const PartyGuest({
    required this.id,
    required this.name,
    this.isCoDj = false,
    required this.lastSeen,
  });

  PartyGuest copyWith({String? name, bool? isCoDj, DateTime? lastSeen}) =>
      PartyGuest(
        id: id,
        name: name ?? this.name,
        isCoDj: isCoDj ?? this.isCoDj,
        lastSeen: lastSeen ?? this.lastSeen,
      );
}

/// One track waiting in the party queue.
class QueueEntry {
  final String id;
  final Track track;

  /// Guest id of the proposer; null when the host added it.
  final String? proposedBy;
  final String proposedByName;
  final DateTime addedAt;

  /// guestId → +1 / -1. One vote per guest per entry; re-voting overwrites.
  final Map<String, int> votes;

  /// Host "play next": pinned entries skip scoring and play in pin order.
  final DateTime? pinnedAt;

  const QueueEntry({
    required this.id,
    required this.track,
    this.proposedBy,
    required this.proposedByName,
    required this.addedAt,
    this.votes = const {},
    this.pinnedAt,
  });

  int get upVotes => votes.values.where((v) => v > 0).length;
  int get downVotes => votes.values.where((v) => v < 0).length;

  QueueEntry copyWith({
    Map<String, int>? votes,
    DateTime? pinnedAt,
    bool clearPin = false,
  }) =>
      QueueEntry(
        id: id,
        track: track,
        proposedBy: proposedBy,
        proposedByName: proposedByName,
        addedAt: addedAt,
        votes: votes ?? this.votes,
        pinnedAt: clearPin ? null : (pinnedAt ?? this.pinnedAt),
      );
}

/// Host constraint: only tracks inside this BPM window are eligible.
class MoodLock {
  final int minBpm;
  final int maxBpm;

  const MoodLock(this.minBpm, this.maxBpm);

  bool contains(int bpm) => bpm >= minBpm && bpm <= maxBpm;

  Map<String, dynamic> toJson() => {'minBpm': minBpm, 'maxBpm': maxBpm};

  @override
  String toString() => '$minBpm–$maxBpm BPM';
}

/// Wire format for tracks sent to guests. Never includes stream URLs — guests
/// only ever reference tracks by id, so they can't inject arbitrary audio.
Map<String, dynamic> trackToWire(Track t) => {
      'id': t.id,
      'title': t.title,
      'artist': t.artist,
      if (t.artworkUrl != null) 'artworkUrl': t.artworkUrl,
      if (t.bpm != null) 'bpm': t.bpm,
      'source': 'soundcloud',
    };
