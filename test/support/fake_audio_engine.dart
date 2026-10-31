import 'dart:async';

import 'package:dj_deckify/services/audio_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;

class FakeLoad {
  final int deck;
  final String url;
  final done = Completer<void>();
  FakeLoad(this.deck, this.url);
}

/// In-memory audio: loads finish on their own unless [holdLoads] is set, and
/// tests drive position and track end by hand.
class FakeAudioEngine extends Fake implements AudioEngine {
  final _pos = <int, StreamController<Duration>>{};
  final _dur = <int, StreamController<Duration?>>{};
  final _state = <int, StreamController<PlayerState>>{};

  final loads = <FakeLoad>[];
  final _latest = <int, FakeLoad>{};
  final loaded = <int, String>{};
  final playing = <int>{};
  final gains = <int, double>{};
  final positions = <int, Duration>{};
  bool holdLoads = false;
  Duration trackLength = const Duration(minutes: 4);

  StreamController<PlayerState> _stateFor(int id) => _state.putIfAbsent(id, StreamController.broadcast);
  StreamController<Duration> _posFor(int id) => _pos.putIfAbsent(id, StreamController.broadcast);
  StreamController<Duration?> _durFor(int id) => _dur.putIfAbsent(id, StreamController.broadcast);

  @override
  Stream<Duration> positionStream(int deckId) => _posFor(deckId).stream;
  @override
  Stream<Duration?> durationStream(int deckId) => _durFor(deckId).stream;
  @override
  Stream<PlayerState> playerStateStream(int deckId) => _stateFor(deckId).stream;

  @override
  Future<bool> loadTrack(int deckId, String hlsUrl, {String? progressiveUrl}) async {
    final load = FakeLoad(deckId, hlsUrl);
    loads.add(load);
    _latest[deckId] = load;
    playing.remove(deckId);
    if (!holdLoads) load.done.complete();
    await load.done.future;
    // A newer load interrupts this one, as it does on a real player.
    if (identical(_latest[deckId], load)) {
      loaded[deckId] = hlsUrl;
      positions[deckId] = Duration.zero;
    }
    return false;
  }

  @override
  Future<void> play(int deckId) async {
    playing.add(deckId);
    _stateFor(deckId).add(PlayerState(true, ProcessingState.ready));
  }

  @override
  Future<void> pause(int deckId) async {
    playing.remove(deckId);
    _stateFor(deckId).add(PlayerState(false, ProcessingState.ready));
  }

  @override
  Future<void> stop(int deckId) async {
    playing.remove(deckId);
    loaded.remove(deckId);
    _stateFor(deckId).add(PlayerState(false, ProcessingState.idle));
  }

  @override
  Future<void> setCrossfadeGain(int deckId, double gain) async => gains[deckId] = gain;
  @override
  Future<void> setSpeed(int deckId, double speed) async {}
  @override
  Duration positionSync(int deckId) => positions[deckId] ?? Duration.zero;
  @override
  Duration? currentDuration(int deckId) => loaded.containsKey(deckId) ? trackLength : null;
  @override
  void dispose(int deckId) {}

  /// Moves playback on [deckId] to [position].
  void seek(int deckId, Duration position) {
    positions[deckId] = position;
    _posFor(deckId).add(position);
  }

  /// The loaded track plays out; just_audio keeps `playing` true at the end.
  void finish(int deckId) => _stateFor(deckId).add(PlayerState(true, ProcessingState.completed));

  /// What the room hears: the loudest playing deck's URL.
  String? get heard {
    final decks = playing.toList()..sort((a, b) => (gains[b] ?? 1).compareTo(gains[a] ?? 1));
    return decks.isEmpty ? null : loaded[decks.first];
  }
}
