// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · ουρά: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Πάρτι $code';
  }

  @override
  String get addDeck => 'ΠΡΟΣΘΗΚΗ DECK';

  @override
  String get deckDropHint => 'Σύρε ένα κομμάτι εδώ';

  @override
  String get deckWaitingForQueue => 'Αναμονή για την ουρά';

  @override
  String get dspUnavailable => 'Το DSP δεν είναι διαθέσιμο (ροή HLS)';

  @override
  String get bpmUnknown => 'Άγνωστο BPM';

  @override
  String get genericError => 'Σφάλμα';

  @override
  String get partyTagline =>
      'Το κινητό σου είναι ο DJ. Το ηχείο είναι απλώς ένα ηχείο.';

  @override
  String get partyIntro =>
      'Οι καλεσμένοι σκανάρουν τον κωδικό QR, ψάχνουν και ψηφίζουν στον browser – χωρίς εφαρμογή και χωρίς λογαριασμό. Η ουρά μένει σε σένα και τον ήχο τον στέλνεις μέσω AirPlay ή Bluetooth.';

  @override
  String get partyNameLabel => 'Όνομα πάρτι';

  @override
  String get startParty => 'ΕΝΑΡΞΗ ΠΑΡΤΙ';

  @override
  String get back => 'ΠΙΣΩ';

  @override
  String get qrForGuests => 'QR για καλεσμένους';

  @override
  String get endParty => 'Λήξη πάρτι';

  @override
  String get endPartyQuestion => 'Λήξη του πάρτι;';

  @override
  String get endPartyWarning =>
      'Οι καλεσμένοι θα αποσυνδεθούν και η ουρά θα διαγραφεί.';

  @override
  String get no => 'ΟΧΙ';

  @override
  String get endAction => 'ΛΗΞΗ';

  @override
  String get tabQueue => 'ΟΥΡΑ';

  @override
  String get tabGuests => 'ΚΑΛΕΣΜΕΝΟΙ';

  @override
  String get tabSearch => 'ΑΝΑΖΗΤΗΣΗ';

  @override
  String get copyLink => 'ΑΝΤΙΓΡΑΦΗ ΣΥΝΔΕΣΜΟΥ';

  @override
  String get queueEmpty => 'Η ουρά είναι άδεια';

  @override
  String get readyPressPlay => 'Έτοιμο – πάτα ▶';

  @override
  String addedBy(String name) {
    return 'από $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Τα κομμάτια εκτός εύρους μένουν στην ουρά, αλλά δεν παίζουν μόνα τους.';

  @override
  String get turnOff => 'ΑΠΕΝΕΡΓΟΠΟΙΗΣΗ';

  @override
  String get lockAction => 'ΚΛΕΙΔΩΜΑ';

  @override
  String get queueEmptyHint =>
      'Τίποτα ακόμα. Πρόσθεσε ένα κομμάτι ή δείξε το QR στους καλεσμένους.';

  @override
  String get vetoBadge => 'ΒΕΤΟ';

  @override
  String get vetoMenu => 'Βέτο';

  @override
  String get playNow => 'Παίξε τώρα';

  @override
  String get playNext => 'Παίξε μετά';

  @override
  String get unpin => 'Ξεκαρφίτσωμα';

  @override
  String get noGuestsYet => 'Δεν έχει έρθει κανείς ακόμα';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ψήφος ×$weight, μπορεί να βάλει βέτο';
  }

  @override
  String get guestRole => 'καλεσμένος';

  @override
  String get removeCoDj => 'Αφαίρεση co-DJ';

  @override
  String get promoteCoDj => 'Προαγωγή σε co-DJ';

  @override
  String get blockGuest => 'Αποκλεισμός';

  @override
  String get searchSoundCloudHint => 'Αναζήτηση στο SoundCloud…';

  @override
  String trackAdded(String title) {
    return 'Προστέθηκε το «$title»';
  }

  @override
  String get playlistSearchHint => 'Καλλιτέχνης ή Καλλιτέχνης - Τραγούδι...';

  @override
  String get playlistIdle => 'Γράψε ένα συγκρότημα ή τραγούδι';

  @override
  String searchingFor(String query) {
    return 'Αναζήτηση «$query»…';
  }

  @override
  String get similarByBpm => 'Παρόμοια (κατά BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Σφάλμα: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Δεν βρέθηκε επόμενο κομμάτι – πρόσθεσε κάποιο στην ουρά';

  @override
  String get toastPickingNext => 'Επιλέγω το επόμενο κομμάτι…';

  @override
  String toastCannotPlay(String title) {
    return 'Δεν παίζει το «$title» – παράλειψη';
  }

  @override
  String relayUnavailable(String error) {
    return 'Το relay δεν είναι διαθέσιμο: $error';
  }
}
