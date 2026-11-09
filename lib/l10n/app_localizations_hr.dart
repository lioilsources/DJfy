// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · red: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Tulum $code';
  }

  @override
  String get addDeck => 'DODAJ DECK';

  @override
  String get deckDropHint => 'Povuci pjesmu ovamo';

  @override
  String get deckWaitingForQueue => 'Čeka red';

  @override
  String get dspUnavailable => 'DSP nije dostupan (HLS stream)';

  @override
  String get bpmUnknown => 'BPM nepoznat';

  @override
  String get genericError => 'Greška';

  @override
  String get partyTagline => 'Tvoj mobitel je DJ. Zvučnik je samo zvučnik.';

  @override
  String get partyIntro =>
      'Gosti skeniraju QR kôd, traže i glasaju u pregledniku – bez aplikacije i bez računa. Red je kod tebe, a zvuk šalješ preko AirPlaya ili Bluetootha.';

  @override
  String get partyNameLabel => 'Naziv tuluma';

  @override
  String get startParty => 'POKRENI TULUM';

  @override
  String get back => 'NATRAG';

  @override
  String get qrForGuests => 'QR za goste';

  @override
  String get endParty => 'Završi tulum';

  @override
  String get endPartyQuestion => 'Završiti tulum?';

  @override
  String get endPartyWarning => 'Gosti će se odspojiti, a red će se izbrisati.';

  @override
  String get no => 'NE';

  @override
  String get endAction => 'ZAVRŠI';

  @override
  String get tabQueue => 'RED';

  @override
  String get tabGuests => 'GOSTI';

  @override
  String get tabSearch => 'TRAŽI';

  @override
  String get copyLink => 'KOPIRAJ POVEZNICU';

  @override
  String get queueEmpty => 'Red je prazan';

  @override
  String get readyPressPlay => 'Spremno – pritisni ▶';

  @override
  String addedBy(String name) {
    return 'dodao/la $name';
  }

  @override
  String get keepGoing => 'BEZ PRESTANKA';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Pjesme izvan raspona ostaju u redu, ali se neće same pustiti.';

  @override
  String get turnOff => 'ISKLJUČI';

  @override
  String get lockAction => 'ZAKLJUČAJ';

  @override
  String get queueEmptyHint =>
      'Još ništa. Dodaj pjesmu ili pokaži gostima QR kôd.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Pusti odmah';

  @override
  String get playNext => 'Pusti sljedeće';

  @override
  String get unpin => 'Otkvači';

  @override
  String get noGuestsYet => 'Još nitko nije stigao';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · glas ×$weight, može staviti veto';
  }

  @override
  String get guestRole => 'gost';

  @override
  String get removeCoDj => 'Ukloni co-DJ';

  @override
  String get promoteCoDj => 'Unaprijedi u co-DJ';

  @override
  String get blockGuest => 'Blokiraj';

  @override
  String get searchSoundCloudHint => 'Traži na SoundCloudu…';

  @override
  String trackAdded(String title) {
    return '„$title” dodano';
  }

  @override
  String get playlistSearchHint => 'Izvođač ili Izvođač - Pjesma...';

  @override
  String get playlistIdle => 'Upiši bend ili pjesmu';

  @override
  String searchingFor(String query) {
    return 'Tražim „$query”…';
  }

  @override
  String get similarByBpm => 'Slično (poredano po BPM-u)';

  @override
  String errorWithMessage(String message) {
    return 'Greška: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Nisam našao sljedeću pjesmu – dodaj neku u red';

  @override
  String get toastPickingNext => 'Biram sljedeću pjesmu…';

  @override
  String toastCannotPlay(String title) {
    return 'Ne mogu pustiti „$title” – preskačem';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay nije dostupan: $error';
  }
}
