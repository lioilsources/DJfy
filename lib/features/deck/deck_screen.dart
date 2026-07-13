import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import '../../services/audio_engine.dart';
import '../mixer/mixer_cubit.dart';
import 'deck_cubit.dart';
import 'deck_widget.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final List<int> _deckIds = [1];
  int _nextId = 2;
  late final MixerCubit _mixer = MixerCubit(AudioEngine.instance)
    ..assignDecks(_deckIds);

  void _addDeck() {
    if (_deckIds.length >= 6) return;
    setState(() => _deckIds.add(_nextId++));
    _mixer.assignDecks(_deckIds);
  }

  void _removeDeck(int id) {
    setState(() => _deckIds.remove(id));
    _mixer.assignDecks(_deckIds);
  }

  @override
  void dispose() {
    _mixer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crossCount = _deckIds.length <= 1 ? 1 : 2;
    return BlocProvider.value(
      value: _mixer,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                childAspectRatio: _deckIds.length <= 2 ? 0.75 : 0.7,
              ),
              itemCount: _deckIds.length,
              itemBuilder: (ctx, i) {
                final id = _deckIds[i];
                return BlocProvider(
                  key: ValueKey(id),
                  create: (_) => DeckCubit(id, AudioEngine.instance),
                  child: DeckWidget(
                    onClose:
                        _deckIds.length > 1 ? () => _removeDeck(id) : null,
                  ),
                );
              },
            ),
          ),
          if (_deckIds.length >= 2) const _CrossfaderRow(),
          if (_deckIds.length < 6)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton.icon(
                onPressed: _addDeck,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('PŘIDAT DECK'),
                style: TextButton.styleFrom(
                  foregroundColor: kNeonCyan,
                  textStyle: const TextStyle(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrossfaderRow extends StatelessWidget {
  const _CrossfaderRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MixerCubit, MixerState>(
      builder: (context, state) {
        final mixer = context.read<MixerCubit>();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onDoubleTap: mixer.recenter,
                child: Row(
                  children: [
                    const Text(
                      'A',
                      style: TextStyle(
                        color: kNeonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          activeTrackColor: kNeonCyan,
                          inactiveTrackColor: kNeonPurple,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: state.crossfade,
                          min: 0,
                          max: 1,
                          onChanged: mixer.setCrossfade,
                        ),
                      ),
                    ),
                    const Text(
                      'B',
                      style: TextStyle(
                        color: kNeonPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'CROSSFADER',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
