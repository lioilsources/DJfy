// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · คิว: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'ปาร์ตี้ $code';
  }

  @override
  String get addDeck => 'เพิ่มเด็ค';

  @override
  String get deckDropHint => 'ลากแทร็กมาที่นี่';

  @override
  String get deckWaitingForQueue => 'รอคิว';

  @override
  String get dspUnavailable => 'ใช้ DSP ไม่ได้ (สตรีม HLS)';

  @override
  String get bpmUnknown => 'ไม่ทราบ BPM';

  @override
  String get genericError => 'ข้อผิดพลาด';

  @override
  String get partyTagline => 'มือถือของคุณคือดีเจ ลำโพงก็แค่ลำโพง';

  @override
  String get partyIntro =>
      'แขกสแกน QR ค้นหาและโหวตในเบราว์เซอร์ – ไม่ต้องมีแอป ไม่ต้องมีบัญชี คิวอยู่ที่คุณ ส่งเสียงผ่าน AirPlay หรือ Bluetooth';

  @override
  String get partyNameLabel => 'ชื่อปาร์ตี้';

  @override
  String get startParty => 'เริ่มปาร์ตี้';

  @override
  String get back => 'กลับ';

  @override
  String get qrForGuests => 'QR สำหรับแขก';

  @override
  String get endParty => 'จบปาร์ตี้';

  @override
  String get endPartyQuestion => 'จบปาร์ตี้ไหม';

  @override
  String get endPartyWarning => 'แขกจะถูกตัดการเชื่อมต่อและคิวจะถูกลบ';

  @override
  String get no => 'ไม่';

  @override
  String get endAction => 'จบ';

  @override
  String get tabQueue => 'คิว';

  @override
  String get tabGuests => 'แขก';

  @override
  String get tabSearch => 'ค้นหา';

  @override
  String get copyLink => 'คัดลอกลิงก์';

  @override
  String get queueEmpty => 'คิวว่าง';

  @override
  String get readyPressPlay => 'พร้อมแล้ว – กด ▶';

  @override
  String addedBy(String name) {
    return '$name เพิ่ม';
  }

  @override
  String get keepGoing => 'ไม่หยุด';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'แทร็กที่อยู่นอกช่วงจะยังอยู่ในคิว แต่จะไม่เล่นเอง';

  @override
  String get turnOff => 'ปิด';

  @override
  String get lockAction => 'ล็อก';

  @override
  String get queueEmptyHint => 'ยังไม่มีอะไร เพิ่มแทร็กหรือให้แขกดู QR';

  @override
  String get vetoBadge => 'วีโต้';

  @override
  String get vetoMenu => 'วีโต้';

  @override
  String get playNow => 'เล่นเลย';

  @override
  String get playNext => 'เล่นถัดไป';

  @override
  String get unpin => 'เลิกปักหมุด';

  @override
  String get noGuestsYet => 'ยังไม่มีใครมา';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · โหวต ×$weight วีโต้ได้';
  }

  @override
  String get guestRole => 'แขก';

  @override
  String get removeCoDj => 'เลิกเป็น co-DJ';

  @override
  String get promoteCoDj => 'ตั้งเป็น co-DJ';

  @override
  String get blockGuest => 'บล็อก';

  @override
  String get searchSoundCloudHint => 'ค้นหาใน SoundCloud…';

  @override
  String trackAdded(String title) {
    return 'เพิ่ม “$title” แล้ว';
  }

  @override
  String get playlistSearchHint => 'ศิลปิน หรือ ศิลปิน - เพลง...';

  @override
  String get playlistIdle => 'พิมพ์ชื่อวงหรือเพลง';

  @override
  String searchingFor(String query) {
    return 'กำลังค้นหา “$query”…';
  }

  @override
  String get similarByBpm => 'คล้ายกัน (เรียงตาม BPM)';

  @override
  String errorWithMessage(String message) {
    return 'ข้อผิดพลาด: $message';
  }

  @override
  String get toastNoNextTrack => 'ไม่พบแทร็กถัดไป – เพิ่มเพลงลงคิวหน่อย';

  @override
  String get toastPickingNext => 'กำลังเลือกแทร็กถัดไป…';

  @override
  String toastCannotPlay(String title) {
    return 'เล่น “$title” ไม่ได้ – ข้าม';
  }

  @override
  String relayUnavailable(String error) {
    return 'ใช้รีเลย์ไม่ได้: $error';
  }
}
