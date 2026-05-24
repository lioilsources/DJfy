import 'track.dart';

class PlaylistResult {
  final Track seed;
  final List<Track> similar;

  const PlaylistResult({required this.seed, required this.similar});
}
