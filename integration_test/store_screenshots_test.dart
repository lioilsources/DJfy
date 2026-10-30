// Store screenshots (tool/store_screenshots.sh): drives the real app through
// the playlist, the decks and a live party, and prints `SHOT <name>` whenever
// the screen is ready for the script to capture from the simulator. The
// guests are played by the script against a local relay while this waits.
import 'dart:async';

import 'package:dj_deckify/features/deck/deck_cubit.dart';
import 'package:dj_deckify/features/deck/deck_widget.dart';
import 'package:dj_deckify/features/party/party_cubit.dart';
import 'package:dj_deckify/features/party/party_state.dart';
import 'package:dj_deckify/features/playlist/playlist_cubit.dart';
import 'package:dj_deckify/features/playlist/playlist_screen.dart';
import 'package:dj_deckify/features/playlist/playlist_state.dart';
import 'package:dj_deckify/main.dart' as app;
import 'package:dj_deckify/models/party.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  // Frames are drawn by the app as on a phone; the test only waits for them.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('store screenshots', (tester) async {
    await app.main();
    await _settle(tester, 3);
    final root = tester.element(find.byType(PlaylistPanel));
    final playlist = root.read<PlaylistCubit>();
    final party = root.read<PartyCubit>();

    // Smart playlist from a seed artist.
    await tester.enterText(find.byType(TextField).first, 'Daft Punk');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _until(tester, () => playlist.state is PlaylistLoaded, seconds: 45);
    final tracks = (playlist.state as PlaylistLoaded).tracks;
    await _settle(tester, 4); // artwork
    await _shot(tester, '01-playlist');

    // One deck with the first track, playing (two side by side are too
    // narrow for a phone in portrait).
    final deck = tester.element(find.byType(DeckWidget)).read<DeckCubit>();
    await deck.loadTrack(tracks[0]);
    await _settle(tester, 6);
    unawaited(deck.togglePlayPause());
    await tester.tap(find.byIcon(Icons.expand_less)); // fold the playlist away
    await _settle(tester, 4);
    await _shot(tester, '02-decks');
    unawaited(deck.togglePlayPause());

    // The party.
    await tester.tap(find.text('PARTY'));
    await _settle(tester, 2);
    await _shot(tester, '03-party-start');
    await tester.enterText(find.byType(TextField), 'Sobotní party');
    await tester.tap(find.text('ZALOŽIT PARTY'));
    await _until(tester, () => party.state.phase == PartyPhase.live, seconds: 20);
    for (final t in tracks.skip(1).take(4)) {
      await party.addTrack(t);
    }
    party.setMoodLock(const MoodLock(110, 130));
    // On the simulator the first stream can take minutes before it plays.
    await party.togglePlay();
    await _settle(tester, 3);
    // ignore: avoid_print
    print('PARTY_CODE ${party.state.code}');

    // Guests join, propose and vote; give a co-DJ badge to the first one in.
    await _until(tester, () => party.state.guests.length >= 4 && party.state.queue.length >= 5, seconds: 150);
    party.toggleCoDj(party.state.guests.keys.first);
    await _settle(tester, 4);
    await _shot(tester, '04-party-queue');
    await tester.tap(find.text('HOSTÉ'));
    await _settle(tester, 2);
    await _shot(tester, '05-party-guests');
    await tester.tap(find.text('HLEDAT'));
    await _settle(tester, 1);
    await tester.enterText(find.byType(TextField), 'Justice');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester, 6);
    await _shot(tester, '06-party-search');
    await tester.tap(find.text('FRONTA'));

    // Keep the party alive while the script shoots the guests' final view.
    // ignore: avoid_print
    print('HOST_DONE');
    await _settle(tester, 30);
    await party.end();
  }, timeout: const Timeout(Duration(minutes: 25)));
}

/// Lets real time pass (network, audio, animations). No tester.pump(): with
/// audio and a live party running it can wait forever for a frame to end.
Future<void> _settle(WidgetTester tester, int seconds) => Future<void>.delayed(Duration(seconds: seconds));

Future<void> _until(WidgetTester tester, bool Function() done, {required int seconds}) async {
  for (var i = 0; i < seconds * 10 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Asks the script for a screenshot, then holds the frame still for it.
Future<void> _shot(WidgetTester tester, String name) async {
  // ignore: avoid_print
  print('SHOT $name');
  await _settle(tester, 3);
}
