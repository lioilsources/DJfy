// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · કતાર: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'પાર્ટી $code';
  }

  @override
  String get addDeck => 'ડેક ઉમેરો';

  @override
  String get deckDropHint => 'ટ્રેક અહીં ખેંચો';

  @override
  String get deckWaitingForQueue => 'કતારની રાહ';

  @override
  String get dspUnavailable => 'DSP ઉપલબ્ધ નથી (HLS સ્ટ્રીમ)';

  @override
  String get bpmUnknown => 'BPM અજ્ઞાત';

  @override
  String get genericError => 'ભૂલ';

  @override
  String get partyTagline => 'તમારો ફોન DJ છે. સ્પીકર ફક્ત સ્પીકર છે.';

  @override
  String get partyIntro =>
      'મહેમાનો QR સ્કેન કરે છે, બ્રાઉઝરમાં શોધે છે અને મત આપે છે – ઍપ કે એકાઉન્ટ વિના. કતાર તમારી પાસે રહે છે, અવાજ AirPlay અથવા Bluetooth દ્વારા મોકલો.';

  @override
  String get partyNameLabel => 'પાર્ટીનું નામ';

  @override
  String get startParty => 'પાર્ટી શરૂ કરો';

  @override
  String get back => 'પાછા';

  @override
  String get qrForGuests => 'મહેમાનો માટે QR';

  @override
  String get endParty => 'પાર્ટી સમાપ્ત કરો';

  @override
  String get endPartyQuestion => 'પાર્ટી સમાપ્ત કરીએ?';

  @override
  String get endPartyWarning => 'મહેમાનો ડિસ્કનેક્ટ થશે અને કતાર ભૂંસાઈ જશે.';

  @override
  String get no => 'ના';

  @override
  String get endAction => 'સમાપ્ત કરો';

  @override
  String get tabQueue => 'કતાર';

  @override
  String get tabGuests => 'મહેમાનો';

  @override
  String get tabSearch => 'શોધો';

  @override
  String get copyLink => 'લિંક કૉપિ કરો';

  @override
  String get queueEmpty => 'કતાર ખાલી છે';

  @override
  String get readyPressPlay => 'તૈયાર – ▶ દબાવો';

  @override
  String addedBy(String name) {
    return '$nameએ ઉમેર્યું';
  }

  @override
  String get keepGoing => 'નૉન-સ્ટૉપ';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'રેન્જ બહારના ટ્રેક કતારમાં રહેશે, પણ જાતે નહીં વાગે.';

  @override
  String get turnOff => 'બંધ કરો';

  @override
  String get lockAction => 'લૉક કરો';

  @override
  String get queueEmptyHint =>
      'હજી કંઈ નથી. ટ્રેક ઉમેરો અથવા મહેમાનોને QR બતાવો.';

  @override
  String get vetoBadge => 'વીટો';

  @override
  String get vetoMenu => 'વીટો';

  @override
  String get playNow => 'હમણાં વગાડો';

  @override
  String get playNext => 'પછી વગાડો';

  @override
  String get unpin => 'પિન દૂર કરો';

  @override
  String get noGuestsYet => 'હજી કોઈ આવ્યું નથી';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · મત ×$weight, વીટો કરી શકે';
  }

  @override
  String get guestRole => 'મહેમાન';

  @override
  String get removeCoDj => 'co-DJ દૂર કરો';

  @override
  String get promoteCoDj => 'co-DJ બનાવો';

  @override
  String get blockGuest => 'બ્લૉક કરો';

  @override
  String get searchSoundCloudHint => 'SoundCloud પર શોધો…';

  @override
  String trackAdded(String title) {
    return '“$title” ઉમેરાયું';
  }

  @override
  String get playlistSearchHint => 'કલાકાર અથવા કલાકાર - ગીત...';

  @override
  String get playlistIdle => 'બેન્ડ અથવા ગીત લખો';

  @override
  String searchingFor(String query) {
    return '“$query” શોધી રહ્યા છીએ…';
  }

  @override
  String get similarByBpm => 'સમાન (BPM મુજબ)';

  @override
  String errorWithMessage(String message) {
    return 'ભૂલ: $message';
  }

  @override
  String get toastNoNextTrack => 'આગળનો ટ્રેક ન મળ્યો – કતારમાં કંઈક ઉમેરો';

  @override
  String get toastPickingNext => 'આગળનો ટ્રેક પસંદ કરી રહ્યા છીએ…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” વગાડી શકાતું નથી – છોડી રહ્યા છીએ';
  }

  @override
  String relayUnavailable(String error) {
    return 'રિલે ઉપલબ્ધ નથી: $error';
  }
}
