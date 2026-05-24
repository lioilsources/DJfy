import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../models/track.dart';

class LastFmService {
  final Dio _dio;

  LastFmService(this._dio);

  Future<Track?> searchTrack(String artist, String title) async {
    final res = await _dio.get(kLastFmBaseUrl, queryParameters: {
      'method': 'track.search',
      'track': title,
      'artist': artist,
      'limit': 1,
      'api_key': kLastFmApiKey,
      'format': 'json',
    });
    final results =
        res.data['results']?['trackmatches']?['track'] as List? ?? [];
    if (results.isEmpty) return null;
    final t = results.first as Map<String, dynamic>;
    return Track(
      id: '${t['artist']}-${t['name']}',
      title: t['name'] as String,
      artist: t['artist'] as String,
      artworkUrl: _extractImage(t['image'] as List?),
    );
  }

  Future<List<Track>> getSimilarTracks(
    String artist,
    String title, {
    int limit = 20,
  }) async {
    final res = await _dio.get(kLastFmBaseUrl, queryParameters: {
      'method': 'track.getSimilar',
      'artist': artist,
      'track': title,
      'limit': limit,
      'api_key': kLastFmApiKey,
      'format': 'json',
    });
    final tracks =
        res.data['similartracks']?['track'] as List? ?? [];
    return tracks.map((t) {
      final map = t as Map<String, dynamic>;
      final tags = (map['toptags']?['tag'] as List? ?? [])
          .map((tag) => tag['name'] as String)
          .toList();
      return Track(
        id: '${map['artist']?['name'] ?? ''}-${map['name']}',
        title: map['name'] as String,
        artist: (map['artist'] as Map?)?['name'] as String? ?? '',
        artworkUrl: _extractImage(map['image'] as List?),
        tags: tags,
        similarity: double.tryParse(map['match']?.toString() ?? ''),
      );
    }).toList();
  }

  Future<List<Track>> getSimilarArtistTracks(
    String artist, {
    int limit = 20,
  }) async {
    final res = await _dio.get(kLastFmBaseUrl, queryParameters: {
      'method': 'artist.getTopTracks',
      'artist': artist,
      'limit': limit,
      'api_key': kLastFmApiKey,
      'format': 'json',
    });
    final tracks = res.data['toptracks']?['track'] as List? ?? [];
    return tracks.map((t) {
      final map = t as Map<String, dynamic>;
      return Track(
        id: '$artist-${map['name']}',
        title: map['name'] as String,
        artist: artist,
        artworkUrl: _extractImage(map['image'] as List?),
      );
    }).toList();
  }

  String? _extractImage(List? images) {
    if (images == null || images.isEmpty) return null;
    final large = images.firstWhere(
      (i) => i['size'] == 'large',
      orElse: () => images.last,
    );
    final url = large['#text'] as String?;
    return (url != null && url.isNotEmpty) ? url : null;
  }
}
