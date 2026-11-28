import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import '../../models/track.dart';
import '../deck/deck_cubit.dart';
import '../deck/deck_registry.dart';
import '../deck/deck_state.dart';

/// A search result: one tap on a deck button loads it onto that deck.
class TrackListItem extends StatelessWidget {
  final Track track;
  final bool isSeed;

  const TrackListItem({super.key, required this.track, this.isSeed = false});

  @override
  Widget build(BuildContext context) {
    final playable = track.soundcloudStreamUrl != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: isSeed ? kNeonCyan.withAlpha(20) : kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSeed ? kNeonCyan.withAlpha(80) : Colors.white.withAlpha(10),
          width: isSeed ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          _Artwork(url: track.artworkUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: TextStyle(
                    color: isSeed ? kNeonCyan : (playable ? Colors.white : Colors.white38),
                    fontWeight: isSeed ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  playable ? track.artist : '${track.artist} · není na SoundCloudu',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (track.bpm != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: kNeonPurple.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kNeonPurple.withAlpha(80)),
              ),
              child: Text(
                '${track.bpm}',
                style: const TextStyle(color: kNeonPurple, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(width: 4),
          DeckButtons(track: track, enabled: playable),
        ],
      ),
    );
  }
}

/// One button per open deck. Lit when the deck holds this track; decks the
/// party drives are off limits.
class DeckButtons extends StatelessWidget {
  final Track track;
  final bool enabled;

  const DeckButtons({super.key, required this.track, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final registry = context.read<DeckRegistry>();
    return BlocBuilder<DeckRegistry, DeckListState>(
      bloc: registry,
      builder: (context, decks) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final id in decks.ordered)
            BlocBuilder<DeckCubit, DeckState>(
              bloc: registry.deck(id),
              builder: (context, state) => _DeckButton(
                deckId: id,
                track: track,
                state: state,
                enabled: enabled && state.config.partyRole == null,
                onTap: () {
                  unawaited(registry.deck(id).loadTrack(track));
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('${track.title} → DECK $id'),
                      duration: const Duration(seconds: 1),
                    ));
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DeckButton extends StatelessWidget {
  final int deckId;
  final Track track;
  final DeckState state;
  final bool enabled;
  final VoidCallback onTap;

  const _DeckButton({
    required this.deckId,
    required this.track,
    required this.state,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final here = state.config.track == track;
    final loading = here && state is DeckLoading;
    final color = !enabled ? Colors.white12 : (here ? kNeonCyan : Colors.white54);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: here ? kNeonCyan.withAlpha(50) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color, width: here ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled && !here ? onTap : null,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: kNeonCyan),
                    )
                  : Text(
                      '$deckId',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final String? url;
  const _Artwork({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.music_note, size: 18, color: Colors.white38),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorWidget: (ctx, url, err) =>
            const Icon(Icons.music_note, size: 18, color: Colors.white38),
      ),
    );
  }
}
