// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · kö: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Fest $code';
  }

  @override
  String get addDeck => 'LÄGG TILL DECK';

  @override
  String get deckDropHint => 'Dra ett spår hit';

  @override
  String get deckWaitingForQueue => 'Väntar på kön';

  @override
  String get dspUnavailable => 'DSP inte tillgänglig (HLS-ström)';

  @override
  String get bpmUnknown => 'BPM okänt';

  @override
  String get genericError => 'Fel';

  @override
  String get partyTagline =>
      'Din telefon är DJ:n. Högtalaren är bara en högtalare.';

  @override
  String get partyIntro =>
      'Gästerna skannar QR-koden, söker och röstar i webbläsaren – utan app och utan konto. Kön finns hos dig, och ljudet skickar du via AirPlay eller Bluetooth.';

  @override
  String get partyNameLabel => 'Festens namn';

  @override
  String get startParty => 'STARTA FEST';

  @override
  String get back => 'TILLBAKA';

  @override
  String get qrForGuests => 'QR för gäster';

  @override
  String get endParty => 'Avsluta festen';

  @override
  String get endPartyQuestion => 'Avsluta festen?';

  @override
  String get endPartyWarning => 'Gästerna kopplas från och kön rensas.';

  @override
  String get no => 'NEJ';

  @override
  String get endAction => 'AVSLUTA';

  @override
  String get tabQueue => 'KÖ';

  @override
  String get tabGuests => 'GÄSTER';

  @override
  String get tabSearch => 'SÖK';

  @override
  String get copyLink => 'KOPIERA LÄNK';

  @override
  String get queueEmpty => 'Kön är tom';

  @override
  String get readyPressPlay => 'Klart – tryck på ▶';

  @override
  String addedBy(String name) {
    return 'tillagd av $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Spår utanför intervallet stannar i kön men spelas inte av sig själva.';

  @override
  String get turnOff => 'STÄNG AV';

  @override
  String get lockAction => 'LÅS';

  @override
  String get queueEmptyHint =>
      'Inget än. Lägg till ett spår eller visa gästerna QR-koden.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Spela nu';

  @override
  String get playNext => 'Spela härnäst';

  @override
  String get unpin => 'Lossa';

  @override
  String get noGuestsYet => 'Ingen har kommit än';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · röst ×$weight, kan lägga in veto';
  }

  @override
  String get guestRole => 'gäst';

  @override
  String get removeCoDj => 'Ta bort co-DJ';

  @override
  String get promoteCoDj => 'Gör till co-DJ';

  @override
  String get blockGuest => 'Blockera';

  @override
  String get searchSoundCloudHint => 'Sök på SoundCloud…';

  @override
  String trackAdded(String title) {
    return '”$title” tillagd';
  }

  @override
  String get playlistSearchHint => 'Artist eller Artist - Låt...';

  @override
  String get playlistIdle => 'Skriv ett band eller en låt';

  @override
  String searchingFor(String query) {
    return 'Söker efter ”$query”…';
  }

  @override
  String get similarByBpm => 'Liknande (sorterat efter BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Fel: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Hittade inget nästa spår – lägg till något i kön';

  @override
  String get toastPickingNext => 'Väljer nästa spår…';

  @override
  String toastCannotPlay(String title) {
    return 'Kan inte spela ”$title” – hoppar över';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay inte tillgänglig: $error';
  }
}
