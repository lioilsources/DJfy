// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · ଧାଡ଼ି: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'ପାର୍ଟି $code';
  }

  @override
  String get addDeck => 'ଡେକ୍ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get deckDropHint => 'ଟ୍ରାକ୍ ଏଠାକୁ ଟାଣନ୍ତୁ';

  @override
  String get deckWaitingForQueue => 'ଧାଡ଼ି ପାଇଁ ଅପେକ୍ଷା';

  @override
  String get dspUnavailable => 'DSP ଉପଲବ୍ଧ ନାହିଁ (HLS ଷ୍ଟ୍ରିମ୍)';

  @override
  String get bpmUnknown => 'BPM ଅଜଣା';

  @override
  String get genericError => 'ତ୍ରୁଟି';

  @override
  String get partyTagline => 'ଆପଣଙ୍କ ଫୋନ୍ ହିଁ DJ। ସ୍ପିକର କେବଳ ସ୍ପିକର।';

  @override
  String get partyIntro =>
      'ଅତିଥିମାନେ QR ସ୍କାନ୍ କରି ବ୍ରାଉଜରରେ ଖୋଜନ୍ତି ଓ ଭୋଟ୍ ଦିଅନ୍ତି – ଆପ୍ ଓ ଆକାଉଣ୍ଟ ବିନା। ଧାଡ଼ି ଆପଣଙ୍କ ପାଖରେ ରହେ, ଧ୍ୱନି AirPlay କିମ୍ବା Bluetooth ଦ୍ୱାରା ପଠାନ୍ତୁ।';

  @override
  String get partyNameLabel => 'ପାର୍ଟିର ନାମ';

  @override
  String get startParty => 'ପାର୍ଟି ଆରମ୍ଭ କରନ୍ତୁ';

  @override
  String get back => 'ପଛକୁ';

  @override
  String get qrForGuests => 'ଅତିଥିଙ୍କ ପାଇଁ QR';

  @override
  String get endParty => 'ପାର୍ଟି ଶେଷ କରନ୍ତୁ';

  @override
  String get endPartyQuestion => 'ପାର୍ଟି ଶେଷ କରିବେ?';

  @override
  String get endPartyWarning =>
      'ଅତିଥିମାନଙ୍କ ସଂଯୋଗ ବିଚ୍ଛିନ୍ନ ହେବ ଓ ଧାଡ଼ି ଲିଭିଯିବ।';

  @override
  String get no => 'ନା';

  @override
  String get endAction => 'ଶେଷ କରନ୍ତୁ';

  @override
  String get tabQueue => 'ଧାଡ଼ି';

  @override
  String get tabGuests => 'ଅତିଥି';

  @override
  String get tabSearch => 'ଖୋଜନ୍ତୁ';

  @override
  String get copyLink => 'ଲିଙ୍କ କପି କରନ୍ତୁ';

  @override
  String get queueEmpty => 'ଧାଡ଼ି ଖାଲି ଅଛି';

  @override
  String get readyPressPlay => 'ପ୍ରସ୍ତୁତ – ▶ ଦବାନ୍ତୁ';

  @override
  String addedBy(String name) {
    return '$name ଯୋଡ଼ିଛନ୍ତି';
  }

  @override
  String get keepGoing => 'ନନ୍-ଷ୍ଟପ୍';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'ସୀମା ବାହାରର ଟ୍ରାକ୍ ଧାଡ଼ିରେ ରହିବ, କିନ୍ତୁ ନିଜେ ବାଜିବ ନାହିଁ।';

  @override
  String get turnOff => 'ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get lockAction => 'ଲକ୍ କରନ୍ତୁ';

  @override
  String get queueEmptyHint =>
      'ଏପର୍ଯ୍ୟନ୍ତ କିଛି ନାହିଁ। ଟ୍ରାକ୍ ଯୋଡ଼ନ୍ତୁ କିମ୍ବା ଅତିଥିଙ୍କୁ QR ଦେଖାନ୍ତୁ।';

  @override
  String get vetoBadge => 'ଭେଟୋ';

  @override
  String get vetoMenu => 'ଭେଟୋ';

  @override
  String get playNow => 'ବର୍ତ୍ତମାନ ବଜାନ୍ତୁ';

  @override
  String get playNext => 'ପରେ ବଜାନ୍ତୁ';

  @override
  String get unpin => 'ପିନ୍ ହଟାନ୍ତୁ';

  @override
  String get noGuestsYet => 'ଏପର୍ଯ୍ୟନ୍ତ କେହି ଆସିନାହାନ୍ତି';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ଭୋଟ୍ ×$weight, ଭେଟୋ କରିପାରିବେ';
  }

  @override
  String get guestRole => 'ଅତିଥି';

  @override
  String get removeCoDj => 'co-DJ ହଟାନ୍ତୁ';

  @override
  String get promoteCoDj => 'co-DJ କରନ୍ତୁ';

  @override
  String get blockGuest => 'ବ୍ଲକ୍ କରନ୍ତୁ';

  @override
  String get searchSoundCloudHint => 'SoundCloud ରେ ଖୋଜନ୍ତୁ…';

  @override
  String trackAdded(String title) {
    return '“$title” ଯୋଡ଼ାଗଲା';
  }

  @override
  String get playlistSearchHint => 'କଳାକାର କିମ୍ବା କଳାକାର - ଗୀତ...';

  @override
  String get playlistIdle => 'ଏକ ବ୍ୟାଣ୍ଡ କିମ୍ବା ଗୀତ ଲେଖନ୍ତୁ';

  @override
  String searchingFor(String query) {
    return '“$query” ଖୋଜୁଛି…';
  }

  @override
  String get similarByBpm => 'ସମାନ (BPM ଅନୁସାରେ)';

  @override
  String errorWithMessage(String message) {
    return 'ତ୍ରୁଟି: $message';
  }

  @override
  String get toastNoNextTrack =>
      'ପରବର୍ତ୍ତୀ ଟ୍ରାକ୍ ମିଳିଲା ନାହିଁ – ଧାଡ଼ିରେ କିଛି ଯୋଡ଼ନ୍ତୁ';

  @override
  String get toastPickingNext => 'ପରବର୍ତ୍ତୀ ଟ୍ରାକ୍ ବାଛୁଛି…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” ବଜାଯାଇପାରୁନି – ଛାଡ଼ୁଛି';
  }

  @override
  String relayUnavailable(String error) {
    return 'ରିଲେ ଉପଲବ୍ଧ ନାହିଁ: $error';
  }
}
