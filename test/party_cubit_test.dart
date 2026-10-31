import 'package:dj_deckify/features/party/party_cubit.dart';
import 'package:dj_deckify/features/party/party_player.dart';
import 'package:dj_deckify/models/track.dart';
import 'package:dj_deckify/services/relay_client.dart';
import 'package:dj_deckify/services/soundcloud_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Relay extends Mock implements RelayClient {}

class _Sc extends Mock implements SoundCloudService {}

class _Player extends Mock implements PartyPlayer {}

const t1 = Track(id: 'sc:1', title: 'One', artist: 'A', scId: 1, bpm: 124);
const t2 = Track(id: 'sc:2', title: 'Two', artist: 'B', scId: 2, bpm: 126);

void main() {
  late _Relay relay;
  late _Sc sc;
  late _Player player;
  late PartyCubit cubit;
  late PartyPlayerEvents events;
  final sent = <Map<String, dynamic>>[];

  setUp(() async {
    relay = _Relay();
    sc = _Sc();
    player = _Player();
    sent.clear();
    when(() => relay.createSession()).thenAnswer((_) async => (code: 'K7QX', token: 'tok'));
    when(() => relay.joinUrl(any())).thenReturn('https://djfy.test/j/K7QX');
    when(() => relay.hostEvents(any(), any(), onConnection: any(named: 'onConnection')))
        .thenAnswer((_) => const Stream.empty());
    when(() => relay.publishSnapshot(any(), any(), any())).thenAnswer((_) async {});
    when(() => relay.sendToGuest(any(), any(), any(), any())).thenAnswer((inv) async {
      sent.add(inv.positionalArguments[3] as Map<String, dynamic>);
    });
    when(() => relay.ban(any(), any(), any())).thenAnswer((_) async {});
    when(() => relay.endSession(any(), any())).thenAnswer((_) async {});
    when(() => sc.searchTracks(any(), limit: any(named: 'limit'))).thenAnswer((_) async => [t1, t2]);
    when(() => player.prepare()).thenAnswer((_) async {});
    when(() => player.stop()).thenAnswer((_) async {});
    when(() => player.dispose()).thenAnswer((_) async {});
    when(() => player.skip()).thenAnswer((_) async {});
    when(() => player.isPlaying).thenReturn(false);
    when(() => player.position).thenReturn(Duration.zero);
    when(() => player.duration).thenReturn(Duration.zero);

    cubit = PartyCubit(relay, sc, playerFactory: (e) {
      events = e;
      return player;
    });
    await cubit.start('Chata');
  });

  tearDown(() => cubit.close());

  Map<String, dynamic> msg(String type, [Map<String, dynamic> extra = const {}]) =>
      {'type': type, 'guestId': 'g-aaaaaaaa', 'name': '🎧 Káťa', ...extra};

  test('guest search returns wire tracks without stream URLs', () async {
    await cubit.handleGuestMessage(msg('search', {'q': 'daft', 'reqId': 'r1'}));
    final res = sent.single;
    expect(res['type'], 'searchResults');
    expect(res['reqId'], 'r1');
    final first = (res['results'] as List).first as Map;
    expect(first['id'], 'sc:1');
    expect(first.keys, isNot(contains('streamUrl')));
  });

  test('propose only accepts tracks the guest was shown', () async {
    await cubit.handleGuestMessage(msg('propose', {'trackId': 'sc:999'}));
    expect(cubit.state.queue, isEmpty);
    expect(sent.last['text'], contains('nenalezena'));

    await cubit.handleGuestMessage(msg('search', {'q': 'daft', 'reqId': 'r'}));
    await cubit.handleGuestMessage(msg('propose', {'trackId': 'sc:1'}));
    expect(cubit.state.queue.single.proposedByName, '🎧 Káťa');
  });

  test('duplicate proposal turns into an upvote; one vote per guest', () async {
    await cubit.handleGuestMessage(msg('search', {'q': 'daft', 'reqId': 'r'}));
    await cubit.handleGuestMessage(msg('propose', {'trackId': 'sc:1'}));
    final other = {'type': 'propose', 'guestId': 'g-bbbbbbbb', 'name': 'Petr', 'trackId': 'sc:1'};
    await cubit.handleGuestMessage(other);
    expect(cubit.state.queue, hasLength(1));
    final id = cubit.state.queue.single.id;
    expect(cubit.state.queue.single.upVotes, 1);

    await cubit.handleGuestMessage({...other, 'type': 'vote', 'entryId': id, 'value': 1});
    await cubit.handleGuestMessage({...other, 'type': 'vote', 'entryId': id, 'value': -1});
    expect(cubit.state.queue.single.upVotes, 0);
    expect(cubit.state.queue.single.downVotes, 1);
  });

  test('banned guest loses proposals and is ignored', () async {
    await cubit.handleGuestMessage(msg('search', {'q': 'daft', 'reqId': 'r'}));
    await cubit.handleGuestMessage(msg('propose', {'trackId': 'sc:1'}));
    await cubit.ban('g-aaaaaaaa');
    expect(cubit.state.queue, isEmpty);
    verify(() => relay.ban('K7QX', 'tok', 'g-aaaaaaaa')).called(1);
    await cubit.handleGuestMessage(msg('propose', {'trackId': 'sc:2'}));
    expect(cubit.state.queue, isEmpty);
  });

  test('only co-DJs can veto', () async {
    await cubit.addTrack(t1);
    final id = cubit.state.queue.single.id;
    await cubit.handleGuestMessage(msg('veto', {'entryId': id}));
    expect(cubit.state.queue, hasLength(1));
    cubit.toggleCoDj('g-aaaaaaaa');
    await cubit.handleGuestMessage(msg('veto', {'entryId': id}));
    expect(cubit.state.queue, isEmpty);
  });

  test('player takes the top-ranked entry and snapshot reflects now playing', () async {
    await cubit.addTrack(t1);
    await cubit.addTrack(t2);
    final id2 = cubit.state.queue.last.id;
    cubit.pin(id2);
    final next = events.peekNext(null);
    expect(next, t2);
    expect(cubit.state.queue, hasLength(2), reason: 'peeking must not consume');
    events.onStarted(next!);
    final snap = cubit.buildSnapshot();
    expect((snap['nowPlaying'] as Map)['title'], 'Two');
    expect((snap['queue'] as List).single['track']['id'], 'sc:1');
  });
}
