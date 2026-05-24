import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../core/cache_service.dart';

class BpmService {
  final Dio _dio;
  final CacheService _cache;

  BpmService(this._dio, this._cache);

  Future<int?> getBpm(String artist, String title) async {
    final cached = await _cache.getBpm(artist, title);
    if (cached != null) return cached;

    try {
      final searchRes = await _dio.get(
        '$kGetSongBpmBaseUrl/search/',
        queryParameters: {
          'api_key': kGetSongBpmKey,
          'type': 'song',
          'lookup': title,
          'artist': artist,
        },
      );
      final songId = _extractSongId(searchRes.data);
      if (songId == null) return null;

      final songRes = await _dio.get(
        '$kGetSongBpmBaseUrl/song/',
        queryParameters: {'api_key': kGetSongBpmKey, 'id': songId},
      );
      final bpm = _extractBpm(songRes.data);
      if (bpm != null) {
        await _cache.saveBpm(artist, title, bpm);
      }
      return bpm;
    } catch (_) {
      return null;
    }
  }

  String? _extractSongId(dynamic data) {
    if (data is Map) {
      final song = data['song'];
      if (song is Map) return song['id']?.toString();
      final results = data['search'] as List?;
      if (results != null && results.isNotEmpty) {
        return (results.first as Map)['id']?.toString();
      }
    }
    return null;
  }

  int? _extractBpm(dynamic data) {
    if (data is Map) {
      final song = data['song'] as Map?;
      if (song != null) {
        final tempo = song['tempo'];
        if (tempo != null) return int.tryParse(tempo.toString());
      }
    }
    return null;
  }
}
