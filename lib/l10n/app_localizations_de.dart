// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · Warteschlange: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Party $code';
  }

  @override
  String get addDeck => 'DECK HINZUFÜGEN';

  @override
  String get deckDropHint => 'Track hierher ziehen';

  @override
  String get deckWaitingForQueue => 'Wartet auf die Warteschlange';

  @override
  String get dspUnavailable => 'DSP nicht verfügbar (HLS-Stream)';

  @override
  String get bpmUnknown => 'BPM unbekannt';

  @override
  String get genericError => 'Fehler';

  @override
  String get partyTagline =>
      'Dein Handy ist der DJ. Der Lautsprecher ist nur ein Lautsprecher.';

  @override
  String get partyIntro =>
      'Gäste scannen den QR-Code, suchen und stimmen im Browser ab – ohne App und ohne Konto. Die Warteschlange liegt bei dir, den Sound schickst du per AirPlay oder Bluetooth.';

  @override
  String get partyNameLabel => 'Name der Party';

  @override
  String get startParty => 'PARTY STARTEN';

  @override
  String get back => 'ZURÜCK';

  @override
  String get qrForGuests => 'QR für Gäste';

  @override
  String get endParty => 'Party beenden';

  @override
  String get endPartyQuestion => 'Party beenden?';

  @override
  String get endPartyWarning =>
      'Die Gäste werden getrennt und die Warteschlange wird gelöscht.';

  @override
  String get no => 'NEIN';

  @override
  String get endAction => 'BEENDEN';

  @override
  String get tabQueue => 'WARTESCHLANGE';

  @override
  String get tabGuests => 'GÄSTE';

  @override
  String get tabSearch => 'SUCHEN';

  @override
  String get copyLink => 'LINK KOPIEREN';

  @override
  String get queueEmpty => 'Die Warteschlange ist leer';

  @override
  String get readyPressPlay => 'Bereit – drück ▶';

  @override
  String addedBy(String name) {
    return 'hinzugefügt von $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood Lock';

  @override
  String get moodLockHint =>
      'Tracks außerhalb des Bereichs bleiben in der Warteschlange, laufen aber nicht von selbst.';

  @override
  String get turnOff => 'AUSSCHALTEN';

  @override
  String get lockAction => 'SPERREN';

  @override
  String get queueEmptyHint =>
      'Noch nichts. Füge einen Track hinzu oder zeig den Gästen den QR-Code.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Jetzt spielen';

  @override
  String get playNext => 'Als Nächstes spielen';

  @override
  String get unpin => 'Lösen';

  @override
  String get noGuestsYet => 'Noch niemand da';

  @override
  String coDjSubtitle(int weight) {
    return 'Co-DJ · Stimme ×$weight, darf ein Veto einlegen';
  }

  @override
  String get guestRole => 'Gast';

  @override
  String get removeCoDj => 'Co-DJ entfernen';

  @override
  String get promoteCoDj => 'Zum Co-DJ machen';

  @override
  String get blockGuest => 'Blockieren';

  @override
  String get searchSoundCloudHint => 'Auf SoundCloud suchen…';

  @override
  String trackAdded(String title) {
    return '„$title“ hinzugefügt';
  }

  @override
  String get playlistSearchHint => 'Interpret oder Interpret - Song...';

  @override
  String get playlistIdle => 'Gib eine Band oder einen Song ein';

  @override
  String searchingFor(String query) {
    return 'Suche „$query“…';
  }

  @override
  String get similarByBpm => 'Ähnlich (nach BPM sortiert)';

  @override
  String errorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Kein weiterer Track gefunden – füge einen zur Warteschlange hinzu';

  @override
  String get toastPickingNext => 'Nächster Track wird ausgewählt…';

  @override
  String toastCannotPlay(String title) {
    return '„$title“ lässt sich nicht abspielen – wird übersprungen';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay nicht erreichbar: $error';
  }
}
