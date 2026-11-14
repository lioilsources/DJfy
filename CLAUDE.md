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

- Engine (`lib/services/audio_engine.dart`), three paths: progressive MP3, or SoundCloud's MP3 HLS (it no longer serves progressive MP3s; `/streams` only has `hls_mp3_128_url`, so the segments are fetched 6 at a time and joined) → downloaded, decoded to PCM (`packages/djfy_decoder`, dr_mp3 via FFI) and played by a `ScratchVoice` (our own playhead, `lib/core/scratch_renderer.dart`, into a SoLoud buffer stream: scratch, backwards, sample-accurate loops, filters); if decoding fails → SoLoud `loadUrl` (DSP, no reverse); AAC HLS or a failed download → `just_audio` (no DSP). Max 4 PCM decks (~10 MB per minute of track). Party loads take PCM only if it's ready within 8 s.
- SoLoud mixer runs at 512 frames (`AudioEngine.mixerBufferFrames`): the 2048 default adds ~46 ms to every touch.
- `ScratchVoice` keeps 40–120 ms of audio ahead of what SoLoud has played (1.5 s in the background). Never `setPause` a buffer-stream voice (SoLoud toggles it while buffering); data must be added after `play()`; after an underrun the stream stays paused until more data arrives. Spike numbers and the open device check (60 ms limit, else move the producer to C) are in `Prompts/05-SCRATCH_DECK_AND_FX.md`.
- Platter (`lib/core/platter.dart`): 33⅓ rpm, one turn = 1.8 s of track; touch stops the record, the finger's speed is the playback rate, release spins up (τ 0.1 s), brake/backspin coast. `AudioEngine.setRate` is signed; decks that can't reverse are muted when held and pulled back with seeks.
- Deck widget tickers (platter, waveform) are created in `initState`, never lazily: a lazy `createTicker` first called from `dispose()` asserts.
- SoLoud filters must be activated BEFORE `play()`, and every param call needs `soundHandle:` (otherwise it targets the inactive global chain)
- SoLoud's 8-band EqFilter uses sqrt-warped FFT bands: band k covers (k/8)²…((k+1)/8)² of Nyquist (band1 = 0–344 Hz @ 44.1 kHz), NOT octave bands
- never `await` just_audio's `play()`: it completes when the track ends. `AudioEngine.play` returns right away.
- Beat grid for Roll/Beatskip/Echo sync: `lib/core/beat_clock.dart` (BPM from GetSongBPM, phase `offset` detected by `lib/core/track_analysis.dart` from onsets, or set with TAP)
- Tempo/BPM matching for smart playlist ordering

## Party mode (Prompts/01-PARTY_PLAN.md)

- Host phone = source of truth (queue, votes, bans, playback); `services/djfy/` Go relay only forwards (SSE down, POST up) and caches the last snapshot. Guest PWA is embedded in the relay (`services/djfy/web/`, plain JS, no build step).
- `lib/features/party/`: `PartyCubit` (app-level, survives leaving the screen), `PartyPlayer` (plays on decks 1/2 from `DeckRegistry`, which alternate; streaming via just_audio; every track change goes through one cancellable `_transition`; the queue only changes once a track is on air; Auto-DJ = moving the real crossfader + ±8 % beatmatch), `airplay_button.dart` → `djfy/airplay` platform view in `ios/Runner/AppDelegate.swift`.
- `lib/features/party/auto_picker.dart`: when no playable track is left ~90 s before the end (or after Next on an empty queue), adds one `🤖 Auto` track: Last.fm similar → artist top tracks → SoundCloud by artist → replay from history. Auto entries rank after anything people added; vetoed or failed tracks are never picked again that party. Switch `NEKONČIT`, on by default.
- `lib/core/smart_queue.dart`: score = votes × freshness × BPM compatibility × mood lock; pinned entries first.
- Guests reference tracks only by id from the host's own search results (no injected URLs).
- Relay URL: `--dart-define=DJFY_RELAY_URL=…` (default `https://djfy.ol1n.com`); relay port 8097 (8095 is taken by webtoon).

## Platforms

iOS, Android. (Docs list macOS as well — check pubspec for active targets.)
