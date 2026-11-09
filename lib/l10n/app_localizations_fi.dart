// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · jono: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Bileet $code';
  }

  @override
  String get addDeck => 'LISÄÄ DECK';

  @override
  String get deckDropHint => 'Vedä kappale tähän';

  @override
  String get deckWaitingForQueue => 'Odottaa jonoa';

  @override
  String get dspUnavailable => 'DSP ei käytettävissä (HLS-striimi)';

  @override
  String get bpmUnknown => 'BPM tuntematon';

  @override
  String get genericError => 'Virhe';

  @override
  String get partyTagline => 'Puhelimesi on DJ. Kaiutin on vain kaiutin.';

  @override
  String get partyIntro =>
      'Vieraat skannaavat QR-koodin, hakevat ja äänestävät selaimessa – ilman sovellusta ja tiliä. Jono on sinun puhelimessasi, ja äänen lähetät AirPlayn tai Bluetoothin kautta.';

  @override
  String get partyNameLabel => 'Bileiden nimi';

  @override
  String get startParty => 'ALOITA BILEET';

  @override
  String get back => 'TAKAISIN';

  @override
  String get qrForGuests => 'QR vieraille';

  @override
  String get endParty => 'Lopeta bileet';

  @override
  String get endPartyQuestion => 'Lopetetaanko bileet?';

  @override
  String get endPartyWarning =>
      'Vieraiden yhteys katkeaa ja jono tyhjennetään.';

  @override
  String get no => 'EI';

  @override
  String get endAction => 'LOPETA';

  @override
  String get tabQueue => 'JONO';

  @override
  String get tabGuests => 'VIERAAT';

  @override
  String get tabSearch => 'HAE';

  @override
  String get copyLink => 'KOPIOI LINKKI';

  @override
  String get queueEmpty => 'Jono on tyhjä';

  @override
  String get readyPressPlay => 'Valmis – paina ▶';

  @override
  String addedBy(String name) {
    return 'lisännyt $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Alueen ulkopuoliset kappaleet jäävät jonoon, mutta eivät soi itsestään.';

  @override
  String get turnOff => 'POIS PÄÄLTÄ';

  @override
  String get lockAction => 'LUKITSE';

  @override
  String get queueEmptyHint =>
      'Ei vielä mitään. Lisää kappale tai näytä vieraille QR-koodi.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Soita nyt';

  @override
  String get playNext => 'Soita seuraavaksi';

  @override
  String get unpin => 'Irrota';

  @override
  String get noGuestsYet => 'Kukaan ei ole vielä tullut';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ääni ×$weight, voi käyttää vetoa';
  }

  @override
  String get guestRole => 'vieras';

  @override
  String get removeCoDj => 'Poista co-DJ';

  @override
  String get promoteCoDj => 'Ylennä co-DJ:ksi';

  @override
  String get blockGuest => 'Estä';

  @override
  String get searchSoundCloudHint => 'Hae SoundCloudista…';

  @override
  String trackAdded(String title) {
    return '”$title” lisätty';
  }

  @override
  String get playlistSearchHint => 'Artisti tai Artisti - Kappale...';

  @override
  String get playlistIdle => 'Kirjoita bändi tai kappale';

  @override
  String searchingFor(String query) {
    return 'Haetaan ”$query”…';
  }

  @override
  String get similarByBpm => 'Samankaltaiset (BPM:n mukaan)';

  @override
  String errorWithMessage(String message) {
    return 'Virhe: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Seuraavaa kappaletta ei löytynyt – lisää jokin jonoon';

  @override
  String get toastPickingNext => 'Valitaan seuraavaa kappaletta…';

  @override
  String toastCannotPlay(String title) {
    return 'Kappaletta ”$title” ei voi toistaa – ohitetaan';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay ei käytettävissä: $error';
  }
}
