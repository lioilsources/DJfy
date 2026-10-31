import 'package:bloc_test/bloc_test.dart';
import 'package:dj_deckify/features/deck/deck_cubit.dart';
import 'package:dj_deckify/features/deck/deck_registry.dart';
import 'package:dj_deckify/features/deck/deck_screen.dart';
import 'package:dj_deckify/features/deck/deck_state.dart';
import 'package:dj_deckify/features/deck/deck_widget.dart';
import 'package:dj_deckify/features/mixer/mixer_cubit.dart';
import 'package:dj_deckify/models/deck_config.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support/fake_audio_engine.dart';

class _Deck extends MockCubit<DeckState> implements DeckCubit {}

const _track = Track(id: 'sc:1', title: 'A rather long track title', artist: 'Some Artist', scId: 1, bpm: 124);

void main() {
  // Logical screen width → width of one grid cell for two or more decks.
  final screens = {'iPhone mini': 360.0, 'iPhone': 402.0, 'iPhone Pro Max': 440.0, 'iPad': 820.0};

  for (final MapEntry(key: name, value: width) in screens.entries) {
    testWidgets('a deck cell with two+ decks fits on $name', (tester) async {
      final columns = deckColumns(2, width);
      final cellWidth = (width - 8) / columns;
      final cellHeight = cellWidth / 0.75;
      final deck = _Deck();
      final config = const DeckConfig(id: 1, track: _track).copyWith(
        position: const Duration(minutes: 1, seconds: 23),
        duration: const Duration(minutes: 3, seconds: 45),
      );
      when(() => deck.state).thenReturn(DeckReady(config));
      when(() => deck.deckId).thenReturn(1);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: cellWidth,
              height: cellHeight,
              child: BlocProvider<DeckCubit>.value(value: deck, child: const DeckWidget()),
            ),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('during a party the live deck comes first, labelled and locked', (tester) async {
    final engine = FakeAudioEngine();
    final mixer = MixerCubit(engine);
    final decks = DeckRegistry((id) => DeckCubit(id, engine), mixer)..ensureFirst(const [1, 2]);
    addTearDown(decks.close);
    addTearDown(mixer.close);
    decks.deck(1).setPartyRole(PartyDeckRole.next);
    decks.deck(2).setPartyRole(PartyDeckRole.live);
    decks.setLive(2);

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [BlocProvider.value(value: mixer), BlocProvider.value(value: decks)],
          child: const DeckScreen(),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(decks.state.ordered, [2, 1]);
    expect(find.text('DECK 2'), findsOneWidget);
    expect(find.text('PARTY · LIVE'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  test('two decks sit side by side only on wide screens', () {
    expect(deckColumns(1, 1200), 1);
    expect(deckColumns(2, 440), 1);
    expect(deckColumns(6, 820), 2);
  });
}
