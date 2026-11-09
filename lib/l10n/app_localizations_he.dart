// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · בתור: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'מסיבה $code';
  }

  @override
  String get addDeck => 'הוספת דק';

  @override
  String get deckDropHint => 'גרור לכאן רצועה';

  @override
  String get deckWaitingForQueue => 'ממתין לתור';

  @override
  String get dspUnavailable => 'DSP לא זמין (שידור HLS)';

  @override
  String get bpmUnknown => 'BPM לא ידוע';

  @override
  String get genericError => 'שגיאה';

  @override
  String get partyTagline => 'הטלפון שלך הוא הדי־ג׳יי. הרמקול הוא רק רמקול.';

  @override
  String get partyIntro =>
      'האורחים סורקים את קוד ה־QR, מחפשים ומצביעים בדפדפן – בלי אפליקציה ובלי חשבון. התור נשאר אצלך, ואת הסאונד שולחים דרך AirPlay או Bluetooth.';

  @override
  String get partyNameLabel => 'שם המסיבה';

  @override
  String get startParty => 'פתיחת מסיבה';

  @override
  String get back => 'חזרה';

  @override
  String get qrForGuests => 'QR לאורחים';

  @override
  String get endParty => 'סיום המסיבה';

  @override
  String get endPartyQuestion => 'לסיים את המסיבה?';

  @override
  String get endPartyWarning => 'האורחים ינותקו והתור יימחק.';

  @override
  String get no => 'לא';

  @override
  String get endAction => 'סיום';

  @override
  String get tabQueue => 'תור';

  @override
  String get tabGuests => 'אורחים';

  @override
  String get tabSearch => 'חיפוש';

  @override
  String get copyLink => 'העתקת קישור';

  @override
  String get queueEmpty => 'התור ריק';

  @override
  String get readyPressPlay => 'מוכן – לחץ ▶';

  @override
  String addedBy(String name) {
    return 'נוסף על ידי $name';
  }

  @override
  String get keepGoing => 'בלי הפסקה';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'רצועות מחוץ לטווח יישארו בתור, אבל לא יתנגנו מעצמן.';

  @override
  String get turnOff => 'כיבוי';

  @override
  String get lockAction => 'נעילה';

  @override
  String get queueEmptyHint =>
      'עדיין כלום. הוסף רצועה או הראה לאורחים את קוד ה־QR.';

  @override
  String get vetoBadge => 'וטו';

  @override
  String get vetoMenu => 'וטו';

  @override
  String get playNow => 'נגן עכשיו';

  @override
  String get playNext => 'נגן הבא';

  @override
  String get unpin => 'ביטול הצמדה';

  @override
  String get noGuestsYet => 'עוד אף אחד לא הגיע';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · קול ×$weight, יכול להטיל וטו';
  }

  @override
  String get guestRole => 'אורח';

  @override
  String get removeCoDj => 'הסרת co-DJ';

  @override
  String get promoteCoDj => 'קידום ל־co-DJ';

  @override
  String get blockGuest => 'חסימה';

  @override
  String get searchSoundCloudHint => 'חיפוש ב־SoundCloud…';

  @override
  String trackAdded(String title) {
    return '„$title” נוסף';
  }

  @override
  String get playlistSearchHint => 'אמן או אמן - שיר...';

  @override
  String get playlistIdle => 'הקלד להקה או שיר';

  @override
  String searchingFor(String query) {
    return 'מחפש „$query”…';
  }

  @override
  String get similarByBpm => 'דומים (לפי BPM)';

  @override
  String errorWithMessage(String message) {
    return 'שגיאה: $message';
  }

  @override
  String get toastNoNextTrack => 'לא מצאתי רצועה נוספת – הוסף משהו לתור';

  @override
  String get toastPickingNext => 'בוחר את הרצועה הבאה…';

  @override
  String toastCannotPlay(String title) {
    return 'אי אפשר לנגן את „$title” – מדלג';
  }

  @override
  String relayUnavailable(String error) {
    return 'שרת הממסר לא זמין: $error';
  }
}
