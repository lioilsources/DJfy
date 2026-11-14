import 'package:ol1n_telemetry/ol1n_telemetry.dart';

import '../models/fx.dart';

/// The app version this build reports; `test/telemetry_test.dart` keeps it
/// equal to `version:` in `pubspec.yaml`.
const kAppVersion = '1.4.0';

/// The app id at the collector (`apps.yaml` in StoreMetrics).
const kTelemetryApp = 'djfy';

/// Firebase App Distribution builds pass `--dart-define=TESTER_BUILD=true`.
const kTesterBuild = bool.fromEnvironment('TESTER_BUILD');

/// Route name → screen. Unnamed routes report `other`.
const kScreenRoutes = {
  '/': 'home',
  '/party': 'party',
  '/settings': 'settings',
};

/// Telemetry id of each effect: a fixed list, never a track or a name.
String fxId(FxType type) => switch (type) {
      FxType.hiLo => 'hi_lo',
      FxType.echo => 'echo',
      FxType.reverb => 'reverb',
      FxType.crush => 'crush',
      FxType.roll => 'roll',
      FxType.beatskip => 'beatskip',
      FxType.brake => 'brake',
      FxType.spin => 'spin',
    };

/// Solo decks or a party; sent with every event as `mode`. The app only
/// writes it, nothing reads it back (measuring never steers the app).
String telemetryMode = 'solo';

const _source = EnumProp({'playlist', 'party'});
const _engine = EnumProp({'pcm', 'soloud', 'stream'});
const _count = IntProp(10000);

/// The one event dictionary of DJfy, mirrored in `docs/telemetry.md`.
final djfyDictionary = TelemetryDictionary(
  appVersion: kAppVersion,
  languages: {'cs'},
  screens: kScreenRoutes.values.toSet(),
  features: {
    'fx',
    'scratch',
    'eq',
    'pitch',
    'crossfader',
    'multi_deck',
    'tap_beat',
    'slip',
    'party',
    'auto_dj',
    'mood_lock',
    'co_dj',
  },
  errorKinds: {
    'search',
    'no_results',
    'no_stream',
    'track_load',
    'relay',
    'party_track',
    'queue_empty',
  },
  lockedTargets: {'fx_no_dsp', 'fx_no_bpm', 'fx_no_pcm', 'eq_no_dsp'},
  common: {
    'mode': const EnumProp({'solo', 'party'}),
  },
  events: {
    ...TelemetryDictionary.flow('playlist_search',
        results: {'empty'},
        start: {'query_kind': const EnumProp({'artist', 'artist_title'})},
        end: {'tracks': _count, 'playable': _count, 'with_bpm': _count}),
    ...TelemetryDictionary.flow('track_load',
        results: {'no_stream'},
        start: {'source': _source},
        end: {'engine': const EnumProp({'pcm', 'soloud', 'stream', 'none'})}),
    'track_play': {'source': _source, 'engine': _engine},
    'fx_use': {
      'fx': EnumProp({for (final t in FxType.values) fxId(t)}),
    },
    ...TelemetryDictionary.flow('party', end: {
      'guests': _count,
      'tracks': _count,
      'host_tracks': _count,
      'guest_tracks': _count,
      'auto_tracks': _count,
      'votes': _count,
    }),
  },
);
