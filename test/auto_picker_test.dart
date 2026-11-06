import 'dart:math';

import 'package:dj_deckify/features/party/auto_picker.dart';
import 'package:dj_deckify/models/party.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:dj_deckify/services/lastfm_service.dart';
import 'package:dj_deckify/services/soundcloud_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _LastFm extends Mock implements LastFmService {}

class _Sc extends Mock implements SoundCloudService {}

const current = Track(id: 'sc:1', title: 'Daft Punk - Around (Original Mix)', artist: 'someuploader', scId: 1, bpm: 124);

Track suggestion(String artist, String title, [double similarity = 1]) =>
    Track(id: '$artist-$title', title: title, artist: artist, similarity: similarity);

Track sc(int id, String title, {String artist = 'label', int? bpm}) =>
    Track(id: 'sc:$id', title: title, artist: artist, scId: id, bpm: bpm);

void main() {
  late _LastFm lastFm;
  late _Sc soundCloud;
  late AutoPicker picker;

  Future<Track> sameTrack(Track t) async => t;
  Future<Track?> pick({List<Track> recent = const [current], Set<String> avoid = const {}, MoodLock? moodLock}) =>
      picker.pick(recent: recent, avoid: avoid, moodLock: moodLock, withBpm: sameTrack);
  void similarIs(List<Track> tracks) => when(() => lastFm.getSimilarTracks(any(), any(), limit: any(named: 'limit')))
      .thenAnswer((_) async => tracks);
  void soundCloudHas(String query, List<Track> tracks) =>
      when(() => soundCloud.searchTracks(query, limit: any(named: 'limit'))).thenAnswer((_) async => tracks);

  setUp(() {
    lastFm = _LastFm();
    soundCloud = _Sc();
    picker = AutoPicker(lastFm, soundCloud, random: Random(1));
    similarIs([]);
    when(() => lastFm.getSimilarArtistTracks(any(), limit: any(named: 'limit'))).thenAnswer((_) async => []);
    when(() => soundCloud.searchTracks(any(), limit: any(named: 'limit'))).thenAnswer((_) async => []);
  });

  test('asks Last.fm with the real artist and title, not the uploader', () async {
    await pick();
    verify(() => lastFm.getSimilarTracks('Daft Punk', 'Around', limit: any(named: 'limit'))).called(1);
  });

  test('picks a suggestion found on SoundCloud', () async {
    similarIs([suggestion('Justice', 'Dance')]);
    final hit = sc(2, 'Justice - Dance');
    soundCloudHas('Justice Dance', [hit]);
    expect(await pick(), hit);
  });

  test('skips remixes, covers and namesakes of the suggestion', () async {
    similarIs([suggestion('Justice', 'Dance')]);
    final original = sc(4, 'Dance', artist: 'Justice');
    soundCloudHas('Justice Dance', [
      sc(2, 'Justice - Dance (Bob Remix)'),
      sc(3, 'Dance', artist: 'Somebody Else'),
      original,
    ]);
    expect(await pick(), original);
  });

  test('keeps a remix Last.fm actually suggested', () async {
    similarIs([suggestion('Justice', 'Dance (Bob Remix)')]);
    final hit = sc(2, 'Justice - Dance (Bob Remix)');
    soundCloudHas('Justice Dance (Bob Remix)', [hit]);
    expect(await pick(), hit);
  });

  test('prefers the closest tempo and respects the mood lock', () async {
    similarIs([suggestion('A', 'One'), suggestion('B', 'Two'), suggestion('C', 'Three')]);
    final near = sc(2, 'A - One', bpm: 125), far = sc(3, 'B - Two', bpm: 160), unknown = sc(4, 'C - Three');
    soundCloudHas('A One', [near]);
    soundCloudHas('B Two', [far]);
    soundCloudHas('C Three', [unknown]);
    expect(await pick(), near);
    expect(await pick(moodLock: const MoodLock(150, 170)), far);
  });

  test('never repeats a played or avoided track, nor the current artist', () async {
    similarIs([suggestion('Daft Punk', 'Other'), suggestion('A', 'Around'), suggestion('B', 'Two')]);
    final avoided = sc(2, 'B - Two');
    soundCloudHas('B Two', [avoided]);
    soundCloudHas('Daft Punk', []);
    expect(await pick(avoid: {'sc:2'}), isNull);
  });

  test('falls back to the artist top tracks when nothing is similar', () async {
    when(() => lastFm.getSimilarArtistTracks('Daft Punk', limit: any(named: 'limit')))
        .thenAnswer((_) async => [suggestion('Daft Punk', 'Aerodynamic')]);
    final hit = sc(2, 'Daft Punk - Aerodynamic');
    soundCloudHas('Daft Punk Aerodynamic', [hit]);
    expect(await pick(), hit);
  });

  test('survives Last.fm being down by searching SoundCloud for the artist', () async {
    when(() => lastFm.getSimilarTracks(any(), any(), limit: any(named: 'limit'))).thenThrow(Exception('offline'));
    when(() => lastFm.getSimilarArtistTracks(any(), limit: any(named: 'limit'))).thenThrow(Exception('offline'));
    final hit = sc(2, 'Daft Punk - Veridis Quo');
    soundCloudHas('Daft Punk', [hit]);
    expect(await pick(), hit);
  });

  test('replays something old as a last resort, but nothing recent', () async {
    final played = [for (var i = 1; i <= 6; i++) sc(i, 'Song $i')];
    expect(await pick(recent: played), played.last);
    expect(await pick(recent: played.take(5).toList()), isNull);
  });

  test('gives up on an empty party', () async {
    expect(await pick(recent: const []), isNull);
  });
}
