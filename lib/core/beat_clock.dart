/// Beat grid for a deck, with position extrapolation between the engine's
/// coarse (200 ms) position polls.
///
/// Two time domains matter here:
/// * **track time** — positions inside the audio file; a beat is always
///   60000/bpm ms regardless of playback speed.
/// * **wall time** — real elapsed time; at speed != 1 a beat takes
///   beatDuration / speed of wall time.
class BeatClock {
  BeatClock({
    double? bpm,
    this.speed = 1.0,
    Stopwatch? stopwatch,
  })  : _bpm = bpm ?? fallbackBpm,
        _clock = stopwatch ?? Stopwatch() {
    _clock.start();
  }

  static const double fallbackBpm = 120;

  final Stopwatch _clock;
  double _bpm;
  double speed;
  bool playing = false;

  Duration _anchorPos = Duration.zero;
  int _anchorWallUs = 0;

  double get bpm => _bpm;

  set bpm(double? value) {
    _bpm = (value == null || value <= 0) ? fallbackBpm : value;
  }

  /// One beat in track time.
  Duration get beatDuration =>
      Duration(microseconds: (60e6 / _bpm).round());

  /// One beat in wall time at the current playback speed.
  Duration get wallBeatDuration =>
      Duration(microseconds: (60e6 / _bpm / speed).round());

  /// Re-anchor the extrapolation. Call on every position poll, and after
  /// seek / play / pause / speed changes (with the freshest known position).
  void anchor(Duration enginePos) {
    _anchorPos = enginePos;
    _anchorWallUs = _clock.elapsedMicroseconds;
  }

  /// Best estimate of the current track position: last anchored position
  /// plus wall time elapsed since, scaled by playback speed while playing.
  Duration get estimatedPosition {
    if (!playing) return _anchorPos;
    final wallUs = _clock.elapsedMicroseconds - _anchorWallUs;
    return _anchorPos + Duration(microseconds: (wallUs * speed).round());
  }

  /// Nearest beat-grid point to [pos] (track time, grid anchored at 0).
  Duration quantizeToBeat(Duration pos) {
    final beatUs = beatDuration.inMicroseconds;
    if (beatUs == 0) return pos;
    final beats = (pos.inMicroseconds / beatUs).round();
    return Duration(microseconds: beats * beatUs);
  }
}
