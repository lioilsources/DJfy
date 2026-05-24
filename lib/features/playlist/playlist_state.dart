import '../../models/track.dart';

sealed class PlaylistState {
  const PlaylistState();
}

class PlaylistIdle extends PlaylistState {
  const PlaylistIdle();
}

class PlaylistSearching extends PlaylistState {
  final String query;
  const PlaylistSearching(this.query);
}

class PlaylistLoaded extends PlaylistState {
  final Track seed;
  final List<Track> tracks;
  const PlaylistLoaded({required this.seed, required this.tracks});
}

class PlaylistError extends PlaylistState {
  final String message;
  const PlaylistError(this.message);
}
