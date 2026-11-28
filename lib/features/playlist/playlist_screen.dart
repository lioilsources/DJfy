import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import '../deck/deck_registry.dart';
import 'playlist_cubit.dart';
import 'playlist_state.dart';
import 'track_list_item.dart';

/// Opens the full-screen search; results load onto decks with one tap.
void openSearch(BuildContext context) {
  final playlist = context.read<PlaylistCubit>();
  final registry = context.read<DeckRegistry>();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: playlist),
          BlocProvider.value(value: registry),
        ],
        child: const SearchScreen(),
      ),
    ),
  );
}

/// The search field above the decks: a tap opens the search screen.
class SearchBarButton extends StatelessWidget {
  const SearchBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, state) {
        final label = switch (state) {
          PlaylistLoaded(:final seed) => '${seed.artist} — ${seed.title}',
          PlaylistSearching(:final query) => 'Hledám "$query"…',
          _ => 'Hledat skladbu…',
        };
        return Material(
          color: kCardBg,
          child: InkWell(
            onTap: () => openSearch(context),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: kNeonCyan, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: state is PlaylistLoaded ? Colors.white70 : Colors.white38, fontSize: 13),
                    ),
                  ),
                  if (state is PlaylistLoaded)
                    Text(
                      '${state.tracks.length + 1} skladeb',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idle = context.read<PlaylistCubit>().state is PlaylistIdle;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: idle,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Interpret nebo Interpret - Song…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onSubmitted: (_) => _search(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kNeonCyan),
            onPressed: () => _search(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Results
          Expanded(
            child: BlocBuilder<PlaylistCubit, PlaylistState>(
              builder: (context, state) {
                return switch (state) {
                  PlaylistIdle() => const Center(
                    child: Text('Zadej kapelu nebo song', style: TextStyle(color: Colors.white38)),
                  ),
                  PlaylistSearching(:final query) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: kNeonCyan, strokeWidth: 2),
                        const SizedBox(height: 8),
                        Text('Hledám "$query"…', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  PlaylistLoaded(:final seed, :final tracks) => ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      TrackListItem(track: seed, isSeed: true),
                      if (tracks.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text(
                            'Podobné (seřazeno dle BPM)',
                            style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                          ),
                        ),
                        ...tracks.map((t) => TrackListItem(track: t)),
                      ],
                      // GetSongBPM backlink (required by API ToS)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'BPM data: getsongbpm.com',
                          style: TextStyle(color: Colors.white.withAlpha(30), fontSize: 9),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  PlaylistError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Chyba: $message',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  void _search(BuildContext context) {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    context.read<PlaylistCubit>().search(q);
  }
}
