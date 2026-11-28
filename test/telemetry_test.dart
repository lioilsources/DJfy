// The checks from ol1n_telemetry's test kit (README "Testovací sada"):
// dictionary ↔ doc, no free text, version constant ↔ pubspec, no key → no
// network, off → nothing, literal event names.

import 'dart:io';

import 'package:dj_deckify/features/playlist/playlist_cubit.dart';
import 'package:dj_deckify/services/bpm_service.dart';
import 'package:dj_deckify/services/lastfm_service.dart';
import 'package:dj_deckify/services/soundcloud_service.dart';
import 'package:dj_deckify/telemetry/telemetry_dictionary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';
import 'package:ol1n_telemetry/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const common = {'mode': 'solo'};

  test('docs/telemetry.md lists exactly the dictionary', () {
    expect(telemetryDocProblems(djfyDictionary, File('docs/telemetry.md').readAsStringSync()), isEmpty);
  });

  test('no property is free text', () {
    expect(telemetryDictionaryProblems(djfyDictionary), isEmpty);
  });

  test('app version matches pubspec.yaml', () {
    expect(telemetryVersionProblems(kAppVersion, File('pubspec.yaml').readAsStringSync()), isEmpty);
  });

  test('the code sends only dictionary events, and every one of them', () {
    expect(telemetryTrackCallProblems(djfyDictionary), isEmpty);
  });

  test('no key, no network', () async {
    expect(await telemetryNoKeyProblems(djfyDictionary, common: () => common), isEmpty);
  }, skip: const bool.fromEnvironment('TELEMETRY_DEBUG'));

  test('off means nothing', () async {
    expect(await telemetryOffProblems(djfyDictionary, common: () => common), isEmpty);
  });

  group('hooks', () {
    tearDown(Telemetry.resetForTest);

    test('a search reports the shape of the query, never its text', () async {
      await Telemetry.init(
        app: kTelemetryApp,
        appVersion: kAppVersion,
        dictionary: djfyDictionary,
        store: MemoryTelemetryStore(),
        lang: () => 'cs',
        common: () => {'mode': telemetryMode},
        sink: FakeSink(),
        startTimer: false,
        observeLifecycle: false,
      );
      final lastFm = _MockLastFm();
      when(() => lastFm.getSimilarArtistTracks(any())).thenAnswer((_) async => []);
      final cubit = PlaylistCubit(lastFm, _MockBpm(), _MockSoundCloud());

      await cubit.search('Secret Band');

      final events = Telemetry.debugQueue;
      final start = events.firstWhere((e) => e.name == 'playlist_search_start');
      final end = events.firstWhere((e) => e.name == 'playlist_search_end');
      expect(start.props['query_kind'], 'artist');
      expect(end.props['result'], 'empty');
      expect(events.where((e) => e.name == 'error_shown').single.props['kind'], 'no_results');
      for (final e in events) {
        expect(e.props.values.whereType<String>().where((v) => v.toLowerCase().contains('secret')), isEmpty);
      }
      await cubit.close();
    });
  });
}

class _MockLastFm extends Mock implements LastFmService {}

class _MockBpm extends Mock implements BpmService {}

class _MockSoundCloud extends Mock implements SoundCloudService {}
