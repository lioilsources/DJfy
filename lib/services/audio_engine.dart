import 'package:just_audio/just_audio.dart';

class AudioEngine {
  static final instance = AudioEngine._();
  AudioEngine._();

  final Map<int, AudioPlayer> _players = {};

  AudioPlayer playerFor(int deckId) {
    return _players.putIfAbsent(deckId, () => AudioPlayer());
  }

  Future<void> loadTrack(int deckId, String hlsUrl) async {
    final player = playerFor(deckId);
    await player.stop();
    await player.setAudioSource(HlsAudioSource(Uri.parse(hlsUrl)));
  }

  Future<void> play(int deckId) async {
    await playerFor(deckId).play();
  }

  Future<void> pause(int deckId) async {
    await playerFor(deckId).pause();
  }

  Future<void> seekTo(int deckId, Duration position) async {
    await playerFor(deckId).seek(position);
  }

  Future<void> setSpeed(int deckId, double speed) async {
    await playerFor(deckId).setSpeed(speed);
  }

  Future<void> setVolume(int deckId, double volume) async {
    await playerFor(deckId).setVolume(volume);
  }

  Stream<Duration> positionStream(int deckId) =>
      playerFor(deckId).positionStream;

  Stream<Duration?> durationStream(int deckId) =>
      playerFor(deckId).durationStream;

  Stream<PlayerState> playerStateStream(int deckId) =>
      playerFor(deckId).playerStateStream;

  void dispose(int deckId) {
    _players.remove(deckId)?.dispose();
  }

  void disposeAll() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
  }
}
