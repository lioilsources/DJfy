// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · ക്യൂ: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'പാർട്ടി $code';
  }

  @override
  String get addDeck => 'ഡെക്ക് ചേർക്കുക';

  @override
  String get deckDropHint => 'ട്രാക്ക് ഇവിടേക്ക് വലിച്ചിടുക';

  @override
  String get deckWaitingForQueue => 'ക്യൂവിനായി കാത്തിരിക്കുന്നു';

  @override
  String get dspUnavailable => 'DSP ലഭ്യമല്ല (HLS സ്ട്രീം)';

  @override
  String get bpmUnknown => 'BPM അജ്ഞാതം';

  @override
  String get genericError => 'പിശക്';

  @override
  String get partyTagline => 'നിങ്ങളുടെ ഫോൺ ആണ് DJ. സ്പീക്കർ വെറും സ്പീക്കർ.';

  @override
  String get partyIntro =>
      'അതിഥികൾ QR സ്കാൻ ചെയ്ത് ബ്രൗസറിൽ തിരയുകയും വോട്ട് ചെയ്യുകയും ചെയ്യുന്നു – ആപ്പോ അക്കൗണ്ടോ വേണ്ട. ക്യൂ നിങ്ങളുടെ കൈയിൽ, ശബ്ദം AirPlay അല്ലെങ്കിൽ Bluetooth വഴി അയയ്ക്കുക.';

  @override
  String get partyNameLabel => 'പാർട്ടിയുടെ പേര്';

  @override
  String get startParty => 'പാർട്ടി തുടങ്ങുക';

  @override
  String get back => 'തിരികെ';

  @override
  String get qrForGuests => 'അതിഥികൾക്കുള്ള QR';

  @override
  String get endParty => 'പാർട്ടി അവസാനിപ്പിക്കുക';

  @override
  String get endPartyQuestion => 'പാർട്ടി അവസാനിപ്പിക്കണോ?';

  @override
  String get endPartyWarning =>
      'അതിഥികളുടെ കണക്ഷൻ വിച്ഛേദിക്കപ്പെടും, ക്യൂ മായ്‌ക്കപ്പെടും.';

  @override
  String get no => 'ഇല്ല';

  @override
  String get endAction => 'അവസാനിപ്പിക്കുക';

  @override
  String get tabQueue => 'ക്യൂ';

  @override
  String get tabGuests => 'അതിഥികൾ';

  @override
  String get tabSearch => 'തിരയുക';

  @override
  String get copyLink => 'ലിങ്ക് പകർത്തുക';

  @override
  String get queueEmpty => 'ക്യൂ ശൂന്യമാണ്';

  @override
  String get readyPressPlay => 'തയ്യാർ – ▶ അമർത്തുക';

  @override
  String addedBy(String name) {
    return '$name ചേർത്തത്';
  }

  @override
  String get keepGoing => 'നോൺ-സ്റ്റോപ്പ്';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'പരിധിക്ക് പുറത്തുള്ള ട്രാക്കുകൾ ക്യൂവിൽ തുടരും, പക്ഷേ സ്വയം പ്ലേ ആകില്ല.';

  @override
  String get turnOff => 'ഓഫാക്കുക';

  @override
  String get lockAction => 'ലോക്ക് ചെയ്യുക';

  @override
  String get queueEmptyHint =>
      'ഇതുവരെ ഒന്നുമില്ല. ഒരു ട്രാക്ക് ചേർക്കുക അല്ലെങ്കിൽ അതിഥികൾക്ക് QR കാണിക്കുക.';

  @override
  String get vetoBadge => 'വീറ്റോ';

  @override
  String get vetoMenu => 'വീറ്റോ';

  @override
  String get playNow => 'ഇപ്പോൾ പ്ലേ ചെയ്യുക';

  @override
  String get playNext => 'അടുത്തതായി പ്ലേ ചെയ്യുക';

  @override
  String get unpin => 'പിൻ നീക്കുക';

  @override
  String get noGuestsYet => 'ഇതുവരെ ആരും എത്തിയിട്ടില്ല';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · വോട്ട് ×$weight, വീറ്റോ ചെയ്യാം';
  }

  @override
  String get guestRole => 'അതിഥി';

  @override
  String get removeCoDj => 'co-DJ നീക്കുക';

  @override
  String get promoteCoDj => 'co-DJ ആക്കുക';

  @override
  String get blockGuest => 'ബ്ലോക്ക് ചെയ്യുക';

  @override
  String get searchSoundCloudHint => 'SoundCloud-ൽ തിരയുക…';

  @override
  String trackAdded(String title) {
    return '“$title” ചേർത്തു';
  }

  @override
  String get playlistSearchHint => 'കലാകാരൻ അല്ലെങ്കിൽ കലാകാരൻ - പാട്ട്...';

  @override
  String get playlistIdle => 'ഒരു ബാൻഡോ പാട്ടോ നൽകുക';

  @override
  String searchingFor(String query) {
    return '“$query” തിരയുന്നു…';
  }

  @override
  String get similarByBpm => 'സമാനമായവ (BPM പ്രകാരം)';

  @override
  String errorWithMessage(String message) {
    return 'പിശക്: $message';
  }

  @override
  String get toastNoNextTrack =>
      'അടുത്ത ട്രാക്ക് കിട്ടിയില്ല – ക്യൂവിലേക്ക് എന്തെങ്കിലും ചേർക്കുക';

  @override
  String get toastPickingNext => 'അടുത്ത ട്രാക്ക് തിരഞ്ഞെടുക്കുന്നു…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” പ്ലേ ചെയ്യാനാകുന്നില്ല – ഒഴിവാക്കുന്നു';
  }

  @override
  String relayUnavailable(String error) {
    return 'റിലേ ലഭ്യമല്ല: $error';
  }
}
