import 'package:flutter/foundation.dart';
import 'constants.dart';

/// Verifies API credentials were injected at build time via
/// `--dart-define` / `--dart-define-from-file=env.json`.
///
/// These are compile-time constants (`String.fromEnvironment`), so a missing
/// key silently becomes `''` and every API call fails quietly (SC auth 401,
/// Last.fm "Invalid API key" → empty results → "Nic nenalezeno"). This surfaces
/// the problem loudly at startup instead of leaving you to guess.
void checkEnv() {
  final missing = <String>[
    if (kLastFmApiKey.isEmpty) 'LASTFM_API_KEY',
    if (kGetSongBpmKey.isEmpty) 'GETSONGBPM_KEY',
    if (kJamendoClientId.isEmpty) 'JAMENDO_CLIENT_ID',
    if (kTokenProxyUrl.isEmpty) 'TOKEN_PROXY_URL',
    if (kProxyApiKey.isEmpty) 'PROXY_API_KEY',
  ];

  if (missing.isEmpty) {
    debugPrint('[env] all API credentials present ✓');
    return;
  }

  debugPrint('');
  debugPrint('┌── MISSING API CREDENTIALS ─────────────────────────────────');
  for (final key in missing) {
    debugPrint('│  ✗ $key');
  }
  debugPrint('│');
  debugPrint('│  These come from env.json at build time and are empty now,');
  debugPrint('│  so the related API calls will fail silently.');
  debugPrint('│');
  debugPrint('│  Run with:  flutter run --dart-define-from-file=env.json');
  debugPrint('│  (VS Code: pick the "DJfy (debug)" launch config)');
  debugPrint('│  Fill the keys in env.json — see env.example.json.');
  debugPrint('└────────────────────────────────────────────────────────────');
  debugPrint('');
}
