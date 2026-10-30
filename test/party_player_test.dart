import 'dart:async';

import 'package:dj_deckify/features/party/party_cubit.dart';
import 'package:dj_deckify/features/party/party_player.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:dj_deckify/services/audio_engine.dart';
import 'package:dj_deckify/services/relay_client.dart';
import 'package:dj_deckify/services/soundcloud_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Relay extends Mock implements RelayClient {}

class _Sc extends Mock implements SoundCloudService {}

class _Engine extends Mock implements AudioEngine {}

const t1 = Track(id: 'sc:1', title: 'One', artist: 'A', scId: 1, bpm: 124);

void main() {
  late _Relay relay;
  late _Sc sc;
  late _Engine engine;
  late Completer<bool> load;
  late PartyCubit cubit;

  setUp(() async {
    relay = _Relay();
    sc = _Sc();
    engine = _Engine();
    load = Completer<bool>();
    when(() => relay.createSession()).thenAnswer((_) async => (code: 'K7QX', token: 'tok'));
    when(() => relay.joinUrl(any())).thenReturn('https://djfy.test/j/K7QX');
    when(
      () => relay.hostEvents(any(), any(), onConnection: any(named: 'onConnection')),
    ).thenAnswer((_) => const Stream.empty());
    when(() => relay.publishSnapshot(any(), any(), any())).thenAnswer((_) async {});
    when(() => relay.sendToGuest(any(), any(), any(), any())).thenAnswer((_) async {});
    when(() => relay.endSession(any(), any())).thenAnswer((_) async {});
    when(() => sc.searchTracks(any(), limit: any(named: 'limit'))).thenAnswer((_) async => [t1]);
    when(() => sc.streamsFor(any())).thenAnswer((_) async => (progressive: null, fallback: 'https://cdn.test/1.mp3'));
    when(() => engine.setCrossfadeGain(any(), any())).thenAnswer((_) async {});
    when(() => engine.setSpeed(any(), any())).thenAnswer((_) async {});
    when(
      () => engine.loadTrack(any(), any(), progressiveUrl: any(named: 'progressiveUrl')),
    ).thenAnswer((_) => load.future);
    when(() => engine.play(any())).thenAnswer((_) async {});
    when(() => engine.pause(any())).thenAnswer((_) async {});
    when(() => engine.positionSync(any())).thenReturn(Duration.zero);
    when(() => engine.currentDuration(any())).thenReturn(null);

    cubit = PartyCubit(
      relay,
      sc,
      playerFactory: ({required onNeedNext, required onStarted, required onFailed}) {
        return PartyPlayer(engine, sc, onNeedNext: onNeedNext, onStarted: onStarted, onFailed: onFailed);
      },
    );
    await cubit.start('Chata');
    const guest = {'guestId': 'g-aaaaaaaa', 'name': 'Káťa'};
    await cubit.handleGuestMessage({'type': 'search', 'q': 'one', 'reqId': 'r', ...guest});
    await cubit.handleGuestMessage({'type': 'propose', 'trackId': 'sc:1', ...guest});
  });

  test('a load finishing after end() starts nothing', () async {
    final playing = cubit.togglePlay();
    await pumpEventQueue();
    verify(() => engine.loadTrack(any(), any(), progressiveUrl: any(named: 'progressiveUrl'))).called(1);

    await cubit.end();
    load.complete(false);
    await playing;
    await pumpEventQueue();

    verifyNever(() => engine.play(any()));
    expect(cubit.state.nowPlaying, isNull);
    expect(cubit.player.isPlaying, isFalse);
    await cubit.close();
  });

  test('a load finishing after close() does not emit', () async {
    final playing = cubit.togglePlay();
    await pumpEventQueue();

    await cubit.close();
    load.complete(false);
    await playing.catchError((_) {}); // togglePlay's own emit is the cubit's concern
    await pumpEventQueue();

    verifyNever(() => engine.play(any()));
  });

  test('a failed load after end() is not reported to the host', () async {
    final toasts = <String>[];
    final sub = cubit.stream.listen((s) => s.message == null ? null : toasts.add(s.message!));
    final playing = cubit.togglePlay();
    await pumpEventQueue();

    await cubit.end();
    load.completeError(Exception('interrupted'));
    await playing;
    await pumpEventQueue();

    expect(toasts, isEmpty);
    await sub.cancel();
    await cubit.close();
  });

  test('a new party can start after the previous one ended mid-load', () async {
    final stale = cubit.togglePlay();
    await pumpEventQueue();
    await cubit.end();

    load = Completer<bool>()..complete(false);
    await cubit.start('Chata 2');
    const guest = {'guestId': 'g-bbbbbbbb', 'name': 'Ota'};
    await cubit.handleGuestMessage({'type': 'search', 'q': 'one', 'reqId': 'r', ...guest});
    await cubit.handleGuestMessage({'type': 'propose', 'trackId': 'sc:1', ...guest});
    await cubit.togglePlay();

    expect(cubit.state.nowPlaying, t1);
    verify(() => engine.play(any())).called(1);
    await stale.timeout(const Duration(seconds: 1), onTimeout: () {});
    await cubit.close();
  });
}
