import 'dart:math' as math;
import 'dart:typed_data';

/// What the deck shows and the beat grid needs, computed once per track from
/// its decoded PCM (in a background isolate: a few hundred ms per track).
class TrackAnalysis {
  /// Waveform: loudest sample per [peakWindow], 0–255 relative to the track.
  final Uint8List peaks;

  /// Onset strength per [onsetWindow]: how much louder it got (energy flux).
  final Float32List onsets;

  const TrackAnalysis(this.peaks, this.onsets);

  static const peaksPerSecond = 20;
  static const onsetsPerSecond = 100;
  static const peakWindow = Duration(microseconds: 1000000 ~/ peaksPerSecond);
  static const onsetWindow = Duration(microseconds: 1000000 ~/ onsetsPerSecond);

  static TrackAnalysis of(Int16List pcm, {required int channels, required int sampleRate}) {
    final frames = pcm.length ~/ channels;

    final peakFrames = sampleRate ~/ peaksPerSecond;
    final rawPeaks = Uint16List((frames / peakFrames).ceil());
    var loudest = 1;
    for (var w = 0; w < rawPeaks.length; w++) {
      final end = math.min(frames, (w + 1) * peakFrames) * channels;
      var peak = 0;
      for (var i = w * peakFrames * channels; i < end; i++) {
        final v = pcm[i].abs();
        if (v > peak) peak = v;
      }
      rawPeaks[w] = peak;
      if (peak > loudest) loudest = peak;
    }
    final peaks = Uint8List(rawPeaks.length);
    for (var w = 0; w < peaks.length; w++) {
      peaks[w] = rawPeaks[w] * 255 ~/ loudest;
    }

    final onsetFrames = sampleRate ~/ onsetsPerSecond;
    final onsets = Float32List((frames / onsetFrames).floor());
    var previous = 0.0;
    for (var w = 0; w < onsets.length; w++) {
      var energy = 0.0;
      final end = (w + 1) * onsetFrames * channels;
      for (var i = w * onsetFrames * channels; i < end; i++) {
        final v = pcm[i] / 32768;
        energy += v * v;
      }
      final level = math.log(1e-6 + energy / (onsetFrames * channels));
      onsets[w] = w == 0 ? 0 : math.max(0, level - previous);
      previous = level;
    }
    return TrackAnalysis(peaks, onsets);
  }

  /// Where the beat grid starts for [bpm]: the phase whose beats line up
  /// with the most onsets. Null when the track is too quiet to tell.
  Duration? beatOffset(double bpm) {
    if (bpm <= 0 || onsets.isEmpty) return null;
    final period = 60 / bpm * onsetsPerSecond; // in onset windows, fractional
    final steps = period.floor();
    if (steps < 2) return null;
    final scores = Float64List(steps);
    for (var phase = 0; phase < steps; phase++) {
      var sum = 0.0;
      for (var t = phase.toDouble(); t < onsets.length; t += period) {
        sum += onsets[t.round().clamp(0, onsets.length - 1)];
      }
      scores[phase] = sum;
    }
    var best = 0;
    for (var p = 1; p < steps; p++) {
      if (scores[p] > scores[best]) best = p;
    }
    final mean = scores.reduce((a, b) => a + b) / steps;
    if (scores[best] <= mean * 1.2) return null; // no clear pulse

    // Parabolic refinement between neighbouring phases.
    final l = scores[(best - 1 + steps) % steps], c = scores[best], r = scores[(best + 1) % steps];
    final denom = l - 2 * c + r;
    final shift = denom == 0 ? 0.0 : 0.5 * (l - r) / denom;
    final phase = (best + shift.clamp(-0.5, 0.5)) % period;
    return Duration(microseconds: (phase / onsetsPerSecond * 1e6).round());
  }
}
