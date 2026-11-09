// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · キュー: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'パーティー $code';
  }

  @override
  String get addDeck => 'デッキを追加';

  @override
  String get deckDropHint => 'ここにトラックをドラッグ';

  @override
  String get deckWaitingForQueue => 'キュー待ち';

  @override
  String get dspUnavailable => 'DSP は使用できません（HLS ストリーム）';

  @override
  String get bpmUnknown => 'BPM 不明';

  @override
  String get genericError => 'エラー';

  @override
  String get partyTagline => 'スマホが DJ。スピーカーはただのスピーカー。';

  @override
  String get partyIntro =>
      'ゲストは QR コードを読み取り、ブラウザで検索・投票します。アプリもアカウントも不要。キューはあなたのスマホにあり、音は AirPlay か Bluetooth で送ります。';

  @override
  String get partyNameLabel => 'パーティー名';

  @override
  String get startParty => 'パーティーを始める';

  @override
  String get back => '戻る';

  @override
  String get qrForGuests => 'ゲスト用 QR';

  @override
  String get endParty => 'パーティーを終了';

  @override
  String get endPartyQuestion => 'パーティーを終了しますか？';

  @override
  String get endPartyWarning => 'ゲストの接続が切れ、キューは削除されます。';

  @override
  String get no => 'いいえ';

  @override
  String get endAction => '終了';

  @override
  String get tabQueue => 'キュー';

  @override
  String get tabGuests => 'ゲスト';

  @override
  String get tabSearch => '検索';

  @override
  String get copyLink => 'リンクをコピー';

  @override
  String get queueEmpty => 'キューは空です';

  @override
  String get readyPressPlay => '準備完了 – ▶ をタップ';

  @override
  String addedBy(String name) {
    return '$name さんが追加';
  }

  @override
  String get keepGoing => 'ノンストップ';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint => '範囲外のトラックはキューに残りますが、自動では再生されません。';

  @override
  String get turnOff => 'オフにする';

  @override
  String get lockAction => 'ロック';

  @override
  String get queueEmptyHint => 'まだ何もありません。トラックを追加するか、ゲストに QR を見せましょう。';

  @override
  String get vetoBadge => '拒否';

  @override
  String get vetoMenu => '拒否';

  @override
  String get playNow => '今すぐ再生';

  @override
  String get playNext => '次に再生';

  @override
  String get unpin => '固定を解除';

  @override
  String get noGuestsYet => 'まだ誰も来ていません';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · 投票 ×$weight、拒否権あり';
  }

  @override
  String get guestRole => 'ゲスト';

  @override
  String get removeCoDj => 'co-DJ を解除';

  @override
  String get promoteCoDj => 'co-DJ にする';

  @override
  String get blockGuest => 'ブロック';

  @override
  String get searchSoundCloudHint => 'SoundCloud で検索…';

  @override
  String trackAdded(String title) {
    return '「$title」を追加しました';
  }

  @override
  String get playlistSearchHint => 'アーティスト または アーティスト - 曲名...';

  @override
  String get playlistIdle => 'バンド名か曲名を入力';

  @override
  String searchingFor(String query) {
    return '「$query」を検索中…';
  }

  @override
  String get similarByBpm => '似た曲（BPM 順）';

  @override
  String errorWithMessage(String message) {
    return 'エラー: $message';
  }

  @override
  String get toastNoNextTrack => '次のトラックが見つかりません – キューに追加してください';

  @override
  String get toastPickingNext => '次のトラックを選んでいます…';

  @override
  String toastCannotPlay(String title) {
    return '「$title」を再生できません – スキップします';
  }

  @override
  String relayUnavailable(String error) {
    return 'リレーに接続できません: $error';
  }
}
