// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · ਕਤਾਰ: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'ਪਾਰਟੀ $code';
  }

  @override
  String get addDeck => 'ਡੈੱਕ ਜੋੜੋ';

  @override
  String get deckDropHint => 'ਟਰੈਕ ਇੱਥੇ ਖਿੱਚੋ';

  @override
  String get deckWaitingForQueue => 'ਕਤਾਰ ਦੀ ਉਡੀਕ';

  @override
  String get dspUnavailable => 'DSP ਉਪਲਬਧ ਨਹੀਂ (HLS ਸਟ੍ਰੀਮ)';

  @override
  String get bpmUnknown => 'BPM ਅਣਜਾਣ';

  @override
  String get genericError => 'ਗਲਤੀ';

  @override
  String get partyTagline => 'ਤੁਹਾਡਾ ਫ਼ੋਨ DJ ਹੈ। ਸਪੀਕਰ ਬੱਸ ਸਪੀਕਰ ਹੈ।';

  @override
  String get partyIntro =>
      'ਮਹਿਮਾਨ QR ਸਕੈਨ ਕਰਦੇ ਹਨ, ਬ੍ਰਾਊਜ਼ਰ ਵਿੱਚ ਖੋਜਦੇ ਅਤੇ ਵੋਟ ਪਾਉਂਦੇ ਹਨ – ਬਿਨਾਂ ਐਪ ਅਤੇ ਬਿਨਾਂ ਖਾਤੇ ਦੇ। ਕਤਾਰ ਤੁਹਾਡੇ ਕੋਲ ਰਹਿੰਦੀ ਹੈ, ਆਵਾਜ਼ AirPlay ਜਾਂ Bluetooth ਰਾਹੀਂ ਭੇਜੋ।';

  @override
  String get partyNameLabel => 'ਪਾਰਟੀ ਦਾ ਨਾਮ';

  @override
  String get startParty => 'ਪਾਰਟੀ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get back => 'ਵਾਪਸ';

  @override
  String get qrForGuests => 'ਮਹਿਮਾਨਾਂ ਲਈ QR';

  @override
  String get endParty => 'ਪਾਰਟੀ ਖਤਮ ਕਰੋ';

  @override
  String get endPartyQuestion => 'ਪਾਰਟੀ ਖਤਮ ਕਰਨੀ ਹੈ?';

  @override
  String get endPartyWarning =>
      'ਮਹਿਮਾਨਾਂ ਦਾ ਕਨੈਕਸ਼ਨ ਟੁੱਟ ਜਾਵੇਗਾ ਅਤੇ ਕਤਾਰ ਮਿਟ ਜਾਵੇਗੀ।';

  @override
  String get no => 'ਨਹੀਂ';

  @override
  String get endAction => 'ਖਤਮ ਕਰੋ';

  @override
  String get tabQueue => 'ਕਤਾਰ';

  @override
  String get tabGuests => 'ਮਹਿਮਾਨ';

  @override
  String get tabSearch => 'ਖੋਜੋ';

  @override
  String get copyLink => 'ਲਿੰਕ ਕਾਪੀ ਕਰੋ';

  @override
  String get queueEmpty => 'ਕਤਾਰ ਖਾਲੀ ਹੈ';

  @override
  String get readyPressPlay => 'ਤਿਆਰ – ▶ ਦਬਾਓ';

  @override
  String addedBy(String name) {
    return '$name ਨੇ ਜੋੜਿਆ';
  }

  @override
  String get keepGoing => 'ਨਾਨ-ਸਟਾਪ';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'ਰੇਂਜ ਤੋਂ ਬਾਹਰਲੇ ਟਰੈਕ ਕਤਾਰ ਵਿੱਚ ਰਹਿਣਗੇ, ਪਰ ਆਪਣੇ-ਆਪ ਨਹੀਂ ਵੱਜਣਗੇ।';

  @override
  String get turnOff => 'ਬੰਦ ਕਰੋ';

  @override
  String get lockAction => 'ਲਾਕ ਕਰੋ';

  @override
  String get queueEmptyHint =>
      'ਹਾਲੇ ਕੁਝ ਨਹੀਂ। ਕੋਈ ਟਰੈਕ ਜੋੜੋ ਜਾਂ ਮਹਿਮਾਨਾਂ ਨੂੰ QR ਦਿਖਾਓ।';

  @override
  String get vetoBadge => 'ਵੀਟੋ';

  @override
  String get vetoMenu => 'ਵੀਟੋ';

  @override
  String get playNow => 'ਹੁਣੇ ਚਲਾਓ';

  @override
  String get playNext => 'ਅਗਲਾ ਚਲਾਓ';

  @override
  String get unpin => 'ਪਿੰਨ ਹਟਾਓ';

  @override
  String get noGuestsYet => 'ਹਾਲੇ ਕੋਈ ਨਹੀਂ ਆਇਆ';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ਵੋਟ ×$weight, ਵੀਟੋ ਕਰ ਸਕਦੇ ਹਨ';
  }

  @override
  String get guestRole => 'ਮਹਿਮਾਨ';

  @override
  String get removeCoDj => 'co-DJ ਹਟਾਓ';

  @override
  String get promoteCoDj => 'co-DJ ਬਣਾਓ';

  @override
  String get blockGuest => 'ਬਲੌਕ ਕਰੋ';

  @override
  String get searchSoundCloudHint => 'SoundCloud \'ਤੇ ਖੋਜੋ…';

  @override
  String trackAdded(String title) {
    return '“$title” ਜੋੜਿਆ ਗਿਆ';
  }

  @override
  String get playlistSearchHint => 'ਕਲਾਕਾਰ ਜਾਂ ਕਲਾਕਾਰ - ਗੀਤ...';

  @override
  String get playlistIdle => 'ਕੋਈ ਬੈਂਡ ਜਾਂ ਗੀਤ ਲਿਖੋ';

  @override
  String searchingFor(String query) {
    return '“$query” ਖੋਜ ਰਹੇ ਹਾਂ…';
  }

  @override
  String get similarByBpm => 'ਮਿਲਦੇ-ਜੁਲਦੇ (BPM ਮੁਤਾਬਕ)';

  @override
  String errorWithMessage(String message) {
    return 'ਗਲਤੀ: $message';
  }

  @override
  String get toastNoNextTrack => 'ਅਗਲਾ ਟਰੈਕ ਨਹੀਂ ਮਿਲਿਆ – ਕਤਾਰ ਵਿੱਚ ਕੁਝ ਜੋੜੋ';

  @override
  String get toastPickingNext => 'ਅਗਲਾ ਟਰੈਕ ਚੁਣ ਰਹੇ ਹਾਂ…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” ਨਹੀਂ ਚੱਲ ਸਕਦਾ – ਛੱਡ ਰਹੇ ਹਾਂ';
  }

  @override
  String relayUnavailable(String error) {
    return 'ਰਿਲੇ ਉਪਲਬਧ ਨਹੀਂ: $error';
  }
}
