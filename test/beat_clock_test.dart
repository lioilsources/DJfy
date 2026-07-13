import 'package:dj_deckify/core/beat_clock.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStopwatch extends Stopwatch {
  int us = 0;

  @override
  int get elapsedMicroseconds => us;
}

void main() {
  group('BeatClock', () {
    test('beatDuration is track-time, independent of speed', () {
      final clock = BeatClock(bpm: 120, speed: 1.3);
      expect(clock.beatDuration, const Duration(milliseconds: 500));
    });

    test('wallBeatDuration scales with speed', () {
      final clock = BeatClock(bpm: 120, speed: 2.0);
      expect(clock.wallBeatDuration, const Duration(milliseconds: 250));
    });

    test('falls back to 120 bpm on null or invalid bpm', () {
      expect(BeatClock().bpm, 120);
      final clock = BeatClock(bpm: 90)..bpm = null;
      expect(clock.bpm, 120);
      clock.bpm = -5;
      expect(clock.bpm, 120);
    });

    test('quantizeToBeat snaps to the nearest grid point', () {
      final clock = BeatClock(bpm: 120); // beat = 500 ms
      expect(
        clock.quantizeToBeat(const Duration(milliseconds: 1240)),
        const Duration(milliseconds: 1000),
      );
      expect(
        clock.quantizeToBeat(const Duration(milliseconds: 1260)),
        const Duration(milliseconds: 1500),
      );
    });

    test('estimatedPosition extrapolates while playing', () {
      final sw = _FakeStopwatch();
      final clock = BeatClock(bpm: 120, stopwatch: sw)..playing = true;
      clock.anchor(const Duration(seconds: 10));
      sw.us += 300000; // 300 ms wall time
      expect(
        clock.estimatedPosition,
        const Duration(seconds: 10, milliseconds: 300),
      );
    });

    test('estimatedPosition scales wall time by playback speed', () {
      final sw = _FakeStopwatch();
      final clock = BeatClock(bpm: 120, speed: 0.5, stopwatch: sw)
        ..playing = true;
      clock.anchor(Duration.zero);
      sw.us += 1000000; // 1 s wall = 0.5 s track at half speed
      expect(clock.estimatedPosition, const Duration(milliseconds: 500));
    });

    test('estimatedPosition holds still while paused', () {
      final sw = _FakeStopwatch();
      final clock = BeatClock(bpm: 120, stopwatch: sw)..playing = false;
      clock.anchor(const Duration(seconds: 5));
      sw.us += 700000;
      expect(clock.estimatedPosition, const Duration(seconds: 5));
    });
  });
}
