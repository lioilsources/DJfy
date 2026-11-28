import 'package:dj_deckify/features/deck/deck_cubit.dart';
import 'package:dj_deckify/features/deck/deck_registry.dart';
import 'package:dj_deckify/features/deck/deck_state.dart';
import 'package:dj_deckify/features/mixer/mixer_cubit.dart';
import 'package:dj_deckify/features/playlist/track_list_item.dart';
import 'package:dj_deckify/models/deck_config.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_audio_engine.dart';

const _track = Track(
  id: 'sc:1',
  title: 'One',
  artist: 'A',
  scId: 1,
  soundcloudStreamUrl: 'https://cdn.example/playlist/one.128.mp3/playlist.m3u8',
);

void main() {
  late FakeAudioEngine engine;
  late MixerCubit mixer;
  late DeckRegistry decks;

  setUp(() {
    engine = FakeAudioEngine();
    mixer = MixerCubit(engine);
    decks = DeckRegistry((id) => DeckCubit(id, engine), mixer)..ensureFirst(const [1, 2]);
  });
  tearDown(() async {
    await decks.close();
    await mixer.close();
  });

  Future<void> pump(WidgetTester tester, Track track) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(value: decks, child: TrackListItem(track: track)),
        ),
      ));

  testWidgets('one tap on a deck button loads the track there', (tester) async {
    await pump(tester, _track);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(decks.deck(2).state.config.track, _track);
    expect(decks.deck(1).state.config.track, isNull);
  });

  testWidgets('a deck the party drives takes no tracks', (tester) async {
    decks.deck(1).setPartyRole(PartyDeckRole.live);
    await pump(tester, _track);
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(decks.deck(1).state.config.track, isNull);
  });

  testWidgets('a track that is not on SoundCloud can go nowhere', (tester) async {
    await pump(tester, const Track(id: 'fm:1', title: 'Gone', artist: 'B'));
    expect(find.textContaining('není na SoundCloudu'), findsOneWidget);
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(decks.deck(1).state.config.track, isNull);
  });
}
