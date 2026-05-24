import '../../models/deck_config.dart';
import '../../models/track.dart';

sealed class DeckState {
  const DeckState();
}

class DeckIdle extends DeckState {
  final DeckConfig config;
  const DeckIdle(this.config);
}

class DeckLoading extends DeckState {
  final DeckConfig config;
  const DeckLoading(this.config);
}

class DeckReady extends DeckState {
  final DeckConfig config;
  const DeckReady(this.config);
}

class DeckError extends DeckState {
  final DeckConfig config;
  final String message;
  const DeckError(this.config, this.message);
}

extension DeckStateX on DeckState {
  DeckConfig get config => switch (this) {
        DeckIdle(:final config) => config,
        DeckLoading(:final config) => config,
        DeckReady(:final config) => config,
        DeckError(:final config) => config,
      };

  Track? get track => config.track;
  bool get isPlaying => config.isPlaying;
}
