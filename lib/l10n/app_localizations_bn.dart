// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · সারি: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'পার্টি $code';
  }

  @override
  String get addDeck => 'ডেক যোগ করুন';

  @override
  String get deckDropHint => 'ট্র্যাক এখানে টেনে আনুন';

  @override
  String get deckWaitingForQueue => 'সারির অপেক্ষায়';

  @override
  String get dspUnavailable => 'DSP উপলব্ধ নয় (HLS স্ট্রিম)';

  @override
  String get bpmUnknown => 'BPM অজানা';

  @override
  String get genericError => 'ত্রুটি';

  @override
  String get partyTagline => 'আপনার ফোনই DJ। স্পিকার শুধু স্পিকার।';

  @override
  String get partyIntro =>
      'অতিথিরা QR স্ক্যান করে ব্রাউজারে খোঁজেন ও ভোট দেন – অ্যাপ বা অ্যাকাউন্ট ছাড়াই। সারি থাকে আপনার কাছে, শব্দ পাঠান AirPlay বা Bluetooth দিয়ে।';

  @override
  String get partyNameLabel => 'পার্টির নাম';

  @override
  String get startParty => 'পার্টি শুরু করুন';

  @override
  String get back => 'ফিরে যান';

  @override
  String get qrForGuests => 'অতিথিদের জন্য QR';

  @override
  String get endParty => 'পার্টি শেষ করুন';

  @override
  String get endPartyQuestion => 'পার্টি শেষ করবেন?';

  @override
  String get endPartyWarning =>
      'অতিথিদের সংযোগ বিচ্ছিন্ন হবে এবং সারি মুছে যাবে।';

  @override
  String get no => 'না';

  @override
  String get endAction => 'শেষ করুন';

  @override
  String get tabQueue => 'সারি';

  @override
  String get tabGuests => 'অতিথি';

  @override
  String get tabSearch => 'খুঁজুন';

  @override
  String get copyLink => 'লিংক কপি করুন';

  @override
  String get queueEmpty => 'সারি খালি';

  @override
  String get readyPressPlay => 'প্রস্তুত – ▶ চাপুন';

  @override
  String addedBy(String name) {
    return '$name যোগ করেছেন';
  }

  @override
  String get keepGoing => 'নন-স্টপ';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'সীমার বাইরের ট্র্যাক সারিতে থাকবে, কিন্তু নিজে থেকে বাজবে না।';

  @override
  String get turnOff => 'বন্ধ করুন';

  @override
  String get lockAction => 'লক করুন';

  @override
  String get queueEmptyHint =>
      'এখনও কিছু নেই। একটি ট্র্যাক যোগ করুন বা অতিথিদের QR দেখান।';

  @override
  String get vetoBadge => 'ভেটো';

  @override
  String get vetoMenu => 'ভেটো';

  @override
  String get playNow => 'এখনই চালান';

  @override
  String get playNext => 'পরেরটা চালান';

  @override
  String get unpin => 'পিন সরান';

  @override
  String get noGuestsYet => 'এখনও কেউ আসেননি';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ভোট ×$weight, ভেটো দিতে পারেন';
  }

  @override
  String get guestRole => 'অতিথি';

  @override
  String get removeCoDj => 'co-DJ সরান';

  @override
  String get promoteCoDj => 'co-DJ করুন';

  @override
  String get blockGuest => 'ব্লক করুন';

  @override
  String get searchSoundCloudHint => 'SoundCloud-এ খুঁজুন…';

  @override
  String trackAdded(String title) {
    return '“$title” যোগ হয়েছে';
  }

  @override
  String get playlistSearchHint => 'শিল্পী বা শিল্পী - গান...';

  @override
  String get playlistIdle => 'একটি ব্যান্ড বা গান লিখুন';

  @override
  String searchingFor(String query) {
    return '“$query” খোঁজা হচ্ছে…';
  }

  @override
  String get similarByBpm => 'একই রকম (BPM অনুযায়ী)';

  @override
  String errorWithMessage(String message) {
    return 'ত্রুটি: $message';
  }

  @override
  String get toastNoNextTrack =>
      'পরের ট্র্যাক পাওয়া যায়নি – সারিতে কিছু যোগ করুন';

  @override
  String get toastPickingNext => 'পরের ট্র্যাক বাছাই হচ্ছে…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” চালানো যাচ্ছে না – এড়িয়ে যাচ্ছি';
  }

  @override
  String relayUnavailable(String error) {
    return 'রিলে উপলব্ধ নয়: $error';
  }
}
