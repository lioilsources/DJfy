// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · रांग: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'पार्टी $code';
  }

  @override
  String get addDeck => 'डेक जोडा';

  @override
  String get deckDropHint => 'ट्रॅक इथे ओढा';

  @override
  String get deckWaitingForQueue => 'रांगेची वाट';

  @override
  String get dspUnavailable => 'DSP उपलब्ध नाही (HLS स्ट्रीम)';

  @override
  String get bpmUnknown => 'BPM अज्ञात';

  @override
  String get genericError => 'त्रुटी';

  @override
  String get partyTagline => 'तुमचा फोन DJ आहे. स्पीकर फक्त स्पीकर आहे.';

  @override
  String get partyIntro =>
      'पाहुणे QR स्कॅन करतात, ब्राउझरमध्ये शोधतात आणि मत देतात – ॲप आणि खात्याशिवाय. रांग तुमच्याकडे राहते, आवाज AirPlay किंवा Bluetooth ने पाठवा.';

  @override
  String get partyNameLabel => 'पार्टीचे नाव';

  @override
  String get startParty => 'पार्टी सुरू करा';

  @override
  String get back => 'मागे';

  @override
  String get qrForGuests => 'पाहुण्यांसाठी QR';

  @override
  String get endParty => 'पार्टी संपवा';

  @override
  String get endPartyQuestion => 'पार्टी संपवायची?';

  @override
  String get endPartyWarning =>
      'पाहुण्यांचे कनेक्शन तुटेल आणि रांग पुसली जाईल.';

  @override
  String get no => 'नाही';

  @override
  String get endAction => 'संपवा';

  @override
  String get tabQueue => 'रांग';

  @override
  String get tabGuests => 'पाहुणे';

  @override
  String get tabSearch => 'शोधा';

  @override
  String get copyLink => 'लिंक कॉपी करा';

  @override
  String get queueEmpty => 'रांग रिकामी आहे';

  @override
  String get readyPressPlay => 'तयार – ▶ दाबा';

  @override
  String addedBy(String name) {
    return '$name यांनी जोडले';
  }

  @override
  String get keepGoing => 'नॉन-स्टॉप';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'मर्यादेबाहेरचे ट्रॅक रांगेत राहतील, पण आपोआप वाजणार नाहीत.';

  @override
  String get turnOff => 'बंद करा';

  @override
  String get lockAction => 'लॉक करा';

  @override
  String get queueEmptyHint =>
      'अजून काही नाही. ट्रॅक जोडा किंवा पाहुण्यांना QR दाखवा.';

  @override
  String get vetoBadge => 'व्हेटो';

  @override
  String get vetoMenu => 'व्हेटो';

  @override
  String get playNow => 'आता वाजवा';

  @override
  String get playNext => 'पुढे वाजवा';

  @override
  String get unpin => 'पिन काढा';

  @override
  String get noGuestsYet => 'अजून कोणी आले नाही';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · मत ×$weight, व्हेटो करू शकतात';
  }

  @override
  String get guestRole => 'पाहुणे';

  @override
  String get removeCoDj => 'co-DJ काढा';

  @override
  String get promoteCoDj => 'co-DJ बनवा';

  @override
  String get blockGuest => 'ब्लॉक करा';

  @override
  String get searchSoundCloudHint => 'SoundCloud वर शोधा…';

  @override
  String trackAdded(String title) {
    return '“$title” जोडले';
  }

  @override
  String get playlistSearchHint => 'कलाकार किंवा कलाकार - गाणे...';

  @override
  String get playlistIdle => 'बँड किंवा गाणे लिहा';

  @override
  String searchingFor(String query) {
    return '“$query” शोधत आहे…';
  }

  @override
  String get similarByBpm => 'सारखे (BPM नुसार)';

  @override
  String errorWithMessage(String message) {
    return 'त्रुटी: $message';
  }

  @override
  String get toastNoNextTrack =>
      'पुढचा ट्रॅक सापडला नाही – रांगेत काहीतरी जोडा';

  @override
  String get toastPickingNext => 'पुढचा ट्रॅक निवडत आहे…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” वाजवता येत नाही – वगळत आहे';
  }

  @override
  String relayUnavailable(String error) {
    return 'रिले उपलब्ध नाही: $error';
  }
}
