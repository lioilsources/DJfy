import 'dart:math' as math;

import 'dart:typed_data';

import 'package:dj_deckify/core/platter.dart';
import 'package:dj_deckify/core/track_analysis.dart';
import 'package:dj_deckify/features/deck/deck_cubit.dart';
import 'package:dj_deckify/features/deck/deck_state.dart';
import 'package:dj_deckify/models/deck_config.dart';
import 'package:dj_deckify/models/fx.dart';
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

  test('a party (streaming) load offers the progressive MP3 for PCM', () async {
    when(() => sc.streamsFor(any())).thenAnswer((_) async => (progressive: 'https://cdn.test/1.mp3', fallback: 'https://cdn.test/1.m3u8'));
    await deck.loadTrack(t1, streaming: true);
    expect(engine.progressive[1], (url: 'https://cdn.test/1.mp3', streaming: true));
    expect(engine.loaded[1], 'https://cdn.test/1.m3u8');
  });

  test('roll on a PCM deck loops in the voice and lands on the grid', () async {
    const withBpm = Track(id: 'sc:3', title: 'Three', artist: 'C', scId: 3, bpm: 120);
    engine.reversible.add(1);
    await deck.loadTrack(withBpm, streaming: true);
    engine.seek(1, const Duration(milliseconds: 10100));
    await deck.play();
    deck.selectFx(FxType.roll);
    deck.fxStart(0.3, 0.5); // 1/4 beat
    expect(engine.loops[1], (start: const Duration(seconds: 10), length: const Duration(milliseconds: 125)));
    expect(engine.seeks[1] ?? [], isEmpty); // no seek clicks
    await Future<void>.delayed(const Duration(milliseconds: 20)); // updates are throttled per frame
    deck.fxUpdate(0.9, 0.5); // 1/16 beat
    expect(engine.loops[1]!.length, const Duration(microseconds: 31250));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    deck.fxEnd();
    expect(engine.loops[1], isNull);
    expect(engine.seeks[1]!.last, greaterThanOrEqualTo(const Duration(milliseconds: 10300)));
  });

  test('a PCM deck gets its waveform and a detected beat grid', () async {
    const withBpm = Track(id: 'sc:3', title: 'Three', artist: 'C', scId: 3, bpm: 120);
    final onsets = Float32List(3000);
    for (var i = 12; i < onsets.length; i += 50) {
      onsets[i] = 1; // a beat every 0.5 s from 0.12 s
    }
    engine.analyses[1] = TrackAnalysis(Uint8List(600), onsets);
    await deck.loadTrack(withBpm, streaming: true);
    await pumpEventQueue();
    expect(deck.state.config.waveform, hasLength(600));
    expect(deck.state.config.beatOffset.inMilliseconds, closeTo(120, 5));

    engine.seek(1, const Duration(milliseconds: 2300));
    await pumpEventQueue();
    deck.tapBeat();
    expect(deck.state.config.beatOffset, const Duration(milliseconds: 300));
  });

  group('platter', () {
    Future<void> loaded({bool playing = true}) async {
      await deck.loadTrack(t1, streaming: true);
      engine.seek(1, const Duration(seconds: 10));
      if (playing) await deck.play();
      engine.rates.clear();
      engine.seeks.clear();
    }

    Future<void> ms(int n) => Future.delayed(Duration(milliseconds: n));

    test('touch mutes the record at once, the deck keeps playing', () async {
      await loaded();
      deck.platterTouch();
      expect(engine.rates[1]!.last, 0);
      expect(engine.playing, {1});
      expect(deck.state.config.isPlaying, isTrue);
      deck.platterRelease();
    });

    test('dragging forward plays at the finger speed and moves the track', () async {
      await loaded();
      deck.platterTouch();
      // Half a turn in 0.9 s = normal speed.
      for (var i = 0; i < 6; i++) {
        deck.platterDrag(math.pi / 6, 0.15);
      }
      expect(engine.rates[1]!.last, closeTo(1, 0.01));
      expect(deck.displayPosition, const Duration(milliseconds: 10900));
      deck.platterRelease();
      expect(engine.seeks[1]!.last, const Duration(milliseconds: 10900));
    });

    test('dragging backwards pulls the audio back with seeks', () async {
      await loaded();
      deck.platterTouch();
      for (var i = 0; i < 4; i++) {
        deck.platterDrag(-math.pi / 4, 0.1);
        await ms(40);
      }
      // A finger that pauses > 50 ms stops the record, so check it went backwards at all.
      expect(engine.rates[1]!.any((r) => r < 0), isTrue);
      expect(engine.seeks[1], isNotEmpty);
      expect(engine.seeks[1]!.last, lessThan(const Duration(seconds: 10)));
      deck.platterRelease();
      expect(deck.displayPosition, lessThan(const Duration(milliseconds: 9200)));
    });

    test('release spins back up to the pitch speed and then stops ticking', () async {
      await loaded();
      await deck.setSpeed(1.1);
      deck.platterTouch();
      deck.platterRelease();
      expect(deck.platterIdle, isFalse);
      await ms(250);
      expect(engine.rates[1]!.last, greaterThan(1.0));
      await ms(600);
      expect(engine.rates[1]!.last, closeTo(1.1, 1e-3));
      expect(deck.platterIdle, isTrue);
    });

    test('slip mode lands where the track would have been', () async {
      await loaded();
      deck.toggleSlip();
      deck.platterTouch();
      deck.platterDrag(-math.pi, 0.2); // back 0.9 s
      await ms(200);
      deck.platterRelease();
      final landed = engine.seeks[1]!.last;
      expect(landed, greaterThanOrEqualTo(const Duration(milliseconds: 10200)));
      expect(landed, lessThan(const Duration(milliseconds: 10400)));
      expect(engine.rates[1]!.last, 1);
    });

    test('scratching a paused deck plays it only under the finger', () async {
      await loaded(playing: false);
      deck.platterTouch();
      expect(engine.playing, {1});
      deck.platterDrag(math.pi / 6, 0.15);
      deck.platterRelease();
      await pumpEventQueue();
      expect(engine.playing, isEmpty);
      expect(deck.state.config.isPlaying, isFalse);
    });

    test('brake coasts to a stop and pauses; play starts at full speed', () async {
      await loaded();
      deck.brake(0.2);
      await ms(120);
      expect(engine.rates[1]!.last, inExclusiveRange(0, 0.8));
      await ms(250);
      expect(engine.playing, isEmpty);
      await deck.play();
      expect(engine.rates[1]!.last, 1);
      expect(engine.playing, {1});
    });

    test('nudge bends the pitch while held', () async {
      await loaded();
      deck.nudge(-1);
      await ms(500);
      expect(engine.rates[1]!.last, closeTo(1 - Platter.nudgeAmount, 1e-3));
      deck.nudge(0);
      await ms(500);
      expect(engine.rates[1]!.last, closeTo(1, 1e-3));
    });

    test('a PCM deck follows the finger directly, backwards included, without seeks', () async {
      await loaded();
      engine.reversible.add(1);
      deck.platterTouch();
      expect(engine.follows[1]!.last, const Duration(seconds: 10));
      deck.platterDrag(-math.pi, 0.2);
      expect(engine.follows[1]!.last, const Duration(milliseconds: 9100));
      await ms(40);
      deck.platterRelease();
      expect(engine.follows[1]!.last, isNull);
      expect(engine.seeks[1] ?? [], isEmpty);
      expect(engine.playing, {1});
    });

    test('a paused PCM deck sounds under the finger without being started', () async {
      await loaded(playing: false);
      engine.reversible.add(1);
      deck.platterTouch();
      expect(engine.playing, isEmpty);
      deck.platterRelease();
      expect(engine.follows[1]!.last, isNull);
    });

    test('the NEXT deck of a party cannot be scratched', () async {
      await loaded();
      deck.setPartyRole(PartyDeckRole.next);
      expect(deck.canScratch, isFalse);
      deck.platterTouch();
      expect(engine.rates[1], isNull);
    });
  });
}
