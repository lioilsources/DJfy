// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · قائمة الانتظار: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'حفلة $code';
  }

  @override
  String get addDeck => 'إضافة منصة';

  @override
  String get deckDropHint => 'اسحب مقطعًا إلى هنا';

  @override
  String get deckWaitingForQueue => 'بانتظار قائمة الانتظار';

  @override
  String get dspUnavailable => 'DSP غير متاح (بث HLS)';

  @override
  String get bpmUnknown => 'BPM غير معروف';

  @override
  String get genericError => 'خطأ';

  @override
  String get partyTagline => 'هاتفك هو الدي جي. والسماعة مجرد سماعة.';

  @override
  String get partyIntro =>
      'يمسح الضيوف رمز QR ويبحثون ويصوّتون في المتصفح – بلا تطبيق وبلا حساب. قائمة الانتظار عندك، وترسل الصوت عبر AirPlay أو Bluetooth.';

  @override
  String get partyNameLabel => 'اسم الحفلة';

  @override
  String get startParty => 'بدء الحفلة';

  @override
  String get back => 'رجوع';

  @override
  String get qrForGuests => 'رمز QR للضيوف';

  @override
  String get endParty => 'إنهاء الحفلة';

  @override
  String get endPartyQuestion => 'هل تريد إنهاء الحفلة؟';

  @override
  String get endPartyWarning => 'سيُفصل الضيوف وستُحذف قائمة الانتظار.';

  @override
  String get no => 'لا';

  @override
  String get endAction => 'إنهاء';

  @override
  String get tabQueue => 'قائمة الانتظار';

  @override
  String get tabGuests => 'الضيوف';

  @override
  String get tabSearch => 'بحث';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get queueEmpty => 'قائمة الانتظار فارغة';

  @override
  String get readyPressPlay => 'جاهز – اضغط ▶';

  @override
  String addedBy(String name) {
    return 'أضافه $name';
  }

  @override
  String get keepGoing => 'بلا توقف';

  @override
  String get moodLock => 'قفل الإيقاع';

  @override
  String get moodLockHint =>
      'تبقى المقاطع خارج النطاق في قائمة الانتظار، لكنها لن تُشغَّل تلقائيًا.';

  @override
  String get turnOff => 'إيقاف';

  @override
  String get lockAction => 'قفل';

  @override
  String get queueEmptyHint =>
      'لا شيء بعد. أضف مقطعًا أو اعرض رمز QR على الضيوف.';

  @override
  String get vetoBadge => 'فيتو';

  @override
  String get vetoMenu => 'فيتو';

  @override
  String get playNow => 'تشغيل الآن';

  @override
  String get playNext => 'تشغيل تاليًا';

  @override
  String get unpin => 'إلغاء التثبيت';

  @override
  String get noGuestsYet => 'لم يصل أحد بعد';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · صوت ×$weight، يمكنه استخدام الفيتو';
  }

  @override
  String get guestRole => 'ضيف';

  @override
  String get removeCoDj => 'إزالة co-DJ';

  @override
  String get promoteCoDj => 'ترقية إلى co-DJ';

  @override
  String get blockGuest => 'حظر';

  @override
  String get searchSoundCloudHint => 'ابحث في SoundCloud…';

  @override
  String trackAdded(String title) {
    return 'تمت إضافة «$title»';
  }

  @override
  String get playlistSearchHint => 'الفنان أو الفنان - الأغنية...';

  @override
  String get playlistIdle => 'اكتب اسم فرقة أو أغنية';

  @override
  String searchingFor(String query) {
    return 'جارٍ البحث عن «$query»…';
  }

  @override
  String get similarByBpm => 'مشابهة (مرتبة حسب BPM)';

  @override
  String errorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get toastNoNextTrack =>
      'لم أجد مقطعًا آخر – أضف مقطعًا إلى قائمة الانتظار';

  @override
  String get toastPickingNext => 'جارٍ اختيار المقطع التالي…';

  @override
  String toastCannotPlay(String title) {
    return 'تعذّر تشغيل «$title» – جارٍ التخطي';
  }

  @override
  String relayUnavailable(String error) {
    return 'خادم الترحيل غير متاح: $error';
  }
}
