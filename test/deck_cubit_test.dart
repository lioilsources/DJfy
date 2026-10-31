import 'package:dj_deckify/features/deck/deck_cubit.dart';
import 'package:dj_deckify/features/deck/deck_state.dart';
import 'package:dj_deckify/models/deck_config.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:dj_deckify/services/soundcloud_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support/fake_audio_engine.dart';

class _Sc extends Mock implements SoundCloudService {}

const t1 = Track(id: 'sc:1', title: 'One', artist: 'A', scId: 1);
const t2 = Track(id: 'sc:2', title: 'Two', artist: 'B', scId: 2);

void main() {
  late FakeAudioEngine engine;
  late _Sc sc;
  late DeckCubit deck;

  setUp(() {
    engine = FakeAudioEngine();
    sc = _Sc();
    when(() => sc.streamsFor(any())).thenAnswer((inv) async {
      return (progressive: null, fallback: 'https://cdn.test/${inv.positionalArguments.first}.mp3');
    });
    deck = DeckCubit(1, engine, soundCloud: sc);
  });

  tearDown(() => deck.close());

  test('streaming load resolves the URL itself and skips DSP', () async {
    await deck.loadTrack(t1, streaming: true);
    expect(deck.state, isA<DeckReady>());
    expect(deck.state.track, t1);
    expect(deck.state.config.hasDsp, isFalse);
    expect(engine.loaded[1], 'https://cdn.test/1.mp3');
  });

  test('a streaming failure shows on the deck and reaches the caller', () async {
    when(() => sc.streamsFor(1)).thenAnswer((_) async => (progressive: null, fallback: null));
    await expectLater(deck.loadTrack(t1, streaming: true), throwsStateError);
    expect(deck.state, isA<DeckError>());
  });

  test('a newer load supersedes one still in progress', () async {
    engine.holdLoads = true;
    final first = deck.loadTrack(t1, streaming: true);
    await pumpEventQueue();
    final second = deck.loadTrack(t2, streaming: true);
    await pumpEventQueue();
    engine.loads[1].done.complete();
    await second;
    engine.loads[0].done.complete();
    await first;
    expect(deck.state.track, t2);
  });

  test('eject cancels a load and empties the deck but keeps its role', () async {
    deck.setPartyRole(PartyDeckRole.next);
    engine.holdLoads = true;
    final load = deck.loadTrack(t1, streaming: true);
    await pumpEventQueue();
    await deck.eject();
    engine.loads.single.done.complete();
    await load;
    expect(deck.state, isA<DeckIdle>());
    expect(deck.state.track, isNull);
    expect(deck.state.config.partyRole, PartyDeckRole.next);
  });

  test('completed fires once per track end', () async {
    await deck.loadTrack(t1, streaming: true);
    var ends = 0;
    final sub = deck.completed.listen((_) => ends++);
    engine.finish(1);
    engine.finish(1);
    await pumpEventQueue();
    expect(ends, 1);
    await sub.cancel();
  });

  test('a role change keeps the deck loaded and playing', () async {
    await deck.loadTrack(t1, streaming: true);
    await deck.play();
    await pumpEventQueue();
    deck.setPartyRole(PartyDeckRole.live);
    expect(deck.state, isA<DeckReady>());
    expect(deck.state.isPlaying, isTrue);
    deck.setPartyRole(null);
    expect(deck.state.config.partyRole, isNull);
    expect(deck.state.isPlaying, isTrue);
  });
}
