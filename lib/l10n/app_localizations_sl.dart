// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · vrsta: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Zabava $code';
  }

  @override
  String get addDeck => 'DODAJ DECK';

  @override
  String get deckDropHint => 'Povleci skladbo sem';

  @override
  String get deckWaitingForQueue => 'Čaka na vrsto';

  @override
  String get dspUnavailable => 'DSP ni na voljo (pretok HLS)';

  @override
  String get bpmUnknown => 'BPM neznan';

  @override
  String get genericError => 'Napaka';

  @override
  String get partyTagline => 'Tvoj telefon je DJ. Zvočnik je samo zvočnik.';

  @override
  String get partyIntro =>
      'Gostje skenirajo kodo QR, iščejo in glasujejo v brskalniku – brez aplikacije in brez računa. Vrsta živi pri tebi, zvok pošlješ prek AirPlay ali Bluetooth.';

  @override
  String get partyNameLabel => 'Ime zabave';

  @override
  String get startParty => 'ZAČNI ZABAVO';

  @override
  String get back => 'NAZAJ';

  @override
  String get qrForGuests => 'QR za goste';

  @override
  String get endParty => 'Končaj zabavo';

  @override
  String get endPartyQuestion => 'Končam zabavo?';

  @override
  String get endPartyWarning => 'Gostje bodo odklopljeni, vrsta pa izbrisana.';

  @override
  String get no => 'NE';

  @override
  String get endAction => 'KONČAJ';

  @override
  String get tabQueue => 'VRSTA';

  @override
  String get tabGuests => 'GOSTJE';

  @override
  String get tabSearch => 'IŠČI';

  @override
  String get copyLink => 'KOPIRAJ POVEZAVO';

  @override
  String get queueEmpty => 'Vrsta je prazna';

  @override
  String get readyPressPlay => 'Pripravljeno – pritisni ▶';

  @override
  String addedBy(String name) {
    return 'dodal(a) $name';
  }

  @override
  String get keepGoing => 'BREZ KONCA';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Skladbe zunaj razpona ostanejo v vrsti, a se ne bodo predvajale same.';

  @override
  String get turnOff => 'IZKLOPI';

  @override
  String get lockAction => 'ZAKLENI';

  @override
  String get queueEmptyHint =>
      'Še nič. Dodaj skladbo ali pokaži gostom kodo QR.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Predvajaj zdaj';

  @override
  String get playNext => 'Predvajaj naslednjo';

  @override
  String get unpin => 'Odpni';

  @override
  String get noGuestsYet => 'Še nihče ni prišel';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · glas ×$weight, lahko vloži veto';
  }

  @override
  String get guestRole => 'gost';

  @override
  String get removeCoDj => 'Odvzemi co-DJ';

  @override
  String get promoteCoDj => 'Povišaj v co-DJ';

  @override
  String get blockGuest => 'Blokiraj';

  @override
  String get searchSoundCloudHint => 'Išči na SoundCloudu…';

  @override
  String trackAdded(String title) {
    return '»$title« dodano';
  }

  @override
  String get playlistSearchHint => 'Izvajalec ali Izvajalec - Pesem...';

  @override
  String get playlistIdle => 'Vpiši skupino ali pesem';

  @override
  String searchingFor(String query) {
    return 'Iščem »$query«…';
  }

  @override
  String get similarByBpm => 'Podobne (razvrščene po BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Napaka: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Nisem našel naslednje skladbe – dodaj kakšno v vrsto';

  @override
  String get toastPickingNext => 'Izbiram naslednjo skladbo…';

  @override
  String toastCannotPlay(String title) {
    return 'Skladbe »$title« ni mogoče predvajati – preskakujem';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay ni na voljo: $error';
  }
}
