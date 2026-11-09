// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · wachtrij: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Feest $code';
  }

  @override
  String get addDeck => 'DECK TOEVOEGEN';

  @override
  String get deckDropHint => 'Sleep hier een track naartoe';

  @override
  String get deckWaitingForQueue => 'Wacht op de wachtrij';

  @override
  String get dspUnavailable => 'DSP niet beschikbaar (HLS-stream)';

  @override
  String get bpmUnknown => 'BPM onbekend';

  @override
  String get genericError => 'Fout';

  @override
  String get partyTagline =>
      'Je telefoon is de dj. De speaker is gewoon een speaker.';

  @override
  String get partyIntro =>
      'Gasten scannen de QR-code, zoeken en stemmen in de browser – zonder app en zonder account. De wachtrij staat op jouw telefoon; het geluid stuur je via AirPlay of Bluetooth.';

  @override
  String get partyNameLabel => 'Naam van het feest';

  @override
  String get startParty => 'FEEST STARTEN';

  @override
  String get back => 'TERUG';

  @override
  String get qrForGuests => 'QR voor gasten';

  @override
  String get endParty => 'Feest beëindigen';

  @override
  String get endPartyQuestion => 'Feest beëindigen?';

  @override
  String get endPartyWarning =>
      'Gasten worden losgekoppeld en de wachtrij wordt gewist.';

  @override
  String get no => 'NEE';

  @override
  String get endAction => 'BEËINDIGEN';

  @override
  String get tabQueue => 'WACHTRIJ';

  @override
  String get tabGuests => 'GASTEN';

  @override
  String get tabSearch => 'ZOEKEN';

  @override
  String get copyLink => 'LINK KOPIËREN';

  @override
  String get queueEmpty => 'De wachtrij is leeg';

  @override
  String get readyPressPlay => 'Klaar – druk op ▶';

  @override
  String addedBy(String name) {
    return 'toegevoegd door $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Tracks buiten het bereik blijven in de wachtrij, maar spelen niet vanzelf.';

  @override
  String get turnOff => 'UITZETTEN';

  @override
  String get lockAction => 'VERGRENDELEN';

  @override
  String get queueEmptyHint =>
      'Nog niets. Voeg een track toe of laat gasten de QR-code zien.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Nu afspelen';

  @override
  String get playNext => 'Hierna afspelen';

  @override
  String get unpin => 'Losmaken';

  @override
  String get noGuestsYet => 'Er is nog niemand';

  @override
  String coDjSubtitle(int weight) {
    return 'co-dj · stem ×$weight, mag een veto geven';
  }

  @override
  String get guestRole => 'gast';

  @override
  String get removeCoDj => 'Co-dj afnemen';

  @override
  String get promoteCoDj => 'Promoveren tot co-dj';

  @override
  String get blockGuest => 'Blokkeren';

  @override
  String get searchSoundCloudHint => 'Zoeken op SoundCloud…';

  @override
  String trackAdded(String title) {
    return '‘$title’ toegevoegd';
  }

  @override
  String get playlistSearchHint => 'Artiest of Artiest - Nummer...';

  @override
  String get playlistIdle => 'Voer een band of nummer in';

  @override
  String searchingFor(String query) {
    return 'Zoeken naar ‘$query’…';
  }

  @override
  String get similarByBpm => 'Vergelijkbaar (op BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Fout: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Geen volgende track gevonden – voeg er een toe aan de wachtrij';

  @override
  String get toastPickingNext => 'Volgende track kiezen…';

  @override
  String toastCannotPlay(String title) {
    return '‘$title’ kan niet worden afgespeeld – overslaan';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay niet bereikbaar: $error';
  }
}
