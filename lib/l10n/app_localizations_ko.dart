// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · 대기열: $count';
  }

  @override
  String partyWithCode(String code) {
    return '파티 $code';
  }

  @override
  String get addDeck => '덱 추가';

  @override
  String get deckDropHint => '여기로 트랙을 끌어다 놓으세요';

  @override
  String get deckWaitingForQueue => '대기열 기다리는 중';

  @override
  String get dspUnavailable => 'DSP를 사용할 수 없음(HLS 스트림)';

  @override
  String get bpmUnknown => 'BPM 알 수 없음';

  @override
  String get genericError => '오류';

  @override
  String get partyTagline => '휴대폰이 DJ입니다. 스피커는 그냥 스피커일 뿐.';

  @override
  String get partyIntro =>
      '게스트는 QR 코드를 스캔해 브라우저에서 검색하고 투표합니다. 앱도 계정도 필요 없어요. 대기열은 내 휴대폰에 있고, 소리는 AirPlay나 Bluetooth로 보냅니다.';

  @override
  String get partyNameLabel => '파티 이름';

  @override
  String get startParty => '파티 시작';

  @override
  String get back => '뒤로';

  @override
  String get qrForGuests => '게스트용 QR';

  @override
  String get endParty => '파티 종료';

  @override
  String get endPartyQuestion => '파티를 종료할까요?';

  @override
  String get endPartyWarning => '게스트 연결이 끊기고 대기열이 삭제됩니다.';

  @override
  String get no => '아니요';

  @override
  String get endAction => '종료';

  @override
  String get tabQueue => '대기열';

  @override
  String get tabGuests => '게스트';

  @override
  String get tabSearch => '검색';

  @override
  String get copyLink => '링크 복사';

  @override
  String get queueEmpty => '대기열이 비어 있습니다';

  @override
  String get readyPressPlay => '준비 완료 – ▶를 누르세요';

  @override
  String addedBy(String name) {
    return '$name 님이 추가';
  }

  @override
  String get keepGoing => '논스톱';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint => '범위를 벗어난 트랙은 대기열에 남지만 자동으로 재생되지 않습니다.';

  @override
  String get turnOff => '끄기';

  @override
  String get lockAction => '고정';

  @override
  String get queueEmptyHint => '아직 아무것도 없어요. 트랙을 추가하거나 게스트에게 QR을 보여 주세요.';

  @override
  String get vetoBadge => '거부';

  @override
  String get vetoMenu => '거부';

  @override
  String get playNow => '지금 재생';

  @override
  String get playNext => '다음에 재생';

  @override
  String get unpin => '고정 해제';

  @override
  String get noGuestsYet => '아직 아무도 오지 않았습니다';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · 투표 ×$weight, 거부권 있음';
  }

  @override
  String get guestRole => '게스트';

  @override
  String get removeCoDj => 'co-DJ 해제';

  @override
  String get promoteCoDj => 'co-DJ로 지정';

  @override
  String get blockGuest => '차단';

  @override
  String get searchSoundCloudHint => 'SoundCloud에서 검색…';

  @override
  String trackAdded(String title) {
    return '\'$title\' 추가됨';
  }

  @override
  String get playlistSearchHint => '아티스트 또는 아티스트 - 곡...';

  @override
  String get playlistIdle => '밴드나 곡을 입력하세요';

  @override
  String searchingFor(String query) {
    return '\'$query\' 검색 중…';
  }

  @override
  String get similarByBpm => '비슷한 곡 (BPM순)';

  @override
  String errorWithMessage(String message) {
    return '오류: $message';
  }

  @override
  String get toastNoNextTrack => '다음 트랙을 찾지 못했어요 – 대기열에 추가해 주세요';

  @override
  String get toastPickingNext => '다음 트랙을 고르는 중…';

  @override
  String toastCannotPlay(String title) {
    return '\'$title\'을(를) 재생할 수 없어 건너뜁니다';
  }

  @override
  String relayUnavailable(String error) {
    return '릴레이에 연결할 수 없음: $error';
  }
}
