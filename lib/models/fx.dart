import 'package:flutter/material.dart';

/// Pacemaker-style per-deck effects, driven by the XY pad in the FX view.
enum FxType { hiLo, echo, reverb, eightBit, roll, beatskip }

extension FxTypeInfo on FxType {
  String get label => switch (this) {
        FxType.hiLo => 'HI-LO',
        FxType.echo => 'ECHO',
        FxType.reverb => 'REVERB',
        FxType.eightBit => '8-BIT',
        FxType.roll => 'ROLL',
        FxType.beatskip => 'BEATSKIP',
      };

  Color get color => switch (this) {
        FxType.hiLo => const Color(0xFF00E5FF),
        FxType.echo => const Color(0xFFFFB300),
        FxType.reverb => const Color(0xFFBB00FF),
        FxType.eightBit => const Color(0xFF43A047),
        FxType.roll => const Color(0xFFE53935),
        FxType.beatskip => const Color(0xFF1E88E5),
      };

  IconData get icon => switch (this) {
        FxType.hiLo => Icons.filter_alt,
        FxType.echo => Icons.graphic_eq,
        FxType.reverb => Icons.church,
        FxType.eightBit => Icons.videogame_asset,
        FxType.roll => Icons.loop,
        FxType.beatskip => Icons.skip_next,
      };

  /// Roll and Beatskip need a beat grid, i.e. a known track BPM.
  bool get needsBpm => this == FxType.roll || this == FxType.beatskip;

  String get xAxisLabel => switch (this) {
        FxType.hiLo => 'LP ← VYP → HP',
        FxType.echo => '1/4  1/2  3/4  1 beat',
        FxType.reverb => 'ROOM SIZE',
        FxType.eightBit => 'CRUSH',
        FxType.roll => '1/2  1/4  1/8  1/16',
        FxType.beatskip => '-4  -2  -1  +1  +2  +4',
      };

  String get yAxisLabel => switch (this) {
        FxType.hiLo => 'REZONANCE',
        FxType.echo => 'MIX',
        FxType.reverb => 'MIX',
        FxType.eightBit => 'MIX',
        FxType.roll => '',
        FxType.beatskip => '',
      };
}
