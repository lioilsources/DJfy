import 'dart:math' as math;

import '../models/party.dart';
import '../models/track.dart';

/// An entry with its computed score and the human-readable reasons behind
/// it, so the host (and guests) can see why a track sits where it does.
class ScoredEntry {
  final QueueEntry entry;
  final double score;
  final List<String> reasons;

  /// Outside the mood lock — kept in the list but never auto-played.
  final bool blocked;

  const ScoredEntry(this.entry, this.score, this.reasons, {this.blocked = false});
}

/// Smart queue ordering:
///
///   score = votes × freshness × BPM compatibility × mood lock
///
/// * **votes** — net votes (co-DJ votes weigh [coDjWeight]×); heavily
///   downvoted tracks sink but never reach zero, so the host can still pick them.
/// * **freshness** — waiting time slowly lifts a track (no starvation); an
///   artist heard in the last [artistCooldown] tracks is pushed down.
/// * **BPM** — closeness to the current track's tempo, half/double-time aware.
/// * **mood lock** — outside the window ⇒ blocked; unknown BPM ⇒ penalized.
///
/// Pinned entries (host "play next") always come first, in pin order.
class SmartQueue {
  static const coDjWeight = 3;
  static const artistCooldown = 3;

  static List<ScoredEntry> rank(
    List<QueueEntry> entries, {
    Track? current,
    List<Track> history = const [],
    MoodLock? moodLock,
    Set<String> coDjs = const {},
    required DateTime now,
  }) {
    final pinned = entries.where((e) => e.pinnedAt != null).toList()
      ..sort((a, b) => a.pinnedAt!.compareTo(b.pinnedAt!));
    final rest = entries.where((e) => e.pinnedAt == null).map((e) => score(
          e,
          current: current,
          history: history,
          moodLock: moodLock,
          coDjs: coDjs,
          now: now,
        ));

    final sorted = rest.toList()
      ..sort((a, b) {
        if (a.blocked != b.blocked) return a.blocked ? 1 : -1;
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : a.entry.addedAt.compareTo(b.entry.addedAt);
      });

    return [
      for (final e in pinned) ScoredEntry(e, double.infinity, const ['📌 host: hraje příští']),
      ...sorted,
    ];
  }

  static ScoredEntry score(
    QueueEntry e, {
    Track? current,
    List<Track> history = const [],
    MoodLock? moodLock,
    Set<String> coDjs = const {},
    required DateTime now,
  }) {
    final reasons = <String>[];

    // Votes
    var net = 0;
    e.votes.forEach((guest, v) => net += v * (coDjs.contains(guest) ? coDjWeight : 1));
    final votes = math.max(0.1, 1 + 0.4 * net);
    if (net != 0) reasons.add('${net > 0 ? '+' : ''}$net hlasů');

    // Freshness: +50 % after an hour of waiting, artist cooldown.
    final waitMin = now.difference(e.addedAt).inSeconds / 60;
    var freshness = 1 + math.min(waitMin, 60) / 60 * 0.5;
    if (waitMin >= 15) reasons.add('čeká ${waitMin.round()} min');
    final recent = [?current, ...history.take(artistCooldown - 1)];
    if (recent.any((t) => _sameArtist(t.artist, e.track.artist))) {
      freshness *= 0.5;
      reasons.add('${e.track.artist} hrál nedávno');
    }

    // BPM compatibility
    final bpm = e.track.bpm;
    final curBpm = current?.bpm;
    var compat = 1.0;
    if (bpm != null && curBpm != null) {
      final diff = bpmDistance(curBpm, bpm);
      compat = diff <= 0.03 ? 1.0 : math.max(0.6, 1 - (diff - 0.03) / 0.12 * 0.4);
      reasons.add(diff <= 0.03 ? 'sedí BPM ($bpm)' : '$bpm BPM vs $curBpm');
    } else if (curBpm != null) {
      compat = 0.85;
    }

    // Mood lock
    var mood = 1.0;
    var blocked = false;
    if (moodLock != null) {
      if (bpm == null) {
        mood = 0.5;
        reasons.add('BPM neznámé (mood lock)');
      } else if (!moodLock.contains(bpm)) {
        mood = 0;
        blocked = true;
        reasons.add('mimo mood lock $moodLock');
      }
    }

    return ScoredEntry(e, votes * freshness * compat * mood, reasons, blocked: blocked);
  }

  /// Relative tempo distance, treating half/double time as compatible
  /// (a 70 BPM track mixes into 140).
  static double bpmDistance(int a, int b) {
    double rel(double x, double y) => (x - y).abs() / y;
    return [rel(b.toDouble(), a.toDouble()), rel(b * 2.0, a.toDouble()), rel(b / 2.0, a.toDouble())]
        .reduce(math.min);
  }

  static bool _sameArtist(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
