// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · कतार: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'पार्टी $code';
  }

  @override
  String get addDeck => 'डेक जोड़ें';

  @override
  String get deckDropHint => 'ट्रैक यहाँ खींचें';

  @override
  String get deckWaitingForQueue => 'कतार का इंतज़ार';

  @override
  String get dspUnavailable => 'DSP उपलब्ध नहीं (HLS स्ट्रीम)';

  @override
  String get bpmUnknown => 'BPM अज्ञात';

  @override
  String get genericError => 'त्रुटि';

  @override
  String get partyTagline => 'आपका फ़ोन DJ है। स्पीकर बस स्पीकर है।';

  @override
  String get partyIntro =>
      'मेहमान QR स्कैन करते हैं, ब्राउज़र में खोजते और वोट करते हैं – बिना ऐप और बिना अकाउंट के। कतार आपके पास रहती है, आवाज़ AirPlay या Bluetooth से भेजें।';

  @override
  String get partyNameLabel => 'पार्टी का नाम';

  @override
  String get startParty => 'पार्टी शुरू करें';

  @override
  String get back => 'वापस';

  @override
  String get qrForGuests => 'मेहमानों के लिए QR';

  @override
  String get endParty => 'पार्टी खत्म करें';

  @override
  String get endPartyQuestion => 'पार्टी खत्म करें?';

  @override
  String get endPartyWarning =>
      'मेहमान डिस्कनेक्ट हो जाएँगे और कतार मिट जाएगी।';

  @override
  String get no => 'नहीं';

  @override
  String get endAction => 'खत्म करें';

  @override
  String get tabQueue => 'कतार';

  @override
  String get tabGuests => 'मेहमान';

  @override
  String get tabSearch => 'खोजें';

  @override
  String get copyLink => 'लिंक कॉपी करें';

  @override
  String get queueEmpty => 'कतार खाली है';

  @override
  String get readyPressPlay => 'तैयार – ▶ दबाएँ';

  @override
  String addedBy(String name) {
    return '$name ने जोड़ा';
  }

  @override
  String get keepGoing => 'नॉन-स्टॉप';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'रेंज से बाहर के ट्रैक कतार में रहेंगे, पर अपने-आप नहीं बजेंगे।';

  @override
  String get turnOff => 'बंद करें';

  @override
  String get lockAction => 'लॉक करें';

  @override
  String get queueEmptyHint =>
      'अभी कुछ नहीं। कोई ट्रैक जोड़ें या मेहमानों को QR दिखाएँ।';

  @override
  String get vetoBadge => 'वीटो';

  @override
  String get vetoMenu => 'वीटो';

  @override
  String get playNow => 'अभी चलाएँ';

  @override
  String get playNext => 'अगला चलाएँ';

  @override
  String get unpin => 'पिन हटाएँ';

  @override
  String get noGuestsYet => 'अभी कोई नहीं आया';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · वोट ×$weight, वीटो कर सकते हैं';
  }

  @override
  String get guestRole => 'मेहमान';

  @override
  String get removeCoDj => 'co-DJ हटाएँ';

  @override
  String get promoteCoDj => 'co-DJ बनाएँ';

  @override
  String get blockGuest => 'ब्लॉक करें';

  @override
  String get searchSoundCloudHint => 'SoundCloud पर खोजें…';

  @override
  String trackAdded(String title) {
    return '“$title” जोड़ा गया';
  }

  @override
  String get playlistSearchHint => 'कलाकार या कलाकार - गाना...';

  @override
  String get playlistIdle => 'कोई बैंड या गाना लिखें';

  @override
  String searchingFor(String query) {
    return '“$query” खोज रहे हैं…';
  }

  @override
  String get similarByBpm => 'मिलते-जुलते (BPM के अनुसार)';

  @override
  String errorWithMessage(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String get toastNoNextTrack => 'अगला ट्रैक नहीं मिला – कतार में कुछ जोड़ें';

  @override
  String get toastPickingNext => 'अगला ट्रैक चुन रहे हैं…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” नहीं चल सका – छोड़ रहे हैं';
  }

  @override
  String relayUnavailable(String error) {
    return 'रिले उपलब्ध नहीं: $error';
  }
}
