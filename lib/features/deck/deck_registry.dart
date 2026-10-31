import 'package:flutter_bloc/flutter_bloc.dart';

import '../mixer/mixer_cubit.dart';
import 'deck_cubit.dart';

class DeckListState {
  final List<int> ids;

  /// Deck the party is playing on; null outside a party.
  final int? liveDeck;

  const DeckListState({this.ids = const [1], this.liveDeck});

  /// Display order: during a party the live deck is always first.
  List<int> get ordered {
    final live = liveDeck;
    if (live == null) return ids;
    return [live, ...ids.where((id) => id != live)];
  }
}

/// Owns the decks at app level, so a deck keeps playing when it scrolls off
/// screen and the party can drive decks 1/2 from outside the deck UI.
class DeckRegistry extends Cubit<DeckListState> {
  static const maxDecks = 6;

  final DeckCubit Function(int id) _create;
  final MixerCubit _mixer;
  final Map<int, DeckCubit> _decks = {};
  int _nextId = 2;

  DeckRegistry(this._create, this._mixer) : super(const DeckListState()) {
    _mixer.assignDecks(state.ids);
  }

  DeckCubit deck(int id) => _decks.putIfAbsent(id, () => _create(id));

  void add() {
    if (state.ids.length >= maxDecks) return;
    _setIds([...state.ids, _nextId++]);
  }

  /// Closes the deck, which also frees its audio.
  void remove(int id) {
    if (state.ids.length <= 1 || !state.ids.contains(id)) return;
    _setIds([...state.ids]..remove(id));
    _decks.remove(id)?.close();
  }

  /// Puts [ids] at the front of the list, creating the ones that are missing.
  void ensureFirst(List<int> ids) {
    final rest = state.ids.where((id) => !ids.contains(id));
    _setIds([...ids, ...rest]);
    final highest = state.ids.reduce((a, b) => a > b ? a : b);
    if (_nextId <= highest) _nextId = highest + 1;
  }

  void setLive(int? id) => emit(DeckListState(ids: state.ids, liveDeck: id));

  void _setIds(List<int> ids) {
    emit(DeckListState(ids: ids, liveDeck: state.liveDeck));
    _mixer.assignDecks(ids);
  }

  @override
  Future<void> close() async {
    await Future.wait([for (final d in _decks.values) d.close()]);
    return super.close();
  }
}
