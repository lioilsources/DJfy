import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../models/deck_config.dart';
import '../../models/track.dart';
import '../../services/audio_engine.dart';
import '../../services/soundcloud_service.dart';
import 'deck_state.dart';

class DeckCubit extends Cubit<DeckState> {
  final int deckId;
  final AudioEngine _engine;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;

  DeckCubit(this.deckId, this._engine)
      : super(DeckIdle(DeckConfig(id: deckId))) {
    _subscribeStreams();
  }

  void _subscribeStreams() {
    _positionSub = _engine.positionStream(deckId).listen((pos) {
      final cfg = state.config.copyWith(position: pos);
      if (state is DeckReady) emit(DeckReady(cfg));
    });
    _durationSub = _engine.durationStream(deckId).listen((dur) {
      if (dur == null) return;
      final cfg = state.config.copyWith(duration: dur);
      if (state is DeckReady) emit(DeckReady(cfg));
      if (state is DeckLoading) emit(DeckLoading(cfg));
    });
    _stateSub = _engine.playerStateStream(deckId).listen((ps) {
      final playing = ps.playing;
      final cfg = state.config.copyWith(isPlaying: playing);
      if (state is DeckReady) emit(DeckReady(cfg));
    });
  }

  Future<void> loadTrack(Track track) async {
    if (track.soundcloudStreamUrl == null) {
      emit(DeckError(state.config, 'Žádný stream URL'));
      return;
    }
    final loadingConfig = state.config.copyWith(track: track);
    emit(DeckLoading(loadingConfig));
    debugPrint('[Deck $deckId] loading: ${track.soundcloudStreamUrl}');

    // Resolve progressive URL in parallel with loading — it's a best-effort
    // call; failure just means no DSP stem filters on this track.
    String? progressiveUrl;
    try {
      final sc = GetIt.I.get<SoundCloudService>();
      if (track.scId != null) {
        progressiveUrl =
            await sc.resolveProgressiveUrl(track.scId!.toString());
      }
    } catch (e) {
      debugPrint('[Deck $deckId] progressive URL resolution failed: $e');
    }

    try {
      final hasDsp = await _engine.loadTrack(
        deckId,
        track.soundcloudStreamUrl!,
        progressiveUrl: progressiveUrl,
      );
      // Re-subscribe streams — SoLoud decks use different stream sources
      _cancelStreams();
      _subscribeStreams();

      final dur = _engine.currentDuration(deckId) ?? Duration.zero;
      debugPrint('[Deck $deckId] load OK, hasDsp=$hasDsp, duration=${dur.inSeconds}s');
      emit(DeckReady(state.config.copyWith(duration: dur, hasDsp: hasDsp)));
    } catch (e) {
      debugPrint('[Deck $deckId] load FAILED: $e');
      emit(DeckError(loadingConfig, e.toString()));
    }
  }

  Future<void> togglePlayPause() async {
    if (state is! DeckReady) return;
    if (state.config.isPlaying) {
      await _engine.pause(deckId);
    } else {
      await _engine.play(deckId);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _engine.seekTo(deckId, position);
  }

  Future<void> setSpeed(double speed) async {
    await _engine.setSpeed(deckId, speed);
    emit(DeckReady(state.config.copyWith(speed: speed)));
  }

  Future<void> setVolume(double volume) async {
    await _engine.setVolume(deckId, volume);
    emit(DeckReady(state.config.copyWith(volume: volume)));
  }

  void toggleStem(StemType stem) {
    if (state is! DeckReady || !state.config.hasDsp) return;
    final current = state.config.stemFilters[stem] ?? true;
    final newActive = !current;
    _engine.setStemActive(deckId, stem, newActive);
    final newFilters = Map<StemType, bool>.from(state.config.stemFilters)
      ..[stem] = newActive;
    emit(DeckReady(state.config.copyWith(stemFilters: newFilters)));
  }

  void _cancelStreams() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
  }

  @override
  Future<void> close() {
    _cancelStreams();
    _engine.dispose(deckId);
    return super.close();
  }
}
