// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · sor: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Buli $code';
  }

  @override
  String get addDeck => 'DECK HOZZÁADÁSA';

  @override
  String get deckDropHint => 'Húzz ide egy számot';

  @override
  String get deckWaitingForQueue => 'A sorra vár';

  @override
  String get dspUnavailable => 'A DSP nem elérhető (HLS-stream)';

  @override
  String get bpmUnknown => 'Ismeretlen BPM';

  @override
  String get genericError => 'Hiba';

  @override
  String get partyTagline => 'A telefonod a DJ. A hangszóró csak hangszóró.';

  @override
  String get partyIntro =>
      'A vendégek beolvassák a QR-kódot, keresnek és szavaznak a böngészőben – app és fiók nélkül. A sor nálad van, a hangot AirPlayen vagy Bluetoothon küldöd.';

  @override
  String get partyNameLabel => 'A buli neve';

  @override
  String get startParty => 'BULI INDÍTÁSA';

  @override
  String get back => 'VISSZA';

  @override
  String get qrForGuests => 'QR a vendégeknek';

  @override
  String get endParty => 'Buli befejezése';

  @override
  String get endPartyQuestion => 'Befejezed a bulit?';

  @override
  String get endPartyWarning =>
      'A vendégek kapcsolata megszakad, a sor törlődik.';

  @override
  String get no => 'NEM';

  @override
  String get endAction => 'BEFEJEZÉS';

  @override
  String get tabQueue => 'SOR';

  @override
  String get tabGuests => 'VENDÉGEK';

  @override
  String get tabSearch => 'KERESÉS';

  @override
  String get copyLink => 'LINK MÁSOLÁSA';

  @override
  String get queueEmpty => 'A sor üres';

  @override
  String get readyPressPlay => 'Kész – nyomd meg: ▶';

  @override
  String addedBy(String name) {
    return 'hozzáadta: $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'A tartományon kívüli számok a sorban maradnak, de maguktól nem szólalnak meg.';

  @override
  String get turnOff => 'KIKAPCSOLÁS';

  @override
  String get lockAction => 'ZÁROLÁS';

  @override
  String get queueEmptyHint =>
      'Még semmi. Adj hozzá egy számot, vagy mutasd meg a vendégeknek a QR-kódot.';

  @override
  String get vetoBadge => 'VÉTÓ';

  @override
  String get vetoMenu => 'Vétó';

  @override
  String get playNow => 'Lejátszás most';

  @override
  String get playNext => 'Lejátszás következőként';

  @override
  String get unpin => 'Rögzítés feloldása';

  @override
  String get noGuestsYet => 'Még senki sem érkezett';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · szavazat ×$weight, vétózhat';
  }

  @override
  String get guestRole => 'vendég';

  @override
  String get removeCoDj => 'Co-DJ elvétele';

  @override
  String get promoteCoDj => 'Előléptetés co-DJ-vé';

  @override
  String get blockGuest => 'Letiltás';

  @override
  String get searchSoundCloudHint => 'Keresés a SoundCloudon…';

  @override
  String trackAdded(String title) {
    return '„$title” hozzáadva';
  }

  @override
  String get playlistSearchHint => 'Előadó vagy Előadó - Dal...';

  @override
  String get playlistIdle => 'Írj be egy zenekart vagy dalt';

  @override
  String searchingFor(String query) {
    return 'Keresés: „$query”…';
  }

  @override
  String get similarByBpm => 'Hasonlók (BPM szerint)';

  @override
  String errorWithMessage(String message) {
    return 'Hiba: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Nem találtam következő számot – adj hozzá egyet a sorhoz';

  @override
  String get toastPickingNext => 'A következő szám kiválasztása…';

  @override
  String toastCannotPlay(String title) {
    return 'A(z) „$title” nem játszható le – kihagyom';
  }

  @override
  String relayUnavailable(String error) {
    return 'A relay nem elérhető: $error';
  }
}
