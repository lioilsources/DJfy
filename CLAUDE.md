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

- `just_audio` for playback (cross-platform, OGG/MP3 support)
- Tempo/BPM matching for smart playlist ordering

## Platforms

iOS, Android. (Docs list macOS as well — check pubspec for active targets.)
