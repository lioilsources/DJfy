// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · kolejka: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Impreza $code';
  }

  @override
  String get addDeck => 'DODAJ DECK';

  @override
  String get deckDropHint => 'Przeciągnij tu utwór';

  @override
  String get deckWaitingForQueue => 'Czeka na kolejkę';

  @override
  String get dspUnavailable => 'DSP niedostępne (strumień HLS)';

  @override
  String get bpmUnknown => 'BPM nieznane';

  @override
  String get genericError => 'Błąd';

  @override
  String get partyTagline =>
      'Twój telefon jest DJ-em. Głośnik to tylko głośnik.';

  @override
  String get partyIntro =>
      'Goście skanują kod QR, szukają i głosują w przeglądarce – bez aplikacji i bez konta. Kolejka jest u ciebie, dźwięk wyślesz przez AirPlay lub Bluetooth.';

  @override
  String get partyNameLabel => 'Nazwa imprezy';

  @override
  String get startParty => 'ZAŁÓŻ IMPREZĘ';

  @override
  String get back => 'WSTECZ';

  @override
  String get qrForGuests => 'QR dla gości';

  @override
  String get endParty => 'Zakończ imprezę';

  @override
  String get endPartyQuestion => 'Zakończyć imprezę?';

  @override
  String get endPartyWarning =>
      'Goście zostaną rozłączeni, a kolejka wyczyszczona.';

  @override
  String get no => 'NIE';

  @override
  String get endAction => 'ZAKOŃCZ';

  @override
  String get tabQueue => 'KOLEJKA';

  @override
  String get tabGuests => 'GOŚCIE';

  @override
  String get tabSearch => 'SZUKAJ';

  @override
  String get copyLink => 'KOPIUJ LINK';

  @override
  String get queueEmpty => 'Kolejka jest pusta';

  @override
  String get readyPressPlay => 'Gotowe – naciśnij ▶';

  @override
  String addedBy(String name) {
    return 'dodał(a) $name';
  }

  @override
  String get keepGoing => 'BEZ KOŃCA';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Utwory spoza zakresu zostaną w kolejce, ale nie zagrają same.';

  @override
  String get turnOff => 'WYŁĄCZ';

  @override
  String get lockAction => 'ZABLOKUJ';

  @override
  String get queueEmptyHint =>
      'Na razie nic. Dodaj utwór albo pokaż gościom kod QR.';

  @override
  String get vetoBadge => 'WETO';

  @override
  String get vetoMenu => 'Weto';

  @override
  String get playNow => 'Graj teraz';

  @override
  String get playNext => 'Graj jako następny';

  @override
  String get unpin => 'Odepnij';

  @override
  String get noGuestsYet => 'Nikt jeszcze nie dotarł';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · głos ×$weight, może zawetować';
  }

  @override
  String get guestRole => 'gość';

  @override
  String get removeCoDj => 'Odbierz co-DJ';

  @override
  String get promoteCoDj => 'Awansuj na co-DJ';

  @override
  String get blockGuest => 'Zablokuj';

  @override
  String get searchSoundCloudHint => 'Szukaj w SoundCloud…';

  @override
  String trackAdded(String title) {
    return 'Dodano „$title”';
  }

  @override
  String get playlistSearchHint => 'Wykonawca lub Wykonawca - Utwór...';

  @override
  String get playlistIdle => 'Wpisz zespół lub utwór';

  @override
  String searchingFor(String query) {
    return 'Szukam „$query”…';
  }

  @override
  String get similarByBpm => 'Podobne (posortowane wg BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Błąd: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Nie znalazłem kolejnego utworu – dodaj jakiś do kolejki';

  @override
  String get toastPickingNext => 'Wybieram kolejny utwór…';

  @override
  String toastCannotPlay(String title) {
    return 'Nie można odtworzyć „$title” – pomijam';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay niedostępny: $error';
  }
}
