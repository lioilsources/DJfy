# DJDeckify — CLAUDE.md

## Overview

Flutter mobile DJ app with smart playlist generation. Integrates Last.fm (scrobbling/recommendations), GetSongBPM (tempo data), and SoundCloud (streaming). Audio via `just_audio`.

## Commands

```bash
flutter pub get
flutter run -d ios
flutter run -d android
flutter build ios
flutter build apk
flutter analyze
```

## Architecture

```
lib/
├── main.dart
├── app/
│   ├── app.dart             # App root
│   └── theme.dart
├── features/
│   ├── deck/                # DJ deck UI (turntable, controls)
│   ├── playlist/            # Smart playlist management
│   ├── search/              # Track search
│   ├── library/             # Local/saved library
│   └── settings/
├── models/                  # Track, playlist, deck state models
└── (core/, services/?)      # API clients, audio engine
```

## External APIs

| Service | Purpose |
|---------|---------|
| Last.fm | Track recommendations, scrobbling |
| GetSongBPM | BPM data for tempo matching |
| SoundCloud | Track streaming |

## Audio

- Dual engine (`lib/services/audio_engine.dart`): progressive MP3 → `flutter_soloud` (real-time DSP: EQ kills, FX pad), HLS → `just_audio` fallback (no DSP)
- SoLoud filters must be activated BEFORE `play()`, and every param call needs `soundHandle:` (otherwise it targets the inactive global chain)
- SoLoud's 8-band EqFilter uses sqrt-warped FFT bands: band k covers (k/8)²…((k+1)/8)² of Nyquist (band1 = 0–344 Hz @ 44.1 kHz), NOT octave bands
- Beat grid for Roll/Beatskip/Echo sync: `lib/core/beat_clock.dart` (BPM from GetSongBPM)
- Tempo/BPM matching for smart playlist ordering

## Platforms

iOS, Android. (Docs list macOS as well — check pubspec for active targets.)
