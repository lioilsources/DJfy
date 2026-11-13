import 'dart:typed_data';

import 'fx.dart';
import 'track.dart';

/// 3-band EQ kill switches, like on a DJ mixer.
///
/// Mapped onto SoLoud's 8-band FFT equalizer whose bands are sqrt-warped:
/// band k covers (k/8)²…((k+1)/8)² of Nyquist. At 44.1 kHz:
/// low = band1 (0–344 Hz), mid = bands 2–3 (344 Hz–3.1 kHz),
/// high = bands 4–8 (3.1–22 kHz).
enum EqBand { low, mid, high }

/// A deck the party has taken over: [live] is on air, [next] gets the upcoming
/// track. Both are locked against manual loading and closing.
enum PartyDeckRole { live, next }

class DeckConfig {
  final int id;
  final Track? track;
  final bool isPlaying;
  final double speed;
  final double volume;
  final Duration position;
  final Duration duration;
  final Map<EqBand, bool> eqBands;
  final bool hasDsp; // true = flutter_soloud (DSP available), false = HLS fallback
  final FxType selectedFx;
  final bool fxActive;
  final double fxX;
  final double fxY;

  /// The FX stays on after the finger lifts, until unlatched.
  final bool fxLatched;
  final PartyDeckRole? partyRole;

  /// Slip mode: after a scratch the track carries on where it would have been.
  final bool slip;

  /// Waveform peaks (see TrackAnalysis), when the deck plays decoded PCM.
  final Uint8List? waveform;

  /// Where the beat grid starts; detected from the audio or set with TAP.
  final Duration beatOffset;

  const DeckConfig({
    required this.id,
    this.track,
    this.isPlaying = false,
    this.speed = 1.0,
    this.volume = 0.8,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.eqBands = const {
      EqBand.low: true,
      EqBand.mid: true,
      EqBand.high: true,
    },
    this.hasDsp = false,
    this.selectedFx = FxType.hiLo,
    this.fxActive = false,
    this.fxX = 0.5,
    this.fxY = 0.5,
    this.fxLatched = false,
    this.partyRole,
    this.slip = false,
    this.waveform,
    this.beatOffset = Duration.zero,
  });

  DeckConfig copyWith({
    Track? track,
    bool? isPlaying,
    double? speed,
    double? volume,
    Duration? position,
    Duration? duration,
    Map<EqBand, bool>? eqBands,
    bool? hasDsp,
    FxType? selectedFx,
    bool? fxActive,
    double? fxX,
    double? fxY,
    bool? fxLatched,
    PartyDeckRole? partyRole,
    bool clearPartyRole = false,
    bool? slip,
    Uint8List? waveform,
    bool clearWaveform = false,
    Duration? beatOffset,
  }) {
    return DeckConfig(
      id: id,
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      eqBands: eqBands ?? this.eqBands,
      hasDsp: hasDsp ?? this.hasDsp,
      selectedFx: selectedFx ?? this.selectedFx,
      fxActive: fxActive ?? this.fxActive,
      fxX: fxX ?? this.fxX,
      fxY: fxY ?? this.fxY,
      fxLatched: fxLatched ?? this.fxLatched,
      partyRole: clearPartyRole ? null : (partyRole ?? this.partyRole),
      slip: slip ?? this.slip,
      waveform: clearWaveform ? null : (waveform ?? this.waveform),
      beatOffset: beatOffset ?? this.beatOffset,
    );
  }
}
