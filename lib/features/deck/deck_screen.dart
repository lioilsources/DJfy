import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import '../mixer/mixer_cubit.dart';
import 'deck_registry.dart';
import 'deck_widget.dart';

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registry = context.read<DeckRegistry>();
    return BlocBuilder<DeckRegistry, DeckListState>(
      builder: (context, decks) {
        final ids = decks.ordered;
        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final crossCount = deckColumns(ids.length, constraints.maxWidth);
                return GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    childAspectRatio: ids.length <= 2 ? 0.75 : 0.7,
                  ),
                  itemCount: ids.length,
                  itemBuilder: (ctx, i) {
                    final id = ids[i];
                    return BlocProvider.value(
                      key: ValueKey(id),
                      value: registry.deck(id),
                      child: DeckWidget(
                        onClose: ids.length > 1 ? () => registry.remove(id) : null,
                      ),
                    );
                  },
                );
              }),
            ),
            if (ids.length >= 2) const _CrossfaderRow(),
            if (ids.length < DeckRegistry.maxDecks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextButton.icon(
                  onPressed: registry.add,
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
      },
    );
  }
}

/// Two decks side by side only fit on tablets/desktop; a phone in portrait
/// stacks them (the playback row overflowed at ~220 pt per deck).
@visibleForTesting
int deckColumns(int decks, double width) => decks <= 1 || width < 600 ? 1 : 2;

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
