import 'package:dio/dio.dart';
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
      if (tracks == null || tracks.isEmpty) return null;
      final track = tracks.first as Map<String, dynamic>;
      final trackId = track['id'];
      final permalinkUrl = track['permalink_url'] as String?;

      final streamUrl = await _getStreamUrl(trackId.toString());
      return (streamUrl: streamUrl, permalinkUrl: permalinkUrl, scId: trackId as int?);
    } catch (_) {
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
      return data['hls_aac_160_url'] as String? ??
          data['hls_aac_128_url'] as String? ??
          data['hls_mp3_128_url'] as String?;
    } catch (_) {
      return null;
    }
  }
}
