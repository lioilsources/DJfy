import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'app/app.dart';
import 'core/cache_service.dart';
import 'services/audio_engine.dart';
import 'services/bpm_service.dart';
import 'services/jamendo_service.dart';
import 'services/lastfm_service.dart';
import 'services/soundcloud_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    ..registerSingleton(AudioEngine.instance);
}
