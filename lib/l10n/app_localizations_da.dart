// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · kø: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Fest $code';
  }

  @override
  String get addDeck => 'TILFØJ DECK';

  @override
  String get deckDropHint => 'Træk et nummer hertil';

  @override
  String get deckWaitingForQueue => 'Venter på køen';

  @override
  String get dspUnavailable => 'DSP ikke tilgængelig (HLS-stream)';

  @override
  String get bpmUnknown => 'BPM ukendt';

  @override
  String get genericError => 'Fejl';

  @override
  String get partyTagline =>
      'Din telefon er DJ\'en. Højttaleren er bare en højttaler.';

  @override
  String get partyIntro =>
      'Gæsterne scanner QR-koden, søger og stemmer i browseren – uden app og uden konto. Køen bor hos dig, og lyden sender du via AirPlay eller Bluetooth.';

  @override
  String get partyNameLabel => 'Festens navn';

  @override
  String get startParty => 'START FEST';

  @override
  String get back => 'TILBAGE';

  @override
  String get qrForGuests => 'QR til gæster';

  @override
  String get endParty => 'Afslut fest';

  @override
  String get endPartyQuestion => 'Afslut festen?';

  @override
  String get endPartyWarning =>
      'Gæsterne bliver afbrudt, og køen bliver slettet.';

  @override
  String get no => 'NEJ';

  @override
  String get endAction => 'AFSLUT';

  @override
  String get tabQueue => 'KØ';

  @override
  String get tabGuests => 'GÆSTER';

  @override
  String get tabSearch => 'SØG';

  @override
  String get copyLink => 'KOPIÉR LINK';

  @override
  String get queueEmpty => 'Køen er tom';

  @override
  String get readyPressPlay => 'Klar – tryk på ▶';

  @override
  String addedBy(String name) {
    return 'tilføjet af $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Numre uden for intervallet bliver i køen, men spiller ikke af sig selv.';

  @override
  String get turnOff => 'SLÅ FRA';

  @override
  String get lockAction => 'LÅS';

  @override
  String get queueEmptyHint =>
      'Intet endnu. Tilføj et nummer, eller vis gæsterne QR-koden.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Spil nu';

  @override
  String get playNext => 'Spil som det næste';

  @override
  String get unpin => 'Frigør';

  @override
  String get noGuestsYet => 'Ingen er kommet endnu';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · stemme ×$weight, kan nedlægge veto';
  }

  @override
  String get guestRole => 'gæst';

  @override
  String get removeCoDj => 'Fjern co-DJ';

  @override
  String get promoteCoDj => 'Gør til co-DJ';

  @override
  String get blockGuest => 'Bloker';

  @override
  String get searchSoundCloudHint => 'Søg på SoundCloud…';

  @override
  String trackAdded(String title) {
    return '“$title” tilføjet';
  }

  @override
  String get playlistSearchHint => 'Kunstner eller Kunstner - Sang...';

  @override
  String get playlistIdle => 'Skriv et band eller en sang';

  @override
  String searchingFor(String query) {
    return 'Søger efter “$query”…';
  }

  @override
  String get similarByBpm => 'Lignende (sorteret efter BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Fejl: $message';
  }

  @override
  String get toastNoNextTrack => 'Fandt ikke flere numre – tilføj et til køen';

  @override
  String get toastPickingNext => 'Vælger næste nummer…';

  @override
  String toastCannotPlay(String title) {
    return 'Kan ikke afspille “$title” – springer over';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay ikke tilgængelig: $error';
  }
}
