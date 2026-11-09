// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · hàng chờ: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Tiệc $code';
  }

  @override
  String get addDeck => 'THÊM DECK';

  @override
  String get deckDropHint => 'Kéo bản nhạc vào đây';

  @override
  String get deckWaitingForQueue => 'Đang chờ hàng chờ';

  @override
  String get dspUnavailable => 'Không có DSP (luồng HLS)';

  @override
  String get bpmUnknown => 'Không rõ BPM';

  @override
  String get genericError => 'Lỗi';

  @override
  String get partyTagline => 'Điện thoại của bạn là DJ. Loa chỉ là loa.';

  @override
  String get partyIntro =>
      'Khách quét mã QR, tìm kiếm và bình chọn trên trình duyệt – không cần ứng dụng, không cần tài khoản. Hàng chờ nằm ở chỗ bạn, âm thanh gửi qua AirPlay hoặc Bluetooth.';

  @override
  String get partyNameLabel => 'Tên bữa tiệc';

  @override
  String get startParty => 'BẮT ĐẦU TIỆC';

  @override
  String get back => 'QUAY LẠI';

  @override
  String get qrForGuests => 'QR cho khách';

  @override
  String get endParty => 'Kết thúc tiệc';

  @override
  String get endPartyQuestion => 'Kết thúc bữa tiệc?';

  @override
  String get endPartyWarning =>
      'Khách sẽ bị ngắt kết nối và hàng chờ sẽ bị xóa.';

  @override
  String get no => 'KHÔNG';

  @override
  String get endAction => 'KẾT THÚC';

  @override
  String get tabQueue => 'HÀNG CHỜ';

  @override
  String get tabGuests => 'KHÁCH';

  @override
  String get tabSearch => 'TÌM';

  @override
  String get copyLink => 'SAO CHÉP LIÊN KẾT';

  @override
  String get queueEmpty => 'Hàng chờ trống';

  @override
  String get readyPressPlay => 'Sẵn sàng – nhấn ▶';

  @override
  String addedBy(String name) {
    return '$name đã thêm';
  }

  @override
  String get keepGoing => 'KHÔNG NGỪNG';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Các bản ngoài khoảng vẫn ở trong hàng chờ nhưng sẽ không tự phát.';

  @override
  String get turnOff => 'TẮT';

  @override
  String get lockAction => 'KHÓA';

  @override
  String get queueEmptyHint =>
      'Chưa có gì. Thêm một bản nhạc hoặc cho khách xem mã QR.';

  @override
  String get vetoBadge => 'PHỦ QUYẾT';

  @override
  String get vetoMenu => 'Phủ quyết';

  @override
  String get playNow => 'Phát ngay';

  @override
  String get playNext => 'Phát tiếp theo';

  @override
  String get unpin => 'Bỏ ghim';

  @override
  String get noGuestsYet => 'Chưa có ai đến';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · phiếu ×$weight, có quyền phủ quyết';
  }

  @override
  String get guestRole => 'khách';

  @override
  String get removeCoDj => 'Bỏ co-DJ';

  @override
  String get promoteCoDj => 'Nâng lên co-DJ';

  @override
  String get blockGuest => 'Chặn';

  @override
  String get searchSoundCloudHint => 'Tìm trên SoundCloud…';

  @override
  String trackAdded(String title) {
    return 'Đã thêm “$title”';
  }

  @override
  String get playlistSearchHint => 'Nghệ sĩ hoặc Nghệ sĩ - Bài hát...';

  @override
  String get playlistIdle => 'Nhập tên ban nhạc hoặc bài hát';

  @override
  String searchingFor(String query) {
    return 'Đang tìm “$query”…';
  }

  @override
  String get similarByBpm => 'Tương tự (theo BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Lỗi: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Không tìm thấy bản tiếp theo – hãy thêm một bản vào hàng chờ';

  @override
  String get toastPickingNext => 'Đang chọn bản tiếp theo…';

  @override
  String toastCannotPlay(String title) {
    return 'Không phát được “$title” – bỏ qua';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay không khả dụng: $error';
  }
}
