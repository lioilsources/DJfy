// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · ಸರತಿ: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'ಪಾರ್ಟಿ $code';
  }

  @override
  String get addDeck => 'ಡೆಕ್ ಸೇರಿಸಿ';

  @override
  String get deckDropHint => 'ಟ್ರ್ಯಾಕ್ ಅನ್ನು ಇಲ್ಲಿಗೆ ಎಳೆಯಿರಿ';

  @override
  String get deckWaitingForQueue => 'ಸರತಿಗಾಗಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get dspUnavailable => 'DSP ಲಭ್ಯವಿಲ್ಲ (HLS ಸ್ಟ್ರೀಮ್)';

  @override
  String get bpmUnknown => 'BPM ತಿಳಿದಿಲ್ಲ';

  @override
  String get genericError => 'ದೋಷ';

  @override
  String get partyTagline => 'ನಿಮ್ಮ ಫೋನ್ DJ. ಸ್ಪೀಕರ್ ಕೇವಲ ಸ್ಪೀಕರ್.';

  @override
  String get partyIntro =>
      'ಅತಿಥಿಗಳು QR ಸ್ಕ್ಯಾನ್ ಮಾಡಿ, ಬ್ರೌಸರ್‌ನಲ್ಲಿ ಹುಡುಕಿ ಮತ ಹಾಕುತ್ತಾರೆ – ಆ್ಯಪ್ ಮತ್ತು ಖಾತೆ ಇಲ್ಲದೆ. ಸರತಿ ನಿಮ್ಮ ಬಳಿಯೇ ಇರುತ್ತದೆ, ಧ್ವನಿಯನ್ನು AirPlay ಅಥವಾ Bluetooth ಮೂಲಕ ಕಳುಹಿಸಿ.';

  @override
  String get partyNameLabel => 'ಪಾರ್ಟಿಯ ಹೆಸರು';

  @override
  String get startParty => 'ಪಾರ್ಟಿ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get qrForGuests => 'ಅತಿಥಿಗಳಿಗೆ QR';

  @override
  String get endParty => 'ಪಾರ್ಟಿ ಮುಗಿಸಿ';

  @override
  String get endPartyQuestion => 'ಪಾರ್ಟಿ ಮುಗಿಸಬೇಕೆ?';

  @override
  String get endPartyWarning =>
      'ಅತಿಥಿಗಳ ಸಂಪರ್ಕ ಕಡಿತಗೊಳ್ಳುತ್ತದೆ ಮತ್ತು ಸರತಿ ಅಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get no => 'ಇಲ್ಲ';

  @override
  String get endAction => 'ಮುಗಿಸಿ';

  @override
  String get tabQueue => 'ಸರತಿ';

  @override
  String get tabGuests => 'ಅತಿಥಿಗಳು';

  @override
  String get tabSearch => 'ಹುಡುಕಿ';

  @override
  String get copyLink => 'ಲಿಂಕ್ ನಕಲಿಸಿ';

  @override
  String get queueEmpty => 'ಸರತಿ ಖಾಲಿಯಾಗಿದೆ';

  @override
  String get readyPressPlay => 'ಸಿದ್ಧ – ▶ ಒತ್ತಿ';

  @override
  String addedBy(String name) {
    return '$name ಸೇರಿಸಿದ್ದಾರೆ';
  }

  @override
  String get keepGoing => 'ನಾನ್-ಸ್ಟಾಪ್';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'ವ್ಯಾಪ್ತಿಯ ಹೊರಗಿನ ಟ್ರ್ಯಾಕ್‌ಗಳು ಸರತಿಯಲ್ಲಿ ಉಳಿಯುತ್ತವೆ, ಆದರೆ ತಾವಾಗಿಯೇ ಪ್ಲೇ ಆಗುವುದಿಲ್ಲ.';

  @override
  String get turnOff => 'ಆಫ್ ಮಾಡಿ';

  @override
  String get lockAction => 'ಲಾಕ್ ಮಾಡಿ';

  @override
  String get queueEmptyHint =>
      'ಇನ್ನೂ ಏನೂ ಇಲ್ಲ. ಟ್ರ್ಯಾಕ್ ಸೇರಿಸಿ ಅಥವಾ ಅತಿಥಿಗಳಿಗೆ QR ತೋರಿಸಿ.';

  @override
  String get vetoBadge => 'ವೀಟೋ';

  @override
  String get vetoMenu => 'ವೀಟೋ';

  @override
  String get playNow => 'ಈಗ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get playNext => 'ಮುಂದೆ ಪ್ಲೇ ಮಾಡಿ';

  @override
  String get unpin => 'ಪಿನ್ ತೆಗೆಯಿರಿ';

  @override
  String get noGuestsYet => 'ಇನ್ನೂ ಯಾರೂ ಬಂದಿಲ್ಲ';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ಮತ ×$weight, ವೀಟೋ ಮಾಡಬಹುದು';
  }

  @override
  String get guestRole => 'ಅತಿಥಿ';

  @override
  String get removeCoDj => 'co-DJ ತೆಗೆಯಿರಿ';

  @override
  String get promoteCoDj => 'co-DJ ಮಾಡಿ';

  @override
  String get blockGuest => 'ನಿರ್ಬಂಧಿಸಿ';

  @override
  String get searchSoundCloudHint => 'SoundCloud ನಲ್ಲಿ ಹುಡುಕಿ…';

  @override
  String trackAdded(String title) {
    return '“$title” ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String get playlistSearchHint => 'ಕಲಾವಿದ ಅಥವಾ ಕಲಾವಿದ - ಹಾಡು...';

  @override
  String get playlistIdle => 'ಬ್ಯಾಂಡ್ ಅಥವಾ ಹಾಡನ್ನು ಬರೆಯಿರಿ';

  @override
  String searchingFor(String query) {
    return '“$query” ಹುಡುಕಲಾಗುತ್ತಿದೆ…';
  }

  @override
  String get similarByBpm => 'ಇದೇ ರೀತಿಯವು (BPM ಪ್ರಕಾರ)';

  @override
  String errorWithMessage(String message) {
    return 'ದೋಷ: $message';
  }

  @override
  String get toastNoNextTrack =>
      'ಮುಂದಿನ ಟ್ರ್ಯಾಕ್ ಸಿಗಲಿಲ್ಲ – ಸರತಿಗೆ ಏನಾದರೂ ಸೇರಿಸಿ';

  @override
  String get toastPickingNext => 'ಮುಂದಿನ ಟ್ರ್ಯಾಕ್ ಆಯ್ಕೆ ಮಾಡಲಾಗುತ್ತಿದೆ…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” ಪ್ಲೇ ಆಗುತ್ತಿಲ್ಲ – ಬಿಟ್ಟುಬಿಡಲಾಗುತ್ತಿದೆ';
  }

  @override
  String relayUnavailable(String error) {
    return 'ರಿಲೇ ಲಭ್ಯವಿಲ್ಲ: $error';
  }
}
