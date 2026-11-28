import 'package:dj_deckify/services/audio_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = Uri.parse('https://cdn.example/playlist/abc.128.mp3/playlist.m3u8?Policy=x');

  test('lists the segments in order, relative ones resolved', () {
    const playlist = '''
#EXTM3U
#EXT-X-VERSION:6
#EXT-X-PLAYLIST-TYPE:VOD
#EXTINF:1.98,
https://cdn.example/media/0/0/31762/abc.128.mp3?Policy=a
#EXTINF:2.97,
../../media/0/31763/79410/abc.128.mp3?Policy=b
#EXT-X-ENDLIST
''';
    expect(AudioEngine.hlsSegments(playlist, base).map((u) => u.toString()), [
      'https://cdn.example/media/0/0/31762/abc.128.mp3?Policy=a',
      'https://cdn.example/media/0/31763/79410/abc.128.mp3?Policy=b',
    ]);
  });

  test('encrypted playlists give nothing to decode', () {
    const playlist = '#EXTM3U\n#EXT-X-KEY:METHOD=AES-128,URI="k"\n#EXTINF:2,\nseg.mp3\n';
    expect(AudioEngine.hlsSegments(playlist, base), isEmpty);
  });

  test('only MP3 playlists are fetched whole', () {
    expect(AudioEngine.isMp3Hls(base.toString()), isTrue);
    expect(AudioEngine.isMp3Hls('https://cdn.example/playlist/abc.160.aac/playlist.m3u8'), isFalse);
    expect(AudioEngine.isMp3Hls('https://cdn.example/track.mp3'), isFalse);
  });
}
