import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/deck_config.dart';
import '../../models/track.dart';
import '../../services/audio_engine.dart';
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
    try {
      await _engine.loadTrack(deckId, track.soundcloudStreamUrl!);
      debugPrint('[Deck $deckId] load OK');
      emit(DeckReady(state.config));
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

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _engine.dispose(deckId);
    return super.close();
  }
}
