// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · kø: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Fest $code';
  }

  @override
  String get addDeck => 'LEGG TIL DECK';

  @override
  String get deckDropHint => 'Dra et spor hit';

  @override
  String get deckWaitingForQueue => 'Venter på køen';

  @override
  String get dspUnavailable => 'DSP ikke tilgjengelig (HLS-strøm)';

  @override
  String get bpmUnknown => 'BPM ukjent';

  @override
  String get genericError => 'Feil';

  @override
  String get partyTagline =>
      'Telefonen din er DJ-en. Høyttaleren er bare en høyttaler.';

  @override
  String get partyIntro =>
      'Gjestene skanner QR-koden, søker og stemmer i nettleseren – uten app og uten konto. Køen bor hos deg, og lyden sender du via AirPlay eller Bluetooth.';

  @override
  String get partyNameLabel => 'Navn på festen';

  @override
  String get startParty => 'START FEST';

  @override
  String get back => 'TILBAKE';

  @override
  String get qrForGuests => 'QR for gjester';

  @override
  String get endParty => 'Avslutt festen';

  @override
  String get endPartyQuestion => 'Avslutte festen?';

  @override
  String get endPartyWarning => 'Gjestene kobles fra, og køen tømmes.';

  @override
  String get no => 'NEI';

  @override
  String get endAction => 'AVSLUTT';

  @override
  String get tabQueue => 'KØ';

  @override
  String get tabGuests => 'GJESTER';

  @override
  String get tabSearch => 'SØK';

  @override
  String get copyLink => 'KOPIER LENKE';

  @override
  String get queueEmpty => 'Køen er tom';

  @override
  String get readyPressPlay => 'Klar – trykk på ▶';

  @override
  String addedBy(String name) {
    return 'lagt til av $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Spor utenfor intervallet blir i køen, men spilles ikke av seg selv.';

  @override
  String get turnOff => 'SLÅ AV';

  @override
  String get lockAction => 'LÅS';

  @override
  String get queueEmptyHint =>
      'Ingenting ennå. Legg til et spor eller vis gjestene QR-koden.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Spill nå';

  @override
  String get playNext => 'Spill som neste';

  @override
  String get unpin => 'Løsne';

  @override
  String get noGuestsYet => 'Ingen har kommet ennå';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · stemme ×$weight, kan nedlegge veto';
  }

  @override
  String get guestRole => 'gjest';

  @override
  String get removeCoDj => 'Fjern co-DJ';

  @override
  String get promoteCoDj => 'Gjør til co-DJ';

  @override
  String get blockGuest => 'Blokker';

  @override
  String get searchSoundCloudHint => 'Søk på SoundCloud…';

  @override
  String trackAdded(String title) {
    return '«$title» lagt til';
  }

  @override
  String get playlistSearchHint => 'Artist eller Artist - Sang...';

  @override
  String get playlistIdle => 'Skriv inn et band eller en sang';

  @override
  String searchingFor(String query) {
    return 'Søker etter «$query»…';
  }

  @override
  String get similarByBpm => 'Lignende (sortert etter BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Feil: $message';
  }

  @override
  String get toastNoNextTrack => 'Fant ikke flere spor – legg til et i køen';

  @override
  String get toastPickingNext => 'Velger neste spor…';

  @override
  String toastCannotPlay(String title) {
    return 'Kan ikke spille «$title» – hopper over';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay ikke tilgjengelig: $error';
  }
}
