// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · قطار: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'پارٹی $code';
  }

  @override
  String get addDeck => 'ڈیک شامل کریں';

  @override
  String get deckDropHint => 'ٹریک یہاں گھسیٹیں';

  @override
  String get deckWaitingForQueue => 'قطار کا انتظار';

  @override
  String get dspUnavailable => 'DSP دستیاب نہیں (HLS اسٹریم)';

  @override
  String get bpmUnknown => 'BPM نامعلوم';

  @override
  String get genericError => 'خرابی';

  @override
  String get partyTagline => 'آپ کا فون ڈی جے ہے۔ اسپیکر صرف اسپیکر ہے۔';

  @override
  String get partyIntro =>
      'مہمان QR کوڈ اسکین کرتے ہیں، براؤزر میں تلاش کرتے اور ووٹ دیتے ہیں – بغیر ایپ اور بغیر اکاؤنٹ کے۔ قطار آپ کے پاس رہتی ہے، آواز AirPlay یا Bluetooth سے بھیجیں۔';

  @override
  String get partyNameLabel => 'پارٹی کا نام';

  @override
  String get startParty => 'پارٹی شروع کریں';

  @override
  String get back => 'واپس';

  @override
  String get qrForGuests => 'مہمانوں کے لیے QR';

  @override
  String get endParty => 'پارٹی ختم کریں';

  @override
  String get endPartyQuestion => 'پارٹی ختم کریں؟';

  @override
  String get endPartyWarning =>
      'مہمانوں کا رابطہ منقطع ہو جائے گا اور قطار مٹ جائے گی۔';

  @override
  String get no => 'نہیں';

  @override
  String get endAction => 'ختم کریں';

  @override
  String get tabQueue => 'قطار';

  @override
  String get tabGuests => 'مہمان';

  @override
  String get tabSearch => 'تلاش';

  @override
  String get copyLink => 'لنک کاپی کریں';

  @override
  String get queueEmpty => 'قطار خالی ہے';

  @override
  String get readyPressPlay => 'تیار – ▶ دبائیں';

  @override
  String addedBy(String name) {
    return '$name نے شامل کیا';
  }

  @override
  String get keepGoing => 'بغیر رکے';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'رینج سے باہر کے ٹریک قطار میں رہیں گے، لیکن خود نہیں چلیں گے۔';

  @override
  String get turnOff => 'بند کریں';

  @override
  String get lockAction => 'لاک کریں';

  @override
  String get queueEmptyHint =>
      'ابھی کچھ نہیں۔ کوئی ٹریک شامل کریں یا مہمانوں کو QR دکھائیں۔';

  @override
  String get vetoBadge => 'ویٹو';

  @override
  String get vetoMenu => 'ویٹو';

  @override
  String get playNow => 'ابھی چلائیں';

  @override
  String get playNext => 'اگلا چلائیں';

  @override
  String get unpin => 'پن ہٹائیں';

  @override
  String get noGuestsYet => 'ابھی کوئی نہیں آیا';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ووٹ ×$weight، ویٹو کر سکتا ہے';
  }

  @override
  String get guestRole => 'مہمان';

  @override
  String get removeCoDj => 'co-DJ ہٹائیں';

  @override
  String get promoteCoDj => 'co-DJ بنائیں';

  @override
  String get blockGuest => 'بلاک کریں';

  @override
  String get searchSoundCloudHint => 'SoundCloud پر تلاش کریں…';

  @override
  String trackAdded(String title) {
    return '“$title” شامل ہو گیا';
  }

  @override
  String get playlistSearchHint => 'فنکار یا فنکار - گانا...';

  @override
  String get playlistIdle => 'کوئی بینڈ یا گانا لکھیں';

  @override
  String searchingFor(String query) {
    return '“$query” تلاش ہو رہا ہے…';
  }

  @override
  String get similarByBpm => 'ملتے جلتے (BPM کے مطابق)';

  @override
  String errorWithMessage(String message) {
    return 'خرابی: $message';
  }

  @override
  String get toastNoNextTrack => 'اگلا ٹریک نہیں ملا – قطار میں کچھ شامل کریں';

  @override
  String get toastPickingNext => 'اگلا ٹریک منتخب ہو رہا ہے…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” نہیں چل سکا – چھوڑا جا رہا ہے';
  }

  @override
  String relayUnavailable(String error) {
    return 'ریلے دستیاب نہیں: $error';
  }
}
