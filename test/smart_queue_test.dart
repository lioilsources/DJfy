import 'package:dj_deckify/core/smart_queue.dart';
import 'package:dj_deckify/features/party/party_player.dart';
import 'package:dj_deckify/models/party.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:flutter_test/flutter_test.dart';

final now = DateTime(2026, 10, 30, 22);

QueueEntry entry(String id, {int? bpm, String artist = 'A', Map<String, int> votes = const {}, int ageMin = 0, DateTime? pinnedAt}) =>
    QueueEntry(
      id: id,
      track: Track(id: 't$id', title: id, artist: artist, bpm: bpm),
      proposedByName: 'x',
      addedAt: now.subtract(Duration(minutes: ageMin)),
      votes: votes,
      pinnedAt: pinnedAt,
    );

List<String> order(List<ScoredEntry> r) => r.map((s) => s.entry.id).toList();

void main() {
  group('SmartQueue.rank', () {
    test('votes beat neutral, downvotes sink', () {
      final r = SmartQueue.rank([
        entry('meh'),
        entry('loved', votes: {'g1': 1, 'g2': 1}),
        entry('hated', votes: {'g1': -1, 'g2': -1}),
      ], now: now);
      expect(order(r), ['loved', 'meh', 'hated']);
      expect(r.last.score, greaterThan(0), reason: 'never fully zero');
    });

    test('co-DJ vote outweighs two guests', () {
      final r = SmartQueue.rank([
        entry('crowd', votes: {'g1': 1, 'g2': 1}),
        entry('dj', votes: {'dj': 1}),
      ], coDjs: {'dj'}, now: now);
      expect(order(r).first, 'dj');
    });

    test('pinned entries come first in pin order', () {
      final r = SmartQueue.rank([
        entry('top', votes: {'g1': 1, 'g2': 1, 'g3': 1}),
        entry('pin2', pinnedAt: now),
        entry('pin1', pinnedAt: now.subtract(const Duration(minutes: 1))),
      ], now: now);
      expect(order(r), ['pin1', 'pin2', 'top']);
    });

    test('BPM close to current track ranks higher, half-time counts', () {
      const current = Track(id: 'c', title: 'c', artist: 'Z', bpm: 128);
      final r = SmartQueue.rank([
        entry('far', bpm: 90),
        entry('half', bpm: 64),
        entry('near', bpm: 127),
      ], current: current, now: now);
      expect(order(r).last, 'far');
      expect(SmartQueue.bpmDistance(128, 64), 0);
    });

    test('mood lock blocks out-of-range tracks and puts them last', () {
      final r = SmartQueue.rank([
        entry('slow', bpm: 90, votes: {'g1': 1, 'g2': 1, 'g3': 1}),
        entry('ok', bpm: 124),
      ], moodLock: const MoodLock(120, 128), now: now);
      expect(order(r), ['ok', 'slow']);
      expect(r.last.blocked, isTrue);
    });

    test('artist heard recently is pushed down', () {
      const current = Track(id: 'c', title: 'c', artist: 'Daft Punk');
      final r = SmartQueue.rank([
        entry('again', artist: 'daft punk'),
        entry('new', artist: 'Justice'),
      ], current: current, now: now);
      expect(order(r), ['new', 'again']);
    });

    test('waiting lifts a track so nothing starves', () {
      final r = SmartQueue.rank([
        entry('fresh'),
        entry('waiting', ageMin: 45),
      ], now: now);
      expect(order(r), ['waiting', 'fresh']);
      expect(r.first.reasons, contains('čeká 45 min'));
    });
  });

  group('PartyPlayer.tempoRatio', () {
    test('matches within pitch range', () {
      expect(PartyPlayer.tempoRatio(128, 124), closeTo(128 / 124, 1e-9));
    });
    test('no change when too far or unknown', () {
      expect(PartyPlayer.tempoRatio(128, 100), 1);
      expect(PartyPlayer.tempoRatio(null, 120), 1);
    });
    test('half-time incoming plays at its own speed', () {
      expect(PartyPlayer.tempoRatio(128, 64), closeTo(1, 1e-9));
    });
  });
}
