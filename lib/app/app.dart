import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../features/deck/deck_screen.dart';
import '../features/playlist/playlist_cubit.dart';
import '../features/playlist/playlist_screen.dart';
import '../services/bpm_service.dart';
import '../services/jamendo_service.dart';
import '../services/lastfm_service.dart';
import 'theme.dart';

class DjDeckifyApp extends StatelessWidget {
  const DjDeckifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DJ Deckify',
      theme: djTheme,
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => PlaylistCubit(
          GetIt.I<LastFmService>(),
          GetIt.I<BpmService>(),
          GetIt.I<JamendoService>(),
        ),
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
