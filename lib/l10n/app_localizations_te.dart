// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · క్యూ: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'పార్టీ $code';
  }

  @override
  String get addDeck => 'డెక్ జోడించండి';

  @override
  String get deckDropHint => 'ట్రాక్‌ను ఇక్కడికి లాగండి';

  @override
  String get deckWaitingForQueue => 'క్యూ కోసం వేచి ఉంది';

  @override
  String get dspUnavailable => 'DSP అందుబాటులో లేదు (HLS స్ట్రీమ్)';

  @override
  String get bpmUnknown => 'BPM తెలియదు';

  @override
  String get genericError => 'లోపం';

  @override
  String get partyTagline => 'మీ ఫోనే DJ. స్పీకర్ కేవలం స్పీకర్.';

  @override
  String get partyIntro =>
      'అతిథులు QR స్కాన్ చేసి, బ్రౌజర్‌లో వెతికి ఓటు వేస్తారు – యాప్, ఖాతా అవసరం లేదు. క్యూ మీ దగ్గరే ఉంటుంది, శబ్దాన్ని AirPlay లేదా Bluetooth ద్వారా పంపండి.';

  @override
  String get partyNameLabel => 'పార్టీ పేరు';

  @override
  String get startParty => 'పార్టీ ప్రారంభించండి';

  @override
  String get back => 'వెనుకకు';

  @override
  String get qrForGuests => 'అతిథుల కోసం QR';

  @override
  String get endParty => 'పార్టీ ముగించండి';

  @override
  String get endPartyQuestion => 'పార్టీ ముగించాలా?';

  @override
  String get endPartyWarning =>
      'అతిథుల కనెక్షన్ తెగిపోతుంది, క్యూ తొలగించబడుతుంది.';

  @override
  String get no => 'కాదు';

  @override
  String get endAction => 'ముగించు';

  @override
  String get tabQueue => 'క్యూ';

  @override
  String get tabGuests => 'అతిథులు';

  @override
  String get tabSearch => 'వెతుకు';

  @override
  String get copyLink => 'లింక్ కాపీ చేయండి';

  @override
  String get queueEmpty => 'క్యూ ఖాళీగా ఉంది';

  @override
  String get readyPressPlay => 'సిద్ధం – ▶ నొక్కండి';

  @override
  String addedBy(String name) {
    return '$name జోడించారు';
  }

  @override
  String get keepGoing => 'నాన్-స్టాప్';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'పరిధి వెలుపలి ట్రాక్‌లు క్యూలో ఉంటాయి, కానీ వాటంతట అవే ప్లే కావు.';

  @override
  String get turnOff => 'ఆఫ్ చేయండి';

  @override
  String get lockAction => 'లాక్ చేయండి';

  @override
  String get queueEmptyHint =>
      'ఇంకా ఏమీ లేదు. ట్రాక్ జోడించండి లేదా అతిథులకు QR చూపించండి.';

  @override
  String get vetoBadge => 'వీటో';

  @override
  String get vetoMenu => 'వీటో';

  @override
  String get playNow => 'ఇప్పుడే ప్లే చేయండి';

  @override
  String get playNext => 'తర్వాత ప్లే చేయండి';

  @override
  String get unpin => 'పిన్ తీసివేయండి';

  @override
  String get noGuestsYet => 'ఇంకా ఎవరూ రాలేదు';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · ఓటు ×$weight, వీటో చేయగలరు';
  }

  @override
  String get guestRole => 'అతిథి';

  @override
  String get removeCoDj => 'co-DJ తీసివేయండి';

  @override
  String get promoteCoDj => 'co-DJ చేయండి';

  @override
  String get blockGuest => 'బ్లాక్ చేయండి';

  @override
  String get searchSoundCloudHint => 'SoundCloud‌లో వెతకండి…';

  @override
  String trackAdded(String title) {
    return '“$title” జోడించబడింది';
  }

  @override
  String get playlistSearchHint => 'కళాకారుడు లేదా కళాకారుడు - పాట...';

  @override
  String get playlistIdle => 'బ్యాండ్ లేదా పాటను నమోదు చేయండి';

  @override
  String searchingFor(String query) {
    return '“$query” కోసం వెతుకుతోంది…';
  }

  @override
  String get similarByBpm => 'ఇలాంటివి (BPM ప్రకారం)';

  @override
  String errorWithMessage(String message) {
    return 'లోపం: $message';
  }

  @override
  String get toastNoNextTrack =>
      'తదుపరి ట్రాక్ దొరకలేదు – క్యూలో ఏదైనా జోడించండి';

  @override
  String get toastPickingNext => 'తదుపరి ట్రాక్‌ను ఎంచుకుంటోంది…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” ప్లే కావడం లేదు – దాటవేస్తోంది';
  }

  @override
  String relayUnavailable(String error) {
    return 'రిలే అందుబాటులో లేదు: $error';
  }
}
