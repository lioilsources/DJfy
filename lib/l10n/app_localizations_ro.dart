// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · coadă: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Petrecere $code';
  }

  @override
  String get addDeck => 'ADAUGĂ DECK';

  @override
  String get deckDropHint => 'Trage o piesă aici';

  @override
  String get deckWaitingForQueue => 'Așteaptă coada';

  @override
  String get dspUnavailable => 'DSP indisponibil (stream HLS)';

  @override
  String get bpmUnknown => 'BPM necunoscut';

  @override
  String get genericError => 'Eroare';

  @override
  String get partyTagline => 'Telefonul tău e DJ-ul. Boxa e doar o boxă.';

  @override
  String get partyIntro =>
      'Invitații scanează codul QR, caută și votează în browser – fără aplicație și fără cont. Coada stă la tine, iar sunetul îl trimiți prin AirPlay sau Bluetooth.';

  @override
  String get partyNameLabel => 'Numele petrecerii';

  @override
  String get startParty => 'PORNEȘTE PETRECEREA';

  @override
  String get back => 'ÎNAPOI';

  @override
  String get qrForGuests => 'QR pentru invitați';

  @override
  String get endParty => 'Încheie petrecerea';

  @override
  String get endPartyQuestion => 'Închei petrecerea?';

  @override
  String get endPartyWarning =>
      'Invitații vor fi deconectați, iar coada va fi ștearsă.';

  @override
  String get no => 'NU';

  @override
  String get endAction => 'ÎNCHEIE';

  @override
  String get tabQueue => 'COADĂ';

  @override
  String get tabGuests => 'INVITAȚI';

  @override
  String get tabSearch => 'CAUTĂ';

  @override
  String get copyLink => 'COPIAZĂ LINKUL';

  @override
  String get queueEmpty => 'Coada e goală';

  @override
  String get readyPressPlay => 'Gata – apasă ▶';

  @override
  String addedBy(String name) {
    return 'adăugată de $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Piesele din afara intervalului rămân în coadă, dar nu pornesc singure.';

  @override
  String get turnOff => 'OPREȘTE';

  @override
  String get lockAction => 'BLOCHEAZĂ';

  @override
  String get queueEmptyHint =>
      'Nimic deocamdată. Adaugă o piesă sau arată-le invitaților codul QR.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Redă acum';

  @override
  String get playNext => 'Redă următoarea';

  @override
  String get unpin => 'Anulează fixarea';

  @override
  String get noGuestsYet => 'N-a venit încă nimeni';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · vot ×$weight, poate da veto';
  }

  @override
  String get guestRole => 'invitat';

  @override
  String get removeCoDj => 'Elimină co-DJ';

  @override
  String get promoteCoDj => 'Promovează co-DJ';

  @override
  String get blockGuest => 'Blochează';

  @override
  String get searchSoundCloudHint => 'Caută pe SoundCloud…';

  @override
  String trackAdded(String title) {
    return '„$title” adăugată';
  }

  @override
  String get playlistSearchHint => 'Artist sau Artist - Piesă...';

  @override
  String get playlistIdle => 'Introdu o trupă sau o piesă';

  @override
  String searchingFor(String query) {
    return 'Caut „$query”…';
  }

  @override
  String get similarByBpm => 'Similare (după BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Eroare: $message';
  }

  @override
  String get toastNoNextTrack => 'N-am găsit altă piesă – adaugă una în coadă';

  @override
  String get toastPickingNext => 'Aleg următoarea piesă…';

  @override
  String toastCannotPlay(String title) {
    return 'Nu pot reda „$title” – trec peste';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay indisponibil: $error';
  }
}
