import 'track.dart';

enum StemType { drums, melody, vocals }

class DeckConfig {
  final int id;
  final Track? track;
  final bool isPlaying;
  final double speed;
  final double volume;
  final Duration position;
  final Duration duration;
  final Map<StemType, bool> stemFilters;
  final bool hasDsp; // true = flutter_soloud (DSP available), false = HLS fallback

  const DeckConfig({
    required this.id,
    this.track,
    this.isPlaying = false,
    this.speed = 1.0,
    this.volume = 0.8,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.stemFilters = const {
      StemType.drums: true,
      StemType.melody: true,
      StemType.vocals: true,
    },
    this.hasDsp = false,
  });

  DeckConfig copyWith({
    Track? track,
    bool? isPlaying,
    double? speed,
    double? volume,
    Duration? position,
    Duration? duration,
    Map<StemType, bool>? stemFilters,
    bool? hasDsp,
  }) {
    return DeckConfig(
      id: id,
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      stemFilters: stemFilters ?? this.stemFilters,
      hasDsp: hasDsp ?? this.hasDsp,
    );
  }
}
