import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/track.dart';
import '../../services/lastfm_service.dart';
import '../../services/bpm_service.dart';
import '../../services/jamendo_service.dart';
// import '../../services/soundcloud_service.dart'; // re-enable when approved
import 'playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  final LastFmService _lastFm;
  final BpmService _bpm;
  final JamendoService _jamendo;

  PlaylistCubit(this._lastFm, this._bpm, this._jamendo)
      : super(const PlaylistIdle());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    emit(PlaylistSearching(query));

    try {
      Track? seed;
      List<Track> similar = [];

      if (query.contains(' - ')) {
        final parts = query.split(' - ');
        final artist = parts[0].trim();
        final title = parts.sublist(1).join(' - ').trim();
        seed = await _lastFm.searchTrack(artist, title);
        if (seed != null) {
          similar = await _lastFm.getSimilarTracks(artist, title);
        }
      }

      if (seed == null) {
        final artistTracks =
            await _lastFm.getSimilarArtistTracks(query.trim());
        if (artistTracks.isEmpty) throw Exception('Nic nenalezeno');
        seed = artistTracks.first;
        similar = artistTracks.skip(1).toList();
      }

      seed = await _enrichTrack(seed);
      final enriched = await Future.wait(
        similar.map(_enrichTrack),
        eagerError: false,
      );

      final seedBpm = seed.bpm;
      List<Track> sorted;
      if (seedBpm != null) {
        final withBpm = enriched.where((t) => t.bpm != null).toList()
          ..sort((a, b) => (a.bpm! - seedBpm)
              .abs()
              .compareTo((b.bpm! - seedBpm).abs()));
        final withoutBpm = enriched.where((t) => t.bpm == null).toList();
        sorted = [...withBpm, ...withoutBpm];
      } else {
        sorted = enriched;
      }

      emit(PlaylistLoaded(seed: seed, tracks: sorted));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<Track> _enrichTrack(Track track) async {
    final bpm = await _bpm.getBpm(track.artist, track.title);

    final jamendo = await _jamendo.findTrack(track.artist, track.title);

    return track.copyWith(
      bpm: bpm,
      artworkUrl: jamendo?.artworkUrl ?? track.artworkUrl,
      soundcloudStreamUrl: jamendo?.streamUrl,
      soundcloudPermalinkUrl: jamendo?.permalinkUrl,
    );
  }
}
