import 'dart:math' as math;
import 'dart:typed_data';

/// Plays a decoded track like a record: a fractional playhead moved by a
/// signed rate, so it can slow down, stop and go backwards with the pitch
/// following the speed. Pure Dart, renders interleaved stereo 16-bit blocks.
class ScratchRenderer {
  /// Interleaved source samples ([channels] per frame).
  final Int16List pcm;
  final int channels;
  final int sampleRate;

  /// Crossfade after a jump (seek, loop wrap), so it never clicks.
  static const crossfadeSeconds = 0.003;

  /// Rate smoothing per second: slewing a few ms keeps rate steps click-free.
  static const rateSlewPerSecond = 400.0;

  /// The finger leads; the playhead closes the gap within about this time.
  static const followSeconds = 0.015;

  /// Below this |rate| the record fades to silence (vinyl stopping).
  static const audibleRate = 0.15;

  ScratchRenderer(this.pcm, {required this.channels, required this.sampleRate})
      : assert(channels == 1 || channels == 2),
        _crossfadeFrames = math.max(1, (crossfadeSeconds * sampleRate).round());

  int get frames => pcm.length ~/ channels;

  /// Source frame under the needle.
  double position = 0;

  /// Requested signed rate while [playing] and not following a finger.
  double rate = 1;
  bool playing = false;

  double? _follow;
  double _followRate = 0;

  double? _loopStart;
  double? _loopEnd;

  double _rate = 0;
  double _gain = 0;
  final int _crossfadeFrames;
  double _fadeFrom = 0;
  int _fadeLeft = 0;

  /// The rate actually playing, after smoothing.
  double get currentRate => _rate;

  /// Played forwards off the end of the track.
  bool get ended => position >= frames - 1 && (playing || _follow != null) && _rate >= 0;

  /// Moves the needle to [frame] with a short crossfade.
  void seek(double frame) {
    _fadeFrom = position;
    _fadeLeft = _crossfadeFrames;
    position = frame.clamp(0, math.max(0, frames - 1)).toDouble();
  }

  /// A finger holds the record at [frame], moving at [fingerRate]; null lets go.
  void follow(double? frame, [double fingerRate = 0]) {
    _follow = frame?.clamp(0, math.max(0, frames - 1)).toDouble();
    _followRate = fingerRate;
  }

  /// Repeats [start, end) while set (roll, loop); null ends the loop.
  void loop(double? start, double? end) {
    if (start == null || end == null || end <= start) {
      _loopStart = _loopEnd = null;
    } else {
      _loopStart = start;
      _loopEnd = end;
    }
  }

  /// Fills [out] (interleaved stereo) and advances the needle.
  void render(Int16List out) {
    final n = out.length ~/ 2;
    final slew = rateSlewPerSecond / sampleRate;
    final followGain = 1 / (followSeconds * sampleRate);
    for (var i = 0; i < n; i++) {
      final follow = _follow;
      final target = follow != null
          ? (_followRate + (follow - position) * followGain).clamp(-8.0, 8.0)
          : (playing ? rate : 0.0);
      _rate += (target - _rate).clamp(-slew, slew);
      final audible = math.min(1.0, _rate.abs() / audibleRate);
      _gain += (audible - _gain) * 0.01;

      var l = 0.0, r = 0.0;
      if (_gain > 1e-4) {
        _read(position);
        l = _l;
        r = _r;
        if (_fadeLeft > 0) {
          final w = _fadeLeft / _crossfadeFrames;
          _read(_fadeFrom);
          l = l * (1 - w) + _l * w;
          r = r * (1 - w) + _r * w;
        }
      }
      out[2 * i] = (l * _gain).round().clamp(-32768, 32767);
      out[2 * i + 1] = (r * _gain).round().clamp(-32768, 32767);

      if (_fadeLeft > 0) {
        _fadeLeft--;
        _fadeFrom += _rate;
      }
      position += _rate;
      final loopEnd = _loopEnd;
      if (loopEnd != null && _rate > 0 && position >= loopEnd) {
        final over = position - loopEnd;
        seek(_loopStart! + over);
      }
      if (position < 0) position = 0;
      final last = (frames - 1).toDouble();
      if (position > last) position = math.max(0, last);
    }
  }

  double _l = 0, _r = 0;

  /// Linear interpolation at a fractional frame; silence outside the track.
  void _read(double at) {
    final i = at.floor();
    if (i < 0 || i >= frames - 1) {
      _l = _r = 0;
      return;
    }
    final f = at - i;
    if (channels == 2) {
      final a = 2 * i;
      _l = pcm[a] + (pcm[a + 2] - pcm[a]) * f;
      _r = pcm[a + 1] + (pcm[a + 3] - pcm[a + 1]) * f;
    } else {
      _l = _r = pcm[i] + (pcm[i + 1] - pcm[i]) * f;
    }
  }
}
