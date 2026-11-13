import 'dart:typed_data';

import 'package:dj_deckify/core/scratch_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stereo ramp: left = frame index, right = −frame index.
ScratchRenderer ramp(int frames) {
  final pcm = Int16List(frames * 2);
  for (var i = 0; i < frames; i++) {
    pcm[2 * i] = i;
    pcm[2 * i + 1] = -i;
  }
  return ScratchRenderer(pcm, channels: 2, sampleRate: 1000);
}

Int16List render(ScratchRenderer r, int frames) {
  final out = Int16List(frames * 2);
  r.render(out);
  return out;
}

/// Runs until the rate and gain smoothing have settled.
void settle(ScratchRenderer r) => render(r, 2000);

void main() {
  test('at rate 1 it plays the track as is, in stereo', () {
    final r = ramp(20000)
      ..playing = true
      ..rate = 1;
    settle(r);
    final at = r.position;
    final out = render(r, 4);
    expect(out[0], closeTo(at, 1));
    expect(out[2] - out[0], 1);
    expect(out[1], -out[0]);
    expect(r.position, at + 4);
  });

  test('backwards plays the track in reverse', () {
    final r = ramp(20000)
      ..position = 10000
      ..playing = true
      ..rate = -1;
    settle(r);
    final out = render(r, 4);
    expect(out[2] - out[0], -1);
  });

  test('half speed interpolates between samples', () {
    final r = ramp(20000)
      ..playing = true
      ..rate = 0.5;
    settle(r);
    final out = render(r, 4);
    final steps = [for (var i = 1; i < 4; i++) out[2 * i] - out[2 * i - 2]];
    expect(steps.reduce((a, b) => a + b), inInclusiveRange(1, 2));
    expect(r.currentRate, closeTo(0.5, 1e-9));
  });

  test('stopping fades to silence instead of clicking', () {
    final r = ramp(20000)
      ..position = 5000
      ..playing = true;
    settle(r);
    r.playing = false;
    final out = render(r, 200);
    for (var i = 1; i < 200; i++) {
      expect((out[2 * i] - out[2 * i - 2]).abs(), lessThan(200), reason: 'jump at $i');
    }
    expect(render(r, 2000).sublist(3000).every((s) => s == 0), isTrue);
  });

  test('a seek crossfades from the old place to the new one', () {
    final r = ramp(20000)
      ..position = 1000
      ..playing = true;
    settle(r);
    r.seek(15000);
    final out = render(r, 3);
    expect(out[0], lessThan(10000)); // still mostly the old place
    final after = render(r, 10);
    expect(after.last.abs(), greaterThan(15000));
  });

  test('a finger pulls the needle to it, wherever the record was going', () {
    final r = ramp(20000)
      ..position = 5000
      ..playing = true;
    settle(r);
    r.follow(4000, -1);
    render(r, 500);
    expect(r.position, closeTo(4000, 30));
    r.follow(null);
    settle(r);
    expect(r.currentRate, 1);
  });

  test('a loop repeats its slice', () {
    final r = ramp(20000)
      ..position = 100
      ..playing = true
      ..rate = 1;
    settle(r);
    final start = r.position;
    r.loop(start, start + 50);
    render(r, 120);
    expect(r.position, inInclusiveRange(start, start + 50));
    r.loop(null, null);
    render(r, 100);
    expect(r.position, greaterThan(start + 50));
  });

  test('playing off the end stops there', () {
    final r = ramp(1000)
      ..position = 990
      ..playing = true;
    settle(r);
    expect(r.ended, isTrue);
    expect(r.position, 999);
  });

  test('mono tracks come out on both channels', () {
    final pcm = Int16List.fromList(List.generate(5000, (i) => i));
    final r = ScratchRenderer(pcm, channels: 1, sampleRate: 1000)..playing = true;
    settle(r);
    final out = render(r, 2);
    expect(out[0], out[1]);
  });
}
