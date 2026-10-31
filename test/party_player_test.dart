import 'package:dj_deckify/features/deck/deck_cubit.dart';
import 'package:dj_deckify/features/deck/deck_registry.dart';
import 'package:dj_deckify/features/deck/deck_state.dart';
import 'package:dj_deckify/features/mixer/mixer_cubit.dart';
import 'package:dj_deckify/features/party/party_cubit.dart';
import 'package:dj_deckify/features/party/party_player.dart';
import 'package:dj_deckify/models/deck_config.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:dj_deckify/services/relay_client.dart';
import 'package:dj_deckify/services/soundcloud_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support/fake_audio_engine.dart';

class _Relay extends Mock implements RelayClient {}

class _Sc extends Mock implements SoundCloudService {}

const t1 = Track(id: 'sc:1', title: 'One', artist: 'A', scId: 1);
const t2 = Track(id: 'sc:2', title: 'Two', artist: 'B', scId: 2);
const t3 = Track(id: 'sc:3', title: 'Three', artist: 'C', scId: 3);

String url(Track t) => 'https://cdn.test/${t.scId}.mp3';

void main() {
  late FakeAudioEngine engine;
  late _Relay relay;
  late _Sc sc;
  late DeckRegistry decks;
  late PartyCubit cubit;
  late PartyPlayer player;

  DeckCubit deck(int id) => decks.deck(id);
  Future<void> settle() => pumpEventQueue();
  Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));

  /// The whole point: what the party shows is what the deck plays.
  void expectInSync(Track track) {
    expect(cubit.state.nowPlaying, track);
    expect(engine.heard, url(track));
    expect(player.liveDeck.state.track, track);
    expect(player.liveDeck.state.config.partyRole, PartyDeckRole.live);
    expect(decks.state.ordered.first, player.liveDeck.deckId);
  }

  setUp(() async {
    engine = FakeAudioEngine();
    relay = _Relay();
    sc = _Sc();
    when(() => relay.createSession()).thenAnswer((_) async => (code: 'K7QX', token: 'tok'));
    when(() => relay.joinUrl(any())).thenReturn('https://djfy.test/j/K7QX');
    when(() => relay.hostEvents(any(), any(), onConnection: any(named: 'onConnection')))
        .thenAnswer((_) => const Stream.empty());
    when(() => relay.publishSnapshot(any(), any(), any())).thenAnswer((_) async {});
    when(() => relay.endSession(any(), any())).thenAnswer((_) async {});
    when(() => sc.streamsFor(any())).thenAnswer((inv) async {
      return (progressive: null, fallback: 'https://cdn.test/${inv.positionalArguments.first}.mp3');
    });

    final mixer = MixerCubit(engine);
    decks = DeckRegistry((id) => DeckCubit(id, engine, soundCloud: sc), mixer);
    cubit = PartyCubit(relay, sc, playerFactory: (events) {
      return player = PartyPlayer(decks, mixer, events)
        ..crossfade = const Duration(milliseconds: 400)
        ..cutFade = const Duration(milliseconds: 100);
    });
    await cubit.start('Chata');
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
    await decks.close();
  });

  test('starting a party stops what decks 1 and 2 were playing and locks them', () async {
    await cubit.end();
    await deck(1).loadTrack(t1, streaming: true);
    await deck(1).play();
    expect(engine.playing, {1});

    await cubit.start('Znovu');
    await settle();

    expect(engine.playing, isEmpty);
    expect(deck(1).state, isA<DeckIdle>());
    expect(deck(1).state.config.partyRole, PartyDeckRole.live);
    expect(deck(2).state.config.partyRole, PartyDeckRole.next);
    expect(decks.state.ids, [1, 2]);
  });

  test('play starts the top of the queue and the UI shows that exact track', () async {
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.togglePlay();
    await settle();

    expectInSync(t1);
    expect(cubit.state.isPlaying, isTrue);
    expect(cubit.state.queue.map((e) => e.track), [t2]);
    expect(player.liveDeck.deckId, 1);
  });

  test('Next cuts to the next track on the other deck, and works again right after', () async {
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.addTrack(t3);
    await cubit.togglePlay();
    await settle();

    cubit.skip();
    await wait(30);
    expect(cubit.state.nowPlaying, t2); // shown at once, still fading in
    expect(decks.state.ordered.first, 2);
    cubit.skip(); // pressed again mid-cut
    await wait(30);
    expect(cubit.state.nowPlaying, t3);
    await wait(150);
    expectInSync(t3);
    expect(engine.playing, hasLength(1));
    expect(cubit.state.history, [t2, t1]);
    expect(cubit.state.transition, isNull);
  });

  test('a second Next during a load discards that track and plays the one after', () async {
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.addTrack(t3);
    await cubit.togglePlay();
    await settle();

    engine.holdLoads = true;
    cubit.skip();
    await settle();
    expect(cubit.state.loadingNext, isTrue);
    engine.holdLoads = false;
    await cubit.skip();
    await settle();
    await wait(150);

    expectInSync(t3);
    expect(cubit.state.queue, isEmpty);
    expect(cubit.state.loadingNext, isFalse);
  });

  test('play now during an automatic change ends on the chosen track', () async {
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.addTrack(t3);
    await cubit.togglePlay();
    await settle();

    engine.holdLoads = true;
    engine.finish(player.liveDeck.deckId); // auto-advance starts loading Two
    await settle();
    final stale = engine.loads.last;
    engine.holdLoads = false;
    await cubit.playNow(cubit.state.queue.firstWhere((e) => e.track == t3).id);
    stale.done.complete(); // the old load lands last
    await settle();

    expectInSync(t3);
    expect(cubit.state.queue.map((e) => e.track), [t2]);
  });

  test('a failed load drops the track once and the party carries on', () async {
    when(() => sc.streamsFor(2)).thenThrow(Exception('geo-blocked'));
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.addTrack(t3);
    await cubit.togglePlay();
    await settle();

    final toasts = <String>[];
    final sub = cubit.stream.listen((s) => s.message == null ? null : toasts.add(s.message!));
    engine.finish(player.liveDeck.deckId);
    await settle();

    expectInSync(t3);
    expect(cubit.state.history, [t1]);
    expect(cubit.state.queue, isEmpty);
    expect(toasts.single, contains('Two'));
    await sub.cancel();
  });

  test('Auto-DJ flips now playing halfway through, with the crossfader moving', () async {
    cubit.setAutoDj(true);
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.togglePlay();
    await settle();
    final from = player.liveDeck.deckId;

    engine.seek(from, engine.trackLength - const Duration(milliseconds: 300));
    await wait(100);
    expect(engine.playing, hasLength(2));
    expect(cubit.state.nowPlaying, t1);
    expect(cubit.state.transition?.to, t2);
    expect(engine.heard, url(t1));

    await wait(400);
    expectInSync(t2);
    expect(engine.playing, hasLength(1));
    expect(cubit.state.transition, isNull);
    expect(decks.deck(from).state, isA<DeckIdle>());
  });

  test('Next during an Auto-DJ crossfade finishes it within the cut time', () async {
    cubit.setAutoDj(true);
    player.crossfade = const Duration(seconds: 8);
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.togglePlay();
    await settle();

    engine.seek(player.liveDeck.deckId, engine.trackLength - const Duration(seconds: 7));
    await wait(100);
    expect(cubit.state.transition, isNotNull);

    await cubit.skip();
    await wait(250);
    expectInSync(t2);
    expect(cubit.state.transition, isNull);
  });

  test('preload follows the top of the queue and the change reuses it', () async {
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    await cubit.addTrack(t3);
    await cubit.togglePlay();
    await settle();
    final live = player.liveDeck.deckId, idle = live == 1 ? 2 : 1;

    engine.seek(live, engine.trackLength - const Duration(seconds: 30));
    await settle();
    expect(deck(idle).state.track, t2);

    cubit.pin(cubit.state.queue.firstWhere((e) => e.track == t3).id);
    engine.seek(live, engine.trackLength - const Duration(seconds: 29));
    await settle();
    expect(deck(idle).state.track, t3);

    final loadsBefore = engine.loads.length;
    engine.finish(live);
    await settle();
    expect(engine.loads, hasLength(loadsBefore));
    expectInSync(t3);
  });

  test('the last track ending stops cleanly, and a new track starts by itself', () async {
    await cubit.addTrack(t1);
    await cubit.togglePlay();
    await settle();

    final states = <bool>[];
    final sub = cubit.stream.map((s) => s.isPlaying).distinct().listen(states.add);
    engine.finish(player.liveDeck.deckId);
    await settle();

    expect(states, [false]);
    expect(cubit.state.nowPlaying, isNull);
    expect(cubit.state.history, [t1]);
    expect(engine.playing, isEmpty);

    await cubit.addTrack(t2);
    await settle();
    expectInSync(t2);
    await sub.cancel();
  });

  test('Next with an empty queue keeps the music going and says why', () async {
    await cubit.addTrack(t1);
    await cubit.togglePlay();
    await settle();

    final toasts = <String>[];
    final sub = cubit.stream.listen((s) => s.message == null ? null : toasts.add(s.message!));
    await cubit.skip();
    await settle();

    expectInSync(t1);
    expect(toasts, ['Fronta je prázdná']);
    await sub.cancel();
  });

  test('pausing on the live deck itself shows on the party', () async {
    await cubit.addTrack(t1);
    await cubit.togglePlay();
    await settle();

    await player.liveDeck.togglePlayPause();
    await settle();
    expect(cubit.state.isPlaying, isFalse);

    await cubit.togglePlay();
    await settle();
    expect(cubit.state.isPlaying, isTrue);
    expect(engine.playing, hasLength(1));
  });

  test('a load finishing after end() starts nothing and the decks are free', () async {
    await cubit.addTrack(t1);
    engine.holdLoads = true;
    final playing = cubit.togglePlay();
    await settle();
    final pending = engine.loads.last;

    await cubit.end();
    pending.done.complete();
    await playing;
    await settle();

    expect(engine.playing, isEmpty);
    expect(cubit.state.nowPlaying, isNull);
    expect(deck(1).state.config.partyRole, isNull);
    expect(deck(2).state.config.partyRole, isNull);
    expect(decks.state.liveDeck, isNull);
  });

  test('a load finishing after close() does not emit', () async {
    await cubit.addTrack(t1);
    engine.holdLoads = true;
    cubit.togglePlay();
    await settle();
    final pending = engine.loads.last;

    await cubit.close();
    pending.done.complete();
    await settle();

    expect(engine.playing, isEmpty);
  });

  test('a failed load after end() is not reported to the host', () async {
    await cubit.addTrack(t1);
    engine.holdLoads = true;
    cubit.togglePlay();
    await settle();
    final pending = engine.loads.last;

    final toasts = <String>[];
    final sub = cubit.stream.listen((s) => s.message == null ? null : toasts.add(s.message!));
    await cubit.end();
    pending.done.completeError(Exception('interrupted'));
    await settle();

    expect(toasts, isEmpty);
    await sub.cancel();
  });

  test('a new party can start after the previous one ended mid-load', () async {
    await cubit.addTrack(t1);
    engine.holdLoads = true;
    cubit.togglePlay();
    await settle();
    await cubit.end();
    engine.holdLoads = false;

    await cubit.start('Chata 2');
    await cubit.addTrack(t1);
    await cubit.togglePlay();
    await settle();

    expectInSync(t1);
  });
}
