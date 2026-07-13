import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/audio_engine.dart';

class MixerState {
  /// Crossfader position 0..1; 0 = full deck A, 1 = full deck B, 0.5 center.
  final double crossfade;
  final int? deckA;
  final int? deckB;

  const MixerState({this.crossfade = 0.5, this.deckA, this.deckB});

  MixerState copyWith({double? crossfade, int? deckA, int? deckB}) =>
      MixerState(
        crossfade: crossfade ?? this.crossfade,
        deckA: deckA ?? this.deckA,
        deckB: deckB ?? this.deckB,
      );
}

/// Crossfader between the first two decks (equal-power curve).
/// Decks beyond A/B keep gain 1.0 — a documented limitation.
class MixerCubit extends Cubit<MixerState> {
  final AudioEngine _engine;

  MixerCubit(this._engine) : super(const MixerState());

  /// Called whenever the deck list changes: A/B = the first two deck ids.
  void assignDecks(List<int> deckIds) {
    final a = deckIds.isNotEmpty ? deckIds[0] : null;
    final b = deckIds.length > 1 ? deckIds[1] : null;

    // Decks that dropped out of the A/B pair go back to full gain.
    for (final old in [state.deckA, state.deckB]) {
      if (old != null && old != a && old != b) {
        _engine.setCrossfadeGain(old, 1.0);
      }
    }

    emit(MixerState(crossfade: state.crossfade, deckA: a, deckB: b));
    _applyGains();
  }

  void setCrossfade(double value) {
    emit(state.copyWith(crossfade: value.clamp(0.0, 1.0)));
    _applyGains();
  }

  void recenter() => setCrossfade(0.5);

  void _applyGains() {
    final a = state.deckA;
    final b = state.deckB;
    // Equal-power: no perceived volume dip in the middle (~-3 dB per deck).
    final gainA = math.cos(state.crossfade * math.pi / 2);
    final gainB = math.sin(state.crossfade * math.pi / 2);
    if (a != null) _engine.setCrossfadeGain(a, b == null ? 1.0 : gainA);
    if (b != null) _engine.setCrossfadeGain(b, gainB);
  }
}
