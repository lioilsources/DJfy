import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../features/deck/deck_screen.dart';
import '../features/party/party_cubit.dart';
import '../features/party/party_player.dart';
import '../features/party/party_screen.dart';
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
          // App-level so a running party survives leaving the party screen.
          BlocProvider(
            create: (_) => PartyCubit(
              GetIt.I<RelayClient>(),
              GetIt.I<SoundCloudService>(),
              bpm: GetIt.I<BpmService>(),
              playerFactory: ({required onNeedNext, required onStarted, required onFailed}) =>
                  PartyPlayer(
                    AudioEngine.instance,
                    GetIt.I<SoundCloudService>(),
                    onNeedNext: onNeedNext,
                    onStarted: onStarted,
                    onFailed: onFailed,
                  ),
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
            onPressed: () {
              final party = context.read<PartyCubit>();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: party,
                  child: const PartyScreen(),
                ),
              ));
            },
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
          PlaylistPanel(),
          Expanded(child: DeckScreen()),
        ],
      ),
    );
  }
}
