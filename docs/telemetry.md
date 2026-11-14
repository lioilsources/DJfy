# Anonymous usage statistics

DJfy sends a small set of anonymous events through the shared
[`ol1n_telemetry`](https://github.com/lioilsources/Ol1nTelemetry) client, so
the owner can see what new users do after the first launch, where a search or
a track load fails, how long people stay, and which deck and party features
the regulars actually use. This file is the **event dictionary**: the
constant `djfyDictionary` (`lib/telemetry/telemetry_dictionary.dart`) and this
document list exactly the same events and properties, and
`test/telemetry_test.dart` fails when they drift apart. The plan behind it is
`DevConventions/Prompts/04-PLAN-analytika.md`.

Adding an event or a property is a change to the privacy policy
(`docs/privacy.html`) and to the store privacy answers. Ask the owner first.

## Rules

The rules of `ol1n_telemetry` apply unchanged: no persistent identifier,
cohorts computed on the device, only enums, bands and numbers, no key → no
network, off wipes the queue at once, measuring never steers the app. See
the package README.

For DJfy in particular:

- **Nothing about the music.** No track, artist, title, BPM value, search
  text, playlist, party name, party code, guest name or guest id ever leaves
  the device through the statistics. Only fixed lists (`mode`, `source`,
  `engine`, `fx`, `query_kind`) and counts.
- **Statistics only go to the owner's collector** (StoreMetrics, protocol v1).
  They never go through the party relay, and the relay knows nothing about
  them.
- Without `TELEMETRY_KEY` and an `https` `TELEMETRY_HOST` the build is silent
  and the settings button in the top bar is hidden (the statistics switch is
  its only setting).

## Configuration

| `--dart-define` | Meaning |
|---|---|
| `TELEMETRY_KEY` | DJfy's key at the collector (`X-Telemetry-Key`). Empty → nothing is sent. |
| `TELEMETRY_HOST` | The collector's base address, `https`. Empty → nothing is sent. |
| `TELEMETRY_DEBUG` | `true` prints events to the console instead of sending them. |
| `TESTER_BUILD` | `true` marks the build as a tester's (`tester: true`). Set for the Firebase App Distribution APK. |

The release workflows (`release-android`, `release-ios`, `release-macos`)
pass both from the GitHub secrets of the same names. The key and the
collector's address never go into this public repository.

Check a session by hand: `flutter run --dart-define=TELEMETRY_DEBUG=true`.

## Screens

| Screen | Route |
|---|---|
| `home` | `/`: smart playlist and decks |
| `party` | `/party`: start, live party (queue, guests, search) |
| `settings` | `/settings`: the statistics switch |

Dialogs and sheets (QR, mood lock) do not change the screen.

## Activation

The first track that has played for 30 seconds on any deck (solo or at a
party; `track_play`). DJfy has no "finished mix" outside a party with
Auto-DJ, so the first track that really plays is the first real use for
everyone.

## Features

`fx`, `scratch`, `eq`, `pitch`, `crossfader`, `multi_deck`, `tap_beat`,
`slip`, `party`, `auto_dj`, `mood_lock`, `co_dj`.

| Feature | When |
|---|---|
| `fx` | a finger on the FX pad |
| `scratch` | a finger on the platter |
| `eq` | an EQ kill switch toggled |
| `pitch` | the tempo slider or a nudge button |
| `crossfader` | the crossfader moved by hand |
| `multi_deck` | PŘIDAT DECK |
| `tap_beat` | TAP set the beat grid |
| `slip` | slip mode toggled |
| `party` | a party started |
| `auto_dj` | Auto-DJ switched on |
| `mood_lock` | a mood lock set |
| `co_dj` | a guest made co-DJ |

## Common properties

Sent with every event.

| Property | Type | Values |
|---|---|---|
| `app_version` | enum | the app version (`kAppVersion`, checked against `pubspec.yaml`) |
| `platform` | enum | `ios`, `android`, `macos`, `windows`, `linux`, `other` |
| `lang` | enum | the app's language: `cs` |
| `session_band` | band | session number: `1`, `2`, `3-5`, `6-10`, `11+` |
| `days_band` | band | days since measuring began: `0`, `1`, `2-6`, `7-29`, `30+`, `pre` |
| `first_session` | bool | the very first session of a new install |
| `tester` | bool | tester build or tester device |
| `mode` | enum | `solo`, `party` (a party is running) |

## Events

### `app_open`

Cold start, or a new session after more than 30 minutes in the background.
Answers: what a new user does after the first launch, and whether they come
back (2nd, 3rd, 6th, 11th session; day 1, 2, 7, 30).

| Property | Type | Values |
|---|---|---|
| `start` | enum | `cold`, `resume` |
| `session_band_first` | bool | the first session of this install in its `session_band` |
| `days_band_first` | bool | the first session of this install in its `days_band` |
| `campaign` | campaign | optional; QR campaign of a new install, `^[a-z0-9-]{1,24}$` (DJfy sends none today) |

### `screen_view`

A screen appeared. Answers: the path through the app in the first session.

| Property | Type | Values |
|---|---|---|
| `screen` | enum | `home`, `party`, `settings`, `other` |
| `prev` | enum | the previous screen, or `none` |

### `screen_leave`

A screen was left. Answers: how long people stay on each screen, and screens
with a long stay but no action.

| Property | Type | Values |
|---|---|---|
| `screen` | enum | as in `screen_view` |
| `secs` | int | foreground seconds on the screen |
| `actions` | int | app events, feature uses and locked taps during the stay |

### `session_pause`

The app went to the background or is closing. Sent at once. Answers: when
and where people stop.

| Property | Type | Values |
|---|---|---|
| `active_secs` | int | foreground seconds in this session |
| `screen` | enum | the screen at the time, or `none` |
| `screen_secs` | int | foreground seconds on that screen |

### `activation`

The first track that played for 30 seconds on this install. Once per
install. Answers: how many new users get to real use, and how fast.

| Property | Type | Values |
|---|---|---|
| `secs` | int | seconds since this session's `app_open` |

### `feature_use`

The first use of a feature in a session. Answers: what regulars use.

| Property | Type | Values |
|---|---|---|
| `feature` | enum | `fx`, `scratch`, `eq`, `pitch`, `crossfader`, `multi_deck`, `tap_beat`, `slip`, `party`, `auto_dj`, `mood_lock`, `co_dj` |

### `feature_snapshot`

After `app_open` of the 3rd, 6th and 11th session: which features this
install has ever used. Answers: what regulars never touch.

| Property | Type | Values |
|---|---|---|
| `f_fx` | bool | FX pad used |
| `f_scratch` | bool | platter scratched |
| `f_eq` | bool | EQ kill used |
| `f_pitch` | bool | tempo slider or nudge used |
| `f_crossfader` | bool | crossfader moved by hand |
| `f_multi_deck` | bool | a deck added |
| `f_tap_beat` | bool | TAP used |
| `f_slip` | bool | slip mode toggled |
| `f_party` | bool | a party started |
| `f_auto_dj` | bool | Auto-DJ switched on |
| `f_mood_lock` | bool | a mood lock set |
| `f_co_dj` | bool | a co-DJ appointed |
| `features_used` | int | how many of them |

### `error_shown`

The user saw an error. Answers: where people struggle.

| Property | Type | Values |
|---|---|---|
| `kind` | enum | `search` (smart playlist search failed), `no_results` (nothing found), `no_stream` (track has no stream), `track_load` (a deck could not load the track), `relay` (party relay unavailable or lost), `party_track` (a party track could not play and was skipped), `queue_empty` (Next on an empty party queue) |
| `screen` | enum | the screen at the time, or `none` |

### `locked_tap`

A tap on something unavailable. Answers: which features people want but
cannot use, and why.

| Property | Type | Values |
|---|---|---|
| `target` | enum | `fx_no_dsp` (FX on a stream without DSP), `fx_no_bpm` (roll or beatskip without a known BPM), `fx_no_pcm` (spin on a deck not decoded to memory), `eq_no_dsp` (EQ on a stream without DSP) |

### `playlist_search_start`

A smart playlist search began. Only the shape of the query is sent, never
its text. Answers: whether the first thing new users do works.

| Property | Type | Values |
|---|---|---|
| `query_kind` | enum | `artist`, `artist_title` (`Artist - Song`) |

### `playlist_search_end`

The search ended. Answers: how often it finds nothing or fails, how long it
takes, and how many results can actually be played.

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel`, `error`, `background`, `empty` |
| `secs` | int | foreground seconds |
| `tracks` | int | tracks found (seed included) |
| `playable` | int | of them with a stream |
| `with_bpm` | int | of them with a known BPM |

### `track_load_start`

A track is being loaded onto a deck. Answers, with `track_load_end`: how
often and how long loading takes, and where it fails.

| Property | Type | Values |
|---|---|---|
| `source` | enum | `playlist` (dragged from the smart playlist), `party` (the party queue) |

### `track_load_end`

The load ended.

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel` (replaced by another track or ejected), `error`, `background`, `no_stream` |
| `secs` | int | foreground seconds |
| `engine` | enum | `pcm` (decoded: scratch, FX, reverse), `soloud` (DSP, no reverse), `stream` (no DSP), `none` (not loaded) |

### `track_play`

A loaded track has played for 30 seconds. Once per load. Answers: how much
music is really played per session, solo or at a party, and on which audio
path.

| Property | Type | Values |
|---|---|---|
| `source` | enum | `playlist`, `party` |
| `engine` | enum | `pcm`, `soloud`, `stream` |

### `fx_use`

An effect was played on the pad. Once per effect and loaded track. Answers:
which effects regulars use and which nobody does.

| Property | Type | Values |
|---|---|---|
| `fx` | enum | `hi_lo`, `echo`, `reverb`, `crush`, `roll`, `beatskip`, `brake`, `spin` |

### `party_start`

ZALOŽIT PARTY was pressed. Answers, with `party_end`: how many parties start,
fail on the relay, and how long and how lively they are.

| Property | Type | Values |
|---|---|---|

### `party_end`

The party ended. `secs` is wall time (a party mostly runs with the screen
locked), not foreground time.

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok` (host ended it), `cancel`, `error` (relay unavailable or lost), `background` (the app was closed mid-party) |
| `secs` | int | seconds since the start |
| `guests` | int | guests who joined |
| `tracks` | int | tracks that went on air |
| `host_tracks` | int | tracks the host added |
| `guest_tracks` | int | tracks guests added |
| `auto_tracks` | int | tracks the endless party added |
| `votes` | int | votes from guests |

## Reading the data

`store-metrics report djfy` on JODA (plan §5.4). Tester builds
(`tester: true`) are left out by default.
