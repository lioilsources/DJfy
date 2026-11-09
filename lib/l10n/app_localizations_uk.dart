// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · черга: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Вечірка $code';
  }

  @override
  String get addDeck => 'ДОДАТИ ДЕКУ';

  @override
  String get deckDropHint => 'Перетягни трек сюди';

  @override
  String get deckWaitingForQueue => 'Чекає на чергу';

  @override
  String get dspUnavailable => 'DSP недоступний (потік HLS)';

  @override
  String get bpmUnknown => 'BPM невідомий';

  @override
  String get genericError => 'Помилка';

  @override
  String get partyTagline => 'Твій телефон — діджей. Колонка — просто колонка.';

  @override
  String get partyIntro =>
      'Гості сканують QR-код, шукають і голосують у браузері – без застосунку й без акаунта. Черга живе в тебе, звук передаєш через AirPlay або Bluetooth.';

  @override
  String get partyNameLabel => 'Назва вечірки';

  @override
  String get startParty => 'ПОЧАТИ ВЕЧІРКУ';

  @override
  String get back => 'НАЗАД';

  @override
  String get qrForGuests => 'QR для гостей';

  @override
  String get endParty => 'Завершити вечірку';

  @override
  String get endPartyQuestion => 'Завершити вечірку?';

  @override
  String get endPartyWarning => 'Гостей буде від’єднано, а чергу очищено.';

  @override
  String get no => 'НІ';

  @override
  String get endAction => 'ЗАВЕРШИТИ';

  @override
  String get tabQueue => 'ЧЕРГА';

  @override
  String get tabGuests => 'ГОСТІ';

  @override
  String get tabSearch => 'ПОШУК';

  @override
  String get copyLink => 'КОПІЮВАТИ ПОСИЛАННЯ';

  @override
  String get queueEmpty => 'Черга порожня';

  @override
  String get readyPressPlay => 'Готово – натисни ▶';

  @override
  String addedBy(String name) {
    return 'додав(-ла) $name';
  }

  @override
  String get keepGoing => 'БЕЗ ЗУПИНКИ';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Треки поза діапазоном залишаться в черзі, але самі не заграють.';

  @override
  String get turnOff => 'ВИМКНУТИ';

  @override
  String get lockAction => 'ЗАФІКСУВАТИ';

  @override
  String get queueEmptyHint =>
      'Поки нічого. Додай трек або покажи гостям QR-код.';

  @override
  String get vetoBadge => 'ВЕТО';

  @override
  String get vetoMenu => 'Вето';

  @override
  String get playNow => 'Грати зараз';

  @override
  String get playNext => 'Грати наступним';

  @override
  String get unpin => 'Відкріпити';

  @override
  String get noGuestsYet => 'Ще ніхто не прийшов';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · голос ×$weight, може накласти вето';
  }

  @override
  String get guestRole => 'гість';

  @override
  String get removeCoDj => 'Забрати co-DJ';

  @override
  String get promoteCoDj => 'Зробити co-DJ';

  @override
  String get blockGuest => 'Заблокувати';

  @override
  String get searchSoundCloudHint => 'Шукати в SoundCloud…';

  @override
  String trackAdded(String title) {
    return '«$title» додано';
  }

  @override
  String get playlistSearchHint => 'Виконавець або Виконавець - Пісня...';

  @override
  String get playlistIdle => 'Введи гурт або пісню';

  @override
  String searchingFor(String query) {
    return 'Шукаю «$query»…';
  }

  @override
  String get similarByBpm => 'Схожі (за BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Помилка: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Не знайшов наступного треку – додай якийсь у чергу';

  @override
  String get toastPickingNext => 'Вибираю наступний трек…';

  @override
  String toastCannotPlay(String title) {
    return 'Не вдається відтворити «$title» – пропускаю';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay недоступний: $error';
  }
}
