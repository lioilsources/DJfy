import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import '../../services/audio_engine.dart';
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

  void _addDeck() {
    if (_deckIds.length >= 6) return;
    setState(() => _deckIds.add(_nextId++));
  }

  void _removeDeck(int id) {
    setState(() => _deckIds.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final crossCount = _deckIds.length <= 1 ? 1 : 2;
    return Column(
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
                  onClose: _deckIds.length > 1 ? () => _removeDeck(id) : null,
                ),
              );
            },
          ),
        ),
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
    );
  }
}
