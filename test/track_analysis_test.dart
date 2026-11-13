import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dj_deckify/core/track_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

const rate = 8000;

/// Stereo clicks: a short decaying burst on every beat, starting at [offset].
Int16List clicks({required double bpm, required Duration offset, int seconds = 30}) {
  final pcm = Int16List(rate * seconds * 2);
  final beat = 60 / bpm * rate;
  for (var t = offset.inMicroseconds / 1e6 * rate; t < rate * seconds; t += beat) {
    for (var i = 0; i < 200 && t + i < rate * seconds; i++) {
      final v = (math.sin(i * 0.9) * 20000 * math.exp(-i / 40)).round();
      final at = (t.round() + i) * 2;
      pcm[at] = v;
      pcm[at + 1] = v;
    }
  }
  return pcm;
}

void main() {
  test('finds the phase of the beat', () {
    for (final offset in [0, 120, 333]) {
      final a = TrackAnalysis.of(
        clicks(bpm: 120, offset: Duration(milliseconds: offset)),
        channels: 2,
        sampleRate: rate,
      );
      final found = a.beatOffset(120)!;
      expect(found.inMilliseconds, closeTo(offset, 12), reason: 'offset $offset ms');
    }
  });

  test('silence has no beat', () {
    final a = TrackAnalysis.of(Int16List(rate * 10 * 2), channels: 2, sampleRate: rate);
    expect(a.beatOffset(120), isNull);
  });

  test('peaks are 20 per second, scaled to the loudest moment', () {
    final pcm = Int16List(rate * 2 * 2);
    for (var i = 0; i < rate; i++) {
      pcm[2 * i] = 1000; // first second quiet
    }
    for (var i = rate; i < rate * 2; i++) {
      pcm[2 * i + 1] = -10000; // second second loud, right channel only
    }
    final a = TrackAnalysis.of(pcm, channels: 2, sampleRate: rate);
    expect(a.peaks, hasLength(40));
    expect(a.peaks.first, 25);
    expect(a.peaks.last, 255);
  });
}
