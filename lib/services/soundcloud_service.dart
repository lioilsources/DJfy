import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';

class SoundCloudService {
  final Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;

  SoundCloudService(this._dio);

  Future<void> authenticate() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(seconds: 60)))) {
      return;
    }
    try {
      final res = await _dio.post(
        '$kSoundCloudBaseUrl/oauth2/token',
        data: {
          'grant_type': 'client_credentials',
          'client_id': kSoundCloudId,
          'client_secret': kSoundCloudSecret,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      _accessToken = res.data['access_token'] as String?;
      final expiresIn = (res.data['expires_in'] as num?)?.toInt() ?? 3600;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      debugPrint('[SC] auth ok, token: ${_accessToken?.substring(0, 8)}…');
    } catch (e) {
      debugPrint('[SC] auth FAILED: $e');
      rethrow;
    }
  }

  Future<({String? streamUrl, String? permalinkUrl, int? scId})?> findTrack(
    String artist,
    String title,
  ) async {
    await authenticate();
    final query = '$title $artist';
    try {
      final res = await _dio.get(
        '$kSoundCloudBaseUrl/tracks',
        queryParameters: {'q': query, 'filter': 'streamable', 'limit': 5},
        options: Options(headers: {'Authorization': 'OAuth $_accessToken'}),
      );
      final tracks = res.data as List?;
      debugPrint('[SC] search "$query" → ${tracks?.length ?? 0} results');
      if (tracks == null || tracks.isEmpty) return null;
      final track = tracks.first as Map<String, dynamic>;
      final trackId = track['id'];
      final permalinkUrl = track['permalink_url'] as String?;
      debugPrint('[SC] picked track id=$trackId: ${track['title']}');

      final streamUrl = await _getStreamUrl(trackId.toString());
      debugPrint('[SC] stream url: $streamUrl');
      return (streamUrl: streamUrl, permalinkUrl: permalinkUrl, scId: trackId as int?);
    } catch (e) {
      debugPrint('[SC] findTrack FAILED: $e');
      return null;
    }
  }

  Future<String?> _getStreamUrl(String trackId) async {
    try {
      final res = await _dio.get(
        '$kSoundCloudBaseUrl/tracks/$trackId/streams',
        options: Options(headers: {'Authorization': 'OAuth $_accessToken'}),
      );
      final data = res.data as Map<String, dynamic>;
      debugPrint('[SC] streams response keys: ${data.keys.toList()}');

      // All SC stream URLs are API endpoints requiring auth — resolve the
      // redirect to get the final CDN URL that just_audio can load directly.
      final apiUrl = data['http_mp3_128_url'] as String? ??
          data['hls_mp3_128_url'] as String? ??
          data['hls_aac_160_url'] as String?;
      if (apiUrl == null) return null;

      return await _resolveCdnUrl(apiUrl);
    } catch (e) {
      debugPrint('[SC] _getStreamUrl FAILED: $e');
      return null;
    }
  }

  Future<String?> _resolveCdnUrl(String apiUrl) async {
    try {
      final res = await _dio.get(
        apiUrl,
        options: Options(
          headers: {'Authorization': 'OAuth $_accessToken'},
          followRedirects: false,
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      // 302 redirect → Location header is the CDN URL
      final location = res.headers.value('location');
      if (location != null) {
        debugPrint('[SC] resolved CDN url: ${location.substring(0, 60)}…');
        return location;
      }
      // Some responses return JSON with url field (HLS manifest path)
      if (res.data is Map && (res.data as Map).containsKey('url')) {
        return res.data['url'] as String?;
      }
      return apiUrl;
    } catch (e) {
      debugPrint('[SC] _resolveCdnUrl FAILED: $e');
      return null;
    }
  }
}
