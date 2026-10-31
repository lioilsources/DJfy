import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../features/deck/deck_cubit.dart';
import '../features/deck/deck_registry.dart';
import '../features/deck/deck_screen.dart';
import '../features/mixer/mixer_cubit.dart';
import '../features/party/party_cubit.dart';
import '../features/party/party_player.dart';
import '../features/party/party_screen.dart';
import '../features/party/party_state.dart';
import '../features/playlist/playlist_cubit.dart';
import '../features/playlist/playlist_screen.dart';
import '../services/audio_engine.dart';
import '../services/bpm_service.dart';
import '../services/lastfm_service.dart';
import '../services/relay_client.dart';
import '../services/soundcloud_service.dart';
import 'theme.dart';

class DjDeckifyApp extends StatelessWidget {
  const DjDeckifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DJ Deckify',
      theme: djTheme,
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => PlaylistCubit(
              GetIt.I<LastFmService>(),
              GetIt.I<BpmService>(),
              GetIt.I<SoundCloudService>(),
            ),
          ),
          // App-level so the party can drive decks and the crossfader, and
          // a playing deck survives scrolling off screen.
          BlocProvider(create: (_) => MixerCubit(AudioEngine.instance)),
          BlocProvider(
            create: (ctx) => DeckRegistry(
              (id) => DeckCubit(id, AudioEngine.instance),
              ctx.read<MixerCubit>(),
            ),
          ),
          // App-level so a running party survives leaving the party screen.
          BlocProvider(
            create: (ctx) => PartyCubit(
              GetIt.I<RelayClient>(),
              GetIt.I<SoundCloudService>(),
              bpm: GetIt.I<BpmService>(),
              playerFactory: (events) => PartyPlayer(ctx.read<DeckRegistry>(), ctx.read<MixerCubit>(), events),
            ),
          ),
        ],
        child: const _HomeScreen(),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DJ DECKIFY'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => _openParty(context),
            icon: const Icon(Icons.celebration, size: 18, color: kNeonPurple),
            label: const Text(
              'PARTY',
              style: TextStyle(color: kNeonPurple, letterSpacing: 1.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                'v1.0',
                style: TextStyle(color: Colors.white.withAlpha(40), fontSize: 11),
              ),
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          _PartyBar(),
          PlaylistPanel(),
          Expanded(child: DeckScreen()),
        ],
      ),
    );
  }
}

void _openParty(BuildContext context) {
  final party = context.read<PartyCubit>();
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: party,
      child: const PartyScreen(),
    ),
  ));
}

/// Live party controls above the decks, so Next is one tap away.
class _PartyBar extends StatelessWidget {
  const _PartyBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartyCubit, PartyState>(
      buildWhen: (a, b) =>
          a.phase != b.phase ||
          a.nowPlaying != b.nowPlaying ||
          a.queue.length != b.queue.length ||
          a.loadingNext != b.loadingNext,
      builder: (context, s) {
        if (s.phase != PartyPhase.live) return const SizedBox.shrink();
        return Material(
          color: kNeonPurple.withAlpha(40),
          child: InkWell(
            onTap: () => _openParty(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  const Icon(Icons.celebration, size: 16, color: kNeonPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${s.nowPlaying?.title ?? 'Party ${s.code}'} · fronta: ${s.queue.length}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: s.loadingNext
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.skip_next, size: 20),
                    onPressed: s.nowPlaying == null && !s.loadingNext ? null : context.read<PartyCubit>().skip,
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
