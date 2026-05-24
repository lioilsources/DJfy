import 'package:dio/dio.dart';
import '../core/constants.dart';

class JamendoTrackResult {
  final String streamUrl;
  final String? permalinkUrl;
  final String? artworkUrl;
  final int? bpm;

  const JamendoTrackResult({
    required this.streamUrl,
    this.permalinkUrl,
    this.artworkUrl,
    this.bpm,
  });
}

class JamendoService {
  final Dio _dio;

  JamendoService(this._dio);

  Future<JamendoTrackResult?> findTrack(String artist, String title) async {
    try {
      final res = await _dio.get(
        '$kJamendoBaseUrl/tracks/',
        queryParameters: {
          'client_id': kJamendoClientId,
          'format': 'json',
          'limit': 5,
          'search': '$title $artist',
          'audioformat': 'mp32',
          'include': 'musicinfo',
        },
      );

      final results = res.data['results'] as List?;
      if (results == null || results.isEmpty) return null;

      // Prefer track where artist name matches
      final map = _bestMatch(results, artist, title);
      final streamUrl = map['audio'] as String?;
      if (streamUrl == null || streamUrl.isEmpty) return null;

      return JamendoTrackResult(
        streamUrl: streamUrl,
        permalinkUrl: map['shareurl'] as String?,
        artworkUrl: map['image'] as String?,
        bpm: _extractBpm(map),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _bestMatch(
      List results, String artist, String title) {
    final artistLower = artist.toLowerCase();
    final titleLower = title.toLowerCase();
    for (final r in results) {
      final map = r as Map<String, dynamic>;
      final rArtist = (map['artist_name'] as String? ?? '').toLowerCase();
      final rTitle = (map['name'] as String? ?? '').toLowerCase();
      if (rArtist.contains(artistLower) || rTitle.contains(titleLower)) {
        return map;
      }
    }
    return results.first as Map<String, dynamic>;
  }

  int? _extractBpm(Map<String, dynamic> map) {
    final musicinfo = map['musicinfo'] as Map?;
    final bpmRaw = musicinfo?['bpm'];
    if (bpmRaw == null) return null;
    return int.tryParse(bpmRaw.toString());
  }
}
