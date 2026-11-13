// End-to-end check of the scratch voice in the real engine (handoff 05):
// download → decode → play → backwards → finger → end of track.
//
//   python3 -m http.server 18766 -d <dir with test.mp3> &
//   flutter run -d macos --profile -t tool/spike/voice_spike.dart --dart-define=MP3_URL=http://127.0.0.1:18766/test.mp3
import 'dart:async';
import 'dart:io';

import 'package:dj_deckify/services/audio_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('voice spike…')))));
  void log(String s) => debugPrint('[spike] $s');
  Future<void> wait(int ms) => Future.delayed(Duration(milliseconds: ms));
  String at(Duration d) => '${(d.inMilliseconds / 1000).toStringAsFixed(2)} s';

  await AudioEngine.initSoLoud();
  SoLoud.instance.setGlobalVolume(0); // silent
  final e = AudioEngine.instance;
  final sw = Stopwatch()..start();
  final dsp = await e.loadTrack(1, 'http://127.0.0.1:1/unused.m3u8',
      progressiveUrl: const String.fromEnvironment('MP3_URL'));
  log('loaded in ${sw.elapsedMilliseconds} ms, dsp $dsp, reversible ${e.canReverse(1)}, '
      'duration ${at(e.currentDuration(1)!)}');

  await e.setRate(1, 1);
  await e.play(1);
  await wait(1000);
  log('after 1 s playing: ${at(e.positionSync(1))}');

  await e.setRate(1, -1);
  await wait(500);
  log('after 0.5 s backwards: ${at(e.positionSync(1))}');

  await e.setRate(1, 0);
  final held = e.positionSync(1);
  await wait(300);
  log('held still 0.3 s: ${at(held)} → ${at(e.positionSync(1))}');

  e.follow(1, const Duration(seconds: 5), 0);
  await wait(300);
  log('finger at 5.00 s: ${at(e.positionSync(1))}');
  e.follow(1, null, 0);

  await e.setRate(1, 2);
  await e.seekTo(1, e.currentDuration(1)! - const Duration(seconds: 1));
  var ended = false;
  final sub = e.playerStateStream(1).listen((s) => ended |= s.processingState.name == 'completed');
  await wait(900);
  log('end of track reported: $ended at ${at(e.positionSync(1))}');
  await sub.cancel();
  await e.stop(1);
  exit(0);
}
