import 'track.dart';

class DeckConfig {
  final int id;
  final Track? track;
  final bool isPlaying;
  final double speed;
  final double volume;
  final Duration position;
  final Duration duration;

  const DeckConfig({
    required this.id,
    this.track,
    this.isPlaying = false,
    this.speed = 1.0,
    this.volume = 0.8,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  DeckConfig copyWith({
    Track? track,
    bool? isPlaying,
    double? speed,
    double? volume,
    Duration? position,
    Duration? duration,
  }) {
    return DeckConfig(
      id: id,
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}
