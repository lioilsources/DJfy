// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · fronta: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Party $code';
  }

  @override
  String get addDeck => 'PŘIDAT DECK';

  @override
  String get deckDropHint => 'Přetáhni track sem';

  @override
  String get deckWaitingForQueue => 'Čeká na frontu';

  @override
  String get dspUnavailable => 'DSP nedostupné (HLS stream)';

  @override
  String get bpmUnknown => 'BPM neznámé';

  @override
  String get genericError => 'Chyba';

  @override
  String get partyTagline =>
      'Tvůj telefon je DJ. Reproduktor je jen reproduktor.';

  @override
  String get partyIntro =>
      'Hosté naskenují QR, hledají a hlasují v prohlížeči – bez appky a bez účtu. Fronta žije u tebe, zvuk pošleš přes AirPlay nebo Bluetooth.';

  @override
  String get partyNameLabel => 'Název party';

  @override
  String get startParty => 'ZALOŽIT PARTY';

  @override
  String get back => 'ZPĚT';

  @override
  String get qrForGuests => 'QR pro hosty';

  @override
  String get endParty => 'Ukončit party';

  @override
  String get endPartyQuestion => 'Ukončit party?';

  @override
  String get endPartyWarning => 'Hosté se odpojí a fronta se smaže.';

  @override
  String get no => 'NE';

  @override
  String get endAction => 'UKONČIT';

  @override
  String get tabQueue => 'FRONTA';

  @override
  String get tabGuests => 'HOSTÉ';

  @override
  String get tabSearch => 'HLEDAT';

  @override
  String get copyLink => 'KOPÍROVAT ODKAZ';

  @override
  String get queueEmpty => 'Fronta je prázdná';

  @override
  String get readyPressPlay => 'Připraveno – zmáčkni ▶';

  @override
  String addedBy(String name) {
    return 'přidal(a) $name';
  }

  @override
  String get keepGoing => 'NEKONČIT';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Skladby mimo rozsah zůstanou ve frontě, ale nezahrají se samy.';

  @override
  String get turnOff => 'VYPNOUT';

  @override
  String get lockAction => 'ZAMKNOUT';

  @override
  String get queueEmptyHint => 'Zatím nic. Přidej skladbu nebo ukaž hostům QR.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Hrát hned';

  @override
  String get playNext => 'Hrát příští';

  @override
  String get unpin => 'Odepnout';

  @override
  String get noGuestsYet => 'Zatím nikdo nedorazil';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · hlas ×$weight, může dát veto';
  }

  @override
  String get guestRole => 'host';

  @override
  String get removeCoDj => 'Odebrat co-DJ';

  @override
  String get promoteCoDj => 'Povýšit na co-DJ';

  @override
  String get blockGuest => 'Zablokovat';

  @override
  String get searchSoundCloudHint => 'Hledat na SoundCloudu…';

  @override
  String trackAdded(String title) {
    return '„$title“ přidáno';
  }

  @override
  String get playlistSearchHint => 'Interpret nebo Interpret - Song...';

  @override
  String get playlistIdle => 'Zadej kapelu nebo song';

  @override
  String searchingFor(String query) {
    return 'Hledám „$query“…';
  }

  @override
  String get similarByBpm => 'Podobné (seřazeno dle BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Chyba: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Nenašel jsem další skladbu – přidej nějakou do fronty';

  @override
  String get toastPickingNext => 'Vybírám další skladbu…';

  @override
  String toastCannotPlay(String title) {
    return 'Nejde přehrát „$title“ – přeskakuju';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay nedostupný: $error';
  }
}
