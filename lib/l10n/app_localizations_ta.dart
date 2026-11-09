// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · வரிசை: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'பார்ட்டி $code';
  }

  @override
  String get addDeck => 'டெக் சேர்';

  @override
  String get deckDropHint => 'டிராக்கை இங்கே இழுக்கவும்';

  @override
  String get deckWaitingForQueue => 'வரிசைக்காகக் காத்திருக்கிறது';

  @override
  String get dspUnavailable => 'DSP கிடைக்கவில்லை (HLS ஸ்ட்ரீம்)';

  @override
  String get bpmUnknown => 'BPM தெரியவில்லை';

  @override
  String get genericError => 'பிழை';

  @override
  String get partyTagline => 'உங்கள் போன்தான் DJ. ஸ்பீக்கர் வெறும் ஸ்பீக்கர்.';

  @override
  String get partyIntro =>
      'விருந்தினர்கள் QR-ஐ ஸ்கேன் செய்து, உலாவியில் தேடி வாக்களிக்கிறார்கள் – ஆப்பும் கணக்கும் தேவையில்லை. வரிசை உங்களிடம் இருக்கும், ஒலியை AirPlay அல்லது Bluetooth வழியாக அனுப்புங்கள்.';

  @override
  String get partyNameLabel => 'பார்ட்டியின் பெயர்';

  @override
  String get startParty => 'பார்ட்டியைத் தொடங்கு';

  @override
  String get back => 'பின்செல்';

  @override
  String get qrForGuests => 'விருந்தினர்களுக்கான QR';

  @override
  String get endParty => 'பார்ட்டியை முடி';

  @override
  String get endPartyQuestion => 'பார்ட்டியை முடிக்கவா?';

  @override
  String get endPartyWarning =>
      'விருந்தினர்களின் இணைப்பு துண்டிக்கப்படும், வரிசை அழிக்கப்படும்.';

  @override
  String get no => 'இல்லை';

  @override
  String get endAction => 'முடி';

  @override
  String get tabQueue => 'வரிசை';

  @override
  String get tabGuests => 'விருந்தினர்கள்';

  @override
  String get tabSearch => 'தேடு';

  @override
  String get copyLink => 'இணைப்பை நகலெடு';

  @override
  String get queueEmpty => 'வரிசை காலியாக உள்ளது';

  @override
  String get readyPressPlay => 'தயார் – ▶ அழுத்தவும்';

  @override
  String addedBy(String name) {
    return '$name சேர்த்தது';
  }

  @override
  String get keepGoing => 'நான்-ஸ்டாப்';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'வரம்புக்கு வெளியே உள்ள டிராக்குகள் வரிசையில் இருக்கும், ஆனால் தானாக இயங்காது.';

  @override
  String get turnOff => 'அணை';

  @override
  String get lockAction => 'பூட்டு';

  @override
  String get queueEmptyHint =>
      'இன்னும் எதுவும் இல்லை. ஒரு டிராக்கைச் சேர்க்கவும் அல்லது விருந்தினர்களுக்கு QR-ஐக் காட்டவும்.';

  @override
  String get vetoBadge => 'வீட்டோ';

  @override
  String get vetoMenu => 'வீட்டோ';

  @override
  String get playNow => 'இப்போது இயக்கு';

  @override
  String get playNext => 'அடுத்ததாக இயக்கு';

  @override
  String get unpin => 'பின்னை நீக்கு';

  @override
  String get noGuestsYet => 'இன்னும் யாரும் வரவில்லை';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · வாக்கு ×$weight, வீட்டோ செய்யலாம்';
  }

  @override
  String get guestRole => 'விருந்தினர்';

  @override
  String get removeCoDj => 'co-DJ-ஐ நீக்கு';

  @override
  String get promoteCoDj => 'co-DJ ஆக்கு';

  @override
  String get blockGuest => 'தடு';

  @override
  String get searchSoundCloudHint => 'SoundCloud-இல் தேடு…';

  @override
  String trackAdded(String title) {
    return '“$title” சேர்க்கப்பட்டது';
  }

  @override
  String get playlistSearchHint => 'கலைஞர் அல்லது கலைஞர் - பாடல்...';

  @override
  String get playlistIdle => 'ஒரு இசைக்குழு அல்லது பாடலை உள்ளிடவும்';

  @override
  String searchingFor(String query) {
    return '“$query” தேடுகிறது…';
  }

  @override
  String get similarByBpm => 'ஒத்தவை (BPM படி)';

  @override
  String errorWithMessage(String message) {
    return 'பிழை: $message';
  }

  @override
  String get toastNoNextTrack =>
      'அடுத்த டிராக் கிடைக்கவில்லை – வரிசையில் ஏதாவது சேர்க்கவும்';

  @override
  String get toastPickingNext => 'அடுத்த டிராக்கைத் தேர்ந்தெடுக்கிறது…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” இயக்க முடியவில்லை – தவிர்க்கிறது';
  }

  @override
  String relayUnavailable(String error) {
    return 'ரிலே கிடைக்கவில்லை: $error';
  }
}
