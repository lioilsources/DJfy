import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app/app.dart';
import 'core/cache_service.dart';
import 'services/audio_engine.dart';
import 'services/bpm_service.dart';
import 'services/jamendo_service.dart';
import 'services/lastfm_service.dart';
import 'services/relay_client.dart';
import 'services/soundcloud_service.dart';
import 'telemetry/telemetry_dictionary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _startTelemetry();
  // Playback category: keep playing with the screen locked (party mode streams
  // through just_audio, which doesn't configure the iOS audio session itself).
  await (await AudioSession.instance).configure(const AudioSessionConfiguration.music());
  await AudioEngine.initSoLoud();
  await _setupServices();
  runApp(const DjDeckifyApp());
}

Future<void> _setupServices() async {
  final cache = CacheService();
  await cache.init();

  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  GetIt.I
    ..registerSingleton(cache)
    ..registerSingleton(LastFmService(dio))
    ..registerSingleton(JamendoService(dio))
    ..registerSingleton(SoundCloudService(dio)) // ready for when approved
    ..registerSingleton(BpmService(dio, cache))
    ..registerSingleton(AudioEngine.instance)
    ..registerSingleton(RelayClient());
}

/// Anonymous usage statistics (`docs/telemetry.md`). Silent without
/// TELEMETRY_KEY and TELEMETRY_HOST; never makes the app wait.
Future<void> _startTelemetry() async {
  try {
    // Asked before CacheService creates the BPM cache: a cache from an
    // earlier launch means DJfy was used before measuring began.
    final docs = await getApplicationDocumentsDirectory();
    final usedBefore = File(p.join(docs.path, CacheService.fileName)).existsSync();
    final support = await getApplicationSupportDirectory();
    unawaited(Telemetry.init(
      app: kTelemetryApp,
      appVersion: kAppVersion,
      dictionary: djfyDictionary,
      store: FileTelemetryStore(p.join(support.path, 'telemetry')),
      lang: () => 'cs',
      tester: kTesterBuild,
      hadDataBefore: () => usedBefore,
      common: () => {'mode': telemetryMode},
    ));
  } catch (_) {
    // No directory, no statistics; the app runs as before.
  }
}
