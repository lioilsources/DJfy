// Spike for handoff 05, part 2.2: decode time and memory of a whole track.
//
//   flutter run -d macos --profile -t tool/spike/decode_spike.dart --dart-define=MP3=/path/to/file.mp3
import 'dart:io';
import 'dart:math' as math;

import 'package:djfy_decoder/djfy_decoder.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('decode spike…')))));
  const path = String.fromEnvironment('MP3');
  final bytes = File(path).readAsBytesSync();
  final rssBefore = ProcessInfo.currentRss;
  final sw = Stopwatch()..start();
  final pcm = await decodeMp3(bytes);
  final ms = sw.elapsedMilliseconds;
  if (pcm == null) {
    debugPrint('[spike] decode FAILED');
    exit(1);
  }
  // Left and right must differ (440 vs 660 Hz): proves real stereo.
  var diff = 0, peak = 0;
  for (var i = 0; i < 44100 * 2; i += 2) {
    diff += (pcm.samples[i] - pcm.samples[i + 1]).abs();
    peak = math.max(peak, pcm.samples[i].abs());
  }
  debugPrint('[spike] ${bytes.length ~/ 1024} KiB mp3 → ${pcm.channels} ch ${pcm.sampleRate} Hz, '
      '${pcm.duration.inSeconds} s, ${pcm.samples.lengthInBytes ~/ (1 << 20)} MiB PCM in $ms ms; '
      'RSS +${(ProcessInfo.currentRss - rssBefore) ~/ (1 << 20)} MiB; L≠R ${diff > 0}, peak $peak');
  exit(0);
}
