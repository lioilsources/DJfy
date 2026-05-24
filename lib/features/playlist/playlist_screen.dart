import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import 'playlist_cubit.dart';
import 'playlist_state.dart';
import 'track_list_item.dart';

class PlaylistPanel extends StatefulWidget {
  const PlaylistPanel({super.key});

  @override
  State<PlaylistPanel> createState() => _PlaylistPanelState();
}

class _PlaylistPanelState extends State<PlaylistPanel> {
  final _controller = TextEditingController();
  bool _expanded = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expanded ? 320 : 52,
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.queue_music, color: kNeonCyan, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'SMART PLAYLIST',
                    style: TextStyle(
                      color: kNeonCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Interpret nebo Interpret - Song...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _search(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _search(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNeonCyan,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(48, 40),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
            // Results
            Expanded(
              child: BlocBuilder<PlaylistCubit, PlaylistState>(
                builder: (context, state) {
                  return switch (state) {
                    PlaylistIdle() => const Center(
                        child: Text(
                          'Zadej kapelu nebo song',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    PlaylistSearching(:final query) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: kNeonCyan,
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hledám "$query"…',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    PlaylistLoaded(:final seed, :final tracks) =>
                      ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          TrackListItem(track: seed, isSeed: true),
                          if (tracks.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                'Podobné (seřazeno dle BPM)',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            ...tracks.map((t) => TrackListItem(track: t)),
                          ],
                          // GetSongBPM backlink (required by API ToS)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'BPM data: getsongbpm.com',
                              style: TextStyle(
                                color: Colors.white.withAlpha(30),
                                fontSize: 9,
                              ),
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
