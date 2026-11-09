// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · queue: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Party $code';
  }

  @override
  String get addDeck => 'ADD DECK';

  @override
  String get deckDropHint => 'Drag a track here';

  @override
  String get deckWaitingForQueue => 'Waiting for the queue';

  @override
  String get dspUnavailable => 'DSP unavailable (HLS stream)';

  @override
  String get bpmUnknown => 'BPM unknown';

  @override
  String get genericError => 'Error';

  @override
  String get partyTagline =>
      'Your phone is the DJ. The speaker is just a speaker.';

  @override
  String get partyIntro =>
      'Guests scan the QR code, search and vote in their browser – no app, no account. The queue lives on your phone; send the sound over AirPlay or Bluetooth.';

  @override
  String get partyNameLabel => 'Party name';

  @override
  String get startParty => 'START PARTY';

  @override
  String get back => 'BACK';

  @override
  String get qrForGuests => 'QR for guests';

  @override
  String get endParty => 'End party';

  @override
  String get endPartyQuestion => 'End the party?';

  @override
  String get endPartyWarning =>
      'Guests will be disconnected and the queue will be cleared.';

  @override
  String get no => 'NO';

  @override
  String get endAction => 'END';

  @override
  String get tabQueue => 'QUEUE';

  @override
  String get tabGuests => 'GUESTS';

  @override
  String get tabSearch => 'SEARCH';

  @override
  String get copyLink => 'COPY LINK';

  @override
  String get queueEmpty => 'The queue is empty';

  @override
  String get readyPressPlay => 'Ready – press ▶';

  @override
  String addedBy(String name) {
    return 'added by $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Tracks outside the range stay in the queue but won\'t play on their own.';

  @override
  String get turnOff => 'TURN OFF';

  @override
  String get lockAction => 'LOCK';

  @override
  String get queueEmptyHint =>
      'Nothing yet. Add a track or show guests the QR code.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Play now';

  @override
  String get playNext => 'Play next';

  @override
  String get unpin => 'Unpin';

  @override
  String get noGuestsYet => 'No one has arrived yet';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · vote ×$weight, can veto';
  }

  @override
  String get guestRole => 'guest';

  @override
  String get removeCoDj => 'Remove co-DJ';

  @override
  String get promoteCoDj => 'Promote to co-DJ';

  @override
  String get blockGuest => 'Block';

  @override
  String get searchSoundCloudHint => 'Search SoundCloud…';

  @override
  String trackAdded(String title) {
    return '“$title” added';
  }

  @override
  String get playlistSearchHint => 'Artist or Artist - Song...';

  @override
  String get playlistIdle => 'Enter a band or a song';

  @override
  String searchingFor(String query) {
    return 'Searching for “$query”…';
  }

  @override
  String get similarByBpm => 'Similar (sorted by BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Couldn\'t find another track – add one to the queue';

  @override
  String get toastPickingNext => 'Picking the next track…';

  @override
  String toastCannotPlay(String title) {
    return 'Can\'t play “$title” – skipping';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay unavailable: $error';
  }
}
