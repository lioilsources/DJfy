import 'package:flutter/material.dart';

/// Pacemaker-style per-deck effects, driven by the XY pad in the FX view.
enum FxType { hiLo, echo, reverb, crush, roll, beatskip, brake, spin }

extension FxTypeInfo on FxType {
  String get label => switch (this) {
        FxType.hiLo => 'HI-LO',
        FxType.echo => 'ECHO',
        FxType.reverb => 'REVERB',
        FxType.crush => 'CRUSH',
        FxType.roll => 'ROLL',
        FxType.beatskip => 'BEATSKIP',
        FxType.brake => 'BRAKE',
        FxType.spin => 'SPIN',
      };

  Color get color => switch (this) {
        FxType.hiLo => const Color(0xFF00E5FF),
        FxType.echo => const Color(0xFFFFB300),
        FxType.reverb => const Color(0xFFBB00FF),
        FxType.crush => const Color(0xFF43A047),
        FxType.roll => const Color(0xFFE53935),
        FxType.beatskip => const Color(0xFF1E88E5),
        FxType.brake => const Color(0xFFFF7043),
        FxType.spin => const Color(0xFFEC407A),
      };

  IconData get icon => switch (this) {
        FxType.hiLo => Icons.filter_alt,
        FxType.echo => Icons.graphic_eq,
        FxType.reverb => Icons.church,
        FxType.crush => Icons.videogame_asset,
        FxType.roll => Icons.loop,
        FxType.beatskip => Icons.skip_next,
        FxType.brake => Icons.trending_down,
        FxType.spin => Icons.replay,
      };

  /// Roll and Beatskip need a beat grid, i.e. a known track BPM.
  bool get needsBpm => this == FxType.roll || this == FxType.beatskip;

  /// Spin plays the record backwards: only decks playing decoded PCM can.
  bool get needsPcm => this == FxType.spin;

  /// Brake and spin move the platter; they let go on release, never latch.
  bool get latchable => this != FxType.brake && this != FxType.spin && this != FxType.beatskip;

  String get xAxisLabel => switch (this) {
        FxType.hiLo => 'LP ← VYP → HP',
        FxType.echo => '1/4  1/2  3/4  1 beat',
        FxType.reverb => 'ROOM SIZE',
        FxType.crush => 'SAMPLERATE',
        FxType.roll => '1/2  1/4  1/8  1/16',
        FxType.beatskip => '-4  -2  -1  +1  +2  +4',
        FxType.brake => 'DOJEZD 0,25 → 2 s',
        FxType.spin => 'DÉLKA 0,5 → 2 s',
      };

  String get yAxisLabel => switch (this) {
        FxType.hiLo => 'REZONANCE',
        FxType.echo => 'MIX',
        FxType.reverb => 'MIX',
        FxType.crush => 'BITY',
        FxType.roll => '',
        FxType.beatskip => '',
        FxType.brake => '',
        FxType.spin => 'SÍLA',
      };
}
