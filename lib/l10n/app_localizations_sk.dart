// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · fronta: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Party $code';
  }

  @override
  String get addDeck => 'PRIDAŤ DECK';

  @override
  String get deckDropHint => 'Pretiahni sem track';

  @override
  String get deckWaitingForQueue => 'Čaká na frontu';

  @override
  String get dspUnavailable => 'DSP nedostupné (HLS stream)';

  @override
  String get bpmUnknown => 'BPM neznáme';

  @override
  String get genericError => 'Chyba';

  @override
  String get partyTagline =>
      'Tvoj telefón je DJ. Reproduktor je len reproduktor.';

  @override
  String get partyIntro =>
      'Hostia naskenujú QR, hľadajú a hlasujú v prehliadači – bez appky a bez účtu. Fronta žije u teba, zvuk pošleš cez AirPlay alebo Bluetooth.';

  @override
  String get partyNameLabel => 'Názov party';

  @override
  String get startParty => 'ZALOŽIŤ PARTY';

  @override
  String get back => 'SPÄŤ';

  @override
  String get qrForGuests => 'QR pre hostí';

  @override
  String get endParty => 'Ukončiť party';

  @override
  String get endPartyQuestion => 'Ukončiť party?';

  @override
  String get endPartyWarning => 'Hostia sa odpoja a fronta sa vymaže.';

  @override
  String get no => 'NIE';

  @override
  String get endAction => 'UKONČIŤ';

  @override
  String get tabQueue => 'FRONTA';

  @override
  String get tabGuests => 'HOSTIA';

  @override
  String get tabSearch => 'HĽADAŤ';

  @override
  String get copyLink => 'KOPÍROVAŤ ODKAZ';

  @override
  String get queueEmpty => 'Fronta je prázdna';

  @override
  String get readyPressPlay => 'Pripravené – stlač ▶';

  @override
  String addedBy(String name) {
    return 'pridal(a) $name';
  }

  @override
  String get keepGoing => 'NEKONČIŤ';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Skladby mimo rozsah zostanú vo fronte, ale samy sa nezahrajú.';

  @override
  String get turnOff => 'VYPNÚŤ';

  @override
  String get lockAction => 'ZAMKNÚŤ';

  @override
  String get queueEmptyHint =>
      'Zatiaľ nič. Pridaj skladbu alebo ukáž hosťom QR.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Hrať hneď';

  @override
  String get playNext => 'Hrať ako ďalšiu';

  @override
  String get unpin => 'Odopnúť';

  @override
  String get noGuestsYet => 'Zatiaľ nikto neprišiel';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · hlas ×$weight, môže dať veto';
  }

  @override
  String get guestRole => 'hosť';

  @override
  String get removeCoDj => 'Odobrať co-DJ';

  @override
  String get promoteCoDj => 'Povýšiť na co-DJ';

  @override
  String get blockGuest => 'Zablokovať';

  @override
  String get searchSoundCloudHint => 'Hľadať na SoundCloude…';

  @override
  String trackAdded(String title) {
    return '„$title“ pridané';
  }

  @override
  String get playlistSearchHint => 'Interpret alebo Interpret - Pieseň...';

  @override
  String get playlistIdle => 'Zadaj kapelu alebo pieseň';

  @override
  String searchingFor(String query) {
    return 'Hľadám „$query“…';
  }

  @override
  String get similarByBpm => 'Podobné (zoradené podľa BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Chyba: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Nenašiel som ďalšiu skladbu – pridaj nejakú do fronty';

  @override
  String get toastPickingNext => 'Vyberám ďalšiu skladbu…';

  @override
  String toastCannotPlay(String title) {
    return 'Nedá sa prehrať „$title“ – preskakujem';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay nedostupný: $error';
  }
}
