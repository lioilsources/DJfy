// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · 队列：$count';
  }

  @override
  String partyWithCode(String code) {
    return '派对 $code';
  }

  @override
  String get addDeck => '添加唱盘';

  @override
  String get deckDropHint => '把曲目拖到这里';

  @override
  String get deckWaitingForQueue => '等待队列';

  @override
  String get dspUnavailable => 'DSP 不可用（HLS 流）';

  @override
  String get bpmUnknown => 'BPM 未知';

  @override
  String get genericError => '错误';

  @override
  String get partyTagline => '你的手机就是 DJ。音箱只是音箱。';

  @override
  String get partyIntro =>
      '来宾扫描二维码，在浏览器里搜索和投票——无需应用，无需账号。队列保存在你这里，声音通过 AirPlay 或蓝牙发送。';

  @override
  String get partyNameLabel => '派对名称';

  @override
  String get startParty => '开始派对';

  @override
  String get back => '返回';

  @override
  String get qrForGuests => '来宾二维码';

  @override
  String get endParty => '结束派对';

  @override
  String get endPartyQuestion => '要结束派对吗？';

  @override
  String get endPartyWarning => '来宾将断开连接，队列将被清空。';

  @override
  String get no => '否';

  @override
  String get endAction => '结束';

  @override
  String get tabQueue => '队列';

  @override
  String get tabGuests => '来宾';

  @override
  String get tabSearch => '搜索';

  @override
  String get copyLink => '复制链接';

  @override
  String get queueEmpty => '队列为空';

  @override
  String get readyPressPlay => '已就绪——按 ▶';

  @override
  String addedBy(String name) {
    return '$name 添加';
  }

  @override
  String get keepGoing => '不停歇';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint => '超出范围的曲目会留在队列中，但不会自动播放。';

  @override
  String get turnOff => '关闭';

  @override
  String get lockAction => '锁定';

  @override
  String get queueEmptyHint => '还没有内容。添加一首曲目，或给来宾看二维码。';

  @override
  String get vetoBadge => '否决';

  @override
  String get vetoMenu => '否决';

  @override
  String get playNow => '立即播放';

  @override
  String get playNext => '下一首播放';

  @override
  String get unpin => '取消置顶';

  @override
  String get noGuestsYet => '还没有人到场';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · 票数 ×$weight，可以否决';
  }

  @override
  String get guestRole => '来宾';

  @override
  String get removeCoDj => '取消 co-DJ';

  @override
  String get promoteCoDj => '设为 co-DJ';

  @override
  String get blockGuest => '屏蔽';

  @override
  String get searchSoundCloudHint => '在 SoundCloud 上搜索…';

  @override
  String trackAdded(String title) {
    return '已添加“$title”';
  }

  @override
  String get playlistSearchHint => '艺人 或 艺人 - 歌曲...';

  @override
  String get playlistIdle => '输入乐队或歌曲';

  @override
  String searchingFor(String query) {
    return '正在搜索“$query”…';
  }

  @override
  String get similarByBpm => '相似曲目（按 BPM 排序）';

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }

  @override
  String get toastNoNextTrack => '找不到下一首曲目——请往队列里加一首';

  @override
  String get toastPickingNext => '正在挑选下一首曲目…';

  @override
  String toastCannotPlay(String title) {
    return '无法播放“$title”——跳过';
  }

  @override
  String relayUnavailable(String error) {
    return '中继不可用：$error';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String partyBarStatus(String title, int count) {
    return '$title · 队列：$count';
  }

  @override
  String partyWithCode(String code) {
    return '派对 $code';
  }

  @override
  String get addDeck => '添加唱盘';

  @override
  String get deckDropHint => '把曲目拖到这里';

  @override
  String get deckWaitingForQueue => '等待队列';

  @override
  String get dspUnavailable => 'DSP 不可用（HLS 流）';

  @override
  String get bpmUnknown => 'BPM 未知';

  @override
  String get genericError => '错误';

  @override
  String get partyTagline => '你的手机就是 DJ。音箱只是音箱。';

  @override
  String get partyIntro =>
      '来宾扫描二维码，在浏览器里搜索和投票——无需应用，无需账号。队列保存在你这里，声音通过 AirPlay 或蓝牙发送。';

  @override
  String get partyNameLabel => '派对名称';

  @override
  String get startParty => '开始派对';

  @override
  String get back => '返回';

  @override
  String get qrForGuests => '来宾二维码';

  @override
  String get endParty => '结束派对';

  @override
  String get endPartyQuestion => '要结束派对吗？';

  @override
  String get endPartyWarning => '来宾将断开连接，队列将被清空。';

  @override
  String get no => '否';

  @override
  String get endAction => '结束';

  @override
  String get tabQueue => '队列';

  @override
  String get tabGuests => '来宾';

  @override
  String get tabSearch => '搜索';

  @override
  String get copyLink => '复制链接';

  @override
  String get queueEmpty => '队列为空';

  @override
  String get readyPressPlay => '已就绪——按 ▶';

  @override
  String addedBy(String name) {
    return '$name 添加';
  }

  @override
  String get keepGoing => '不停歇';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint => '超出范围的曲目会留在队列中，但不会自动播放。';

  @override
  String get turnOff => '关闭';

  @override
  String get lockAction => '锁定';

  @override
  String get queueEmptyHint => '还没有内容。添加一首曲目，或给来宾看二维码。';

  @override
  String get vetoBadge => '否决';

  @override
  String get vetoMenu => '否决';

  @override
  String get playNow => '立即播放';

  @override
  String get playNext => '下一首播放';

  @override
  String get unpin => '取消置顶';

  @override
  String get noGuestsYet => '还没有人到场';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · 票数 ×$weight，可以否决';
  }

  @override
  String get guestRole => '来宾';

  @override
  String get removeCoDj => '取消 co-DJ';

  @override
  String get promoteCoDj => '设为 co-DJ';

  @override
  String get blockGuest => '屏蔽';

  @override
  String get searchSoundCloudHint => '在 SoundCloud 上搜索…';

  @override
  String trackAdded(String title) {
    return '已添加“$title”';
  }

  @override
  String get playlistSearchHint => '艺人 或 艺人 - 歌曲...';

  @override
  String get playlistIdle => '输入乐队或歌曲';

  @override
  String searchingFor(String query) {
    return '正在搜索“$query”…';
  }

  @override
  String get similarByBpm => '相似曲目（按 BPM 排序）';

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }

  @override
  String get toastNoNextTrack => '找不到下一首曲目——请往队列里加一首';

  @override
  String get toastPickingNext => '正在挑选下一首曲目…';

  @override
  String toastCannotPlay(String title) {
    return '无法播放“$title”——跳过';
  }

  @override
  String relayUnavailable(String error) {
    return '中继不可用：$error';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String partyBarStatus(String title, int count) {
    return '$title · 佇列：$count';
  }

  @override
  String partyWithCode(String code) {
    return '派對 $code';
  }

  @override
  String get addDeck => '新增唱盤';

  @override
  String get deckDropHint => '將曲目拖曳到這裡';

  @override
  String get deckWaitingForQueue => '等待佇列';

  @override
  String get dspUnavailable => 'DSP 無法使用（HLS 串流）';

  @override
  String get bpmUnknown => 'BPM 未知';

  @override
  String get genericError => '錯誤';

  @override
  String get partyTagline => '你的手機就是 DJ。喇叭只是喇叭。';

  @override
  String get partyIntro =>
      '來賓掃描 QR 碼，在瀏覽器中搜尋並投票——不用 App，也不用帳號。佇列留在你這裡，聲音透過 AirPlay 或藍牙傳送。';

  @override
  String get partyNameLabel => '派對名稱';

  @override
  String get startParty => '開始派對';

  @override
  String get back => '返回';

  @override
  String get qrForGuests => '來賓 QR 碼';

  @override
  String get endParty => '結束派對';

  @override
  String get endPartyQuestion => '要結束派對嗎？';

  @override
  String get endPartyWarning => '來賓將中斷連線，佇列也會清除。';

  @override
  String get no => '否';

  @override
  String get endAction => '結束';

  @override
  String get tabQueue => '佇列';

  @override
  String get tabGuests => '來賓';

  @override
  String get tabSearch => '搜尋';

  @override
  String get copyLink => '複製連結';

  @override
  String get queueEmpty => '佇列是空的';

  @override
  String get readyPressPlay => '準備好了——按 ▶';

  @override
  String addedBy(String name) {
    return '$name 新增';
  }

  @override
  String get keepGoing => '不停歇';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint => '超出範圍的曲目會留在佇列中，但不會自動播放。';

  @override
  String get turnOff => '關閉';

  @override
  String get lockAction => '鎖定';

  @override
  String get queueEmptyHint => '還沒有內容。新增一首曲目，或讓來賓看 QR 碼。';

  @override
  String get vetoBadge => '否決';

  @override
  String get vetoMenu => '否決';

  @override
  String get playNow => '立即播放';

  @override
  String get playNext => '下一首播放';

  @override
  String get unpin => '取消釘選';

  @override
  String get noGuestsYet => '還沒有人到場';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · 票數 ×$weight，可以否決';
  }

  @override
  String get guestRole => '來賓';

  @override
  String get removeCoDj => '取消 co-DJ';

  @override
  String get promoteCoDj => '設為 co-DJ';

  @override
  String get blockGuest => '封鎖';

  @override
  String get searchSoundCloudHint => '在 SoundCloud 上搜尋…';

  @override
  String trackAdded(String title) {
    return '已新增「$title」';
  }

  @override
  String get playlistSearchHint => '藝人 或 藝人 - 歌曲...';

  @override
  String get playlistIdle => '輸入樂團或歌曲';

  @override
  String searchingFor(String query) {
    return '正在搜尋「$query」…';
  }

  @override
  String get similarByBpm => '相似曲目（依 BPM 排序）';

  @override
  String errorWithMessage(String message) {
    return '錯誤：$message';
  }

  @override
  String get toastNoNextTrack => '找不到下一首曲目——請在佇列中新增一首';

  @override
  String get toastPickingNext => '正在挑選下一首曲目…';

  @override
  String toastCannotPlay(String title) {
    return '無法播放「$title」——略過';
  }

  @override
  String relayUnavailable(String error) {
    return '中繼無法使用：$error';
  }
}
