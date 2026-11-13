// Spike for handoff 05, part 2: can a Dart producer feed a SoLoud
// BufferStream with low enough latency for scratching?
//
//   flutter run -d macos -t tool/spike/buffer_stream_spike.dart
//   flutter run -d <phone> --profile -t tool/spike/buffer_stream_spike.dart
//
// Prints one line per configuration and exits. Not part of the app.
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

const rate = 44100;
const blockFrames = 256;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('BufferStream spike…')))));
  unawaited(_run());
}

Future<void> _run() async {
  final out = <String>[];
  void log(String s) {
    debugPrint('[spike] $s');
    out.add(s);
  }

  log('platform ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
  for (final mixer in [2048, 512, 256]) {
    await SoLoud.instance.init(bufferSize: mixer);
    // Silent run: the master is muted, voices still mix (a voice at volume 0
    // could be skipped as inaudible and stop consuming).
    SoLoud.instance.setGlobalVolume(0);
    log('--- mixer bufferSize $mixer frames = ${(mixer / rate * 1000).toStringAsFixed(1)} ms');
    if (mixer == 2048) await _filters(log);
    for (final aheadMs in [20, 40, 60, 90]) {
      for (final jank in [false, true]) {
        log(await _measure(aheadMs: aheadMs, jank: jank));
      }
    }
    SoLoud.instance.deinit();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
  File('${Directory.systemTemp.path}/djfy_spike.txt').writeAsStringSync(out.join('\n'));
  log('done');
  exit(0);
}

/// One stream, fed at [aheadMs] ahead of what SoLoud consumed; [jank] blocks
/// the main isolate 30 ms every 400 ms, like a heavy frame.
Future<String> _measure({required int aheadMs, required bool jank}) async {
  var underruns = 0;
  final source = SoLoud.instance.setBufferStream(
    maxBufferSizeDuration: const Duration(seconds: 3),
    bufferingType: BufferingType.released,
    bufferingTimeNeeds: 0.01,
    sampleRate: rate,
    channels: Channels.stereo,
    format: BufferType.s16le,
    onBuffering: (isBuffering, handle, time) {
      if (isBuffering) underruns++;
    },
  );
  var pushedFrames = 0;
  var phase = 0.0;
  Uint8List block() {
    final pcm = Int16List(blockFrames * 2);
    for (var i = 0; i < blockFrames; i++) {
      final v = (math.sin(phase) * 6000).round();
      phase += 2 * math.pi * 440 / rate;
      pcm[2 * i] = v;
      pcm[2 * i + 1] = v;
    }
    pushedFrames += blockFrames;
    return pcm.buffer.asUint8List();
  }

  void fill() {
    final consumed = SoLoud.instance.getStreamTimeConsumed(source).inMicroseconds / 1e6;
    while (pushedFrames / rate - consumed < aheadMs / 1000) {
      SoLoud.instance.addAudioDataStream(source, block());
    }
  }

  // Data must arrive after play(): the handle starts paused for buffering
  // and only an add re-checks it.
  final handle = await SoLoud.instance.play(source);
  fill();
  final aheads = <double>[];
  var worstGapMs = 0.0;
  final sw = Stopwatch()..start();
  var last = 0;
  final timer = Timer.periodic(const Duration(milliseconds: 4), (_) {
    final now = sw.elapsedMicroseconds;
    worstGapMs = math.max(worstGapMs, (now - last) / 1000);
    last = now;
    final consumed = SoLoud.instance.getStreamTimeConsumed(source).inMicroseconds / 1e6;
    aheads.add((pushedFrames / rate - consumed) * 1000);
    fill();
  });
  Timer? jankTimer;
  if (jank) {
    jankTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      final until = sw.elapsedMicroseconds + 30000;
      while (sw.elapsedMicroseconds < until) {}
    });
  }
  await Future<void>.delayed(const Duration(seconds: 5));
  final consumedEnd = SoLoud.instance.getStreamTimeConsumed(source).inMicroseconds / 1e6;
  final wall = sw.elapsedMicroseconds / 1e6;
  timer.cancel();
  jankTimer?.cancel();
  await SoLoud.instance.stop(handle);
  SoLoud.instance.disposeSource(source);
  aheads.sort();
  final median = aheads.isEmpty ? 0 : aheads[aheads.length ~/ 2];
  return 'ahead ${aheadMs.toString().padLeft(2)} ms ${jank ? '+jank' : '     '}: '
      'underruns $underruns, median ahead ${median.toStringAsFixed(1)} ms, '
      'worst timer gap ${worstGapMs.toStringAsFixed(1)} ms, '
      'played ${consumedEnd.toStringAsFixed(2)} s of ${wall.toStringAsFixed(2)} s';
}

/// Filters on a BufferStream source: activate before play, set per handle.
Future<void> _filters(void Function(String) log) async {
  final source = SoLoud.instance.setBufferStream(
    sampleRate: rate,
    channels: Channels.stereo,
    format: BufferType.s16le,
    bufferingTimeNeeds: 0.01,
    bufferingType: BufferingType.released,
  );
  try {
    source.filters.echoFilter.activate();
    source.filters.biquadFilter.activate();
    SoLoud.instance.addAudioDataStream(source, Uint8List(blockFrames * 4 * 40));
    final h = await SoLoud.instance.play(source);
    source.filters.echoFilter.wet(soundHandle: h).value = 0.5;
    source.filters.biquadFilter.frequency(soundHandle: h).value = 800;
    log('filters on BufferStream: echo wet ${source.filters.echoFilter.wet(soundHandle: h).value}, '
        'biquad freq ${source.filters.biquadFilter.frequency(soundHandle: h).value}');
    await SoLoud.instance.stop(h);
  } catch (e) {
    log('filters on BufferStream FAILED: $e');
  }
  SoLoud.instance.disposeSource(source);
}
