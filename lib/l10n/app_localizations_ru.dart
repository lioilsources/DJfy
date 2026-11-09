// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · очередь: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Вечеринка $code';
  }

  @override
  String get addDeck => 'ДОБАВИТЬ ДЕКУ';

  @override
  String get deckDropHint => 'Перетащи трек сюда';

  @override
  String get deckWaitingForQueue => 'Ждёт очередь';

  @override
  String get dspUnavailable => 'DSP недоступен (поток HLS)';

  @override
  String get bpmUnknown => 'BPM неизвестен';

  @override
  String get genericError => 'Ошибка';

  @override
  String get partyTagline => 'Твой телефон — диджей. Колонка — просто колонка.';

  @override
  String get partyIntro =>
      'Гости сканируют QR-код, ищут и голосуют в браузере – без приложения и без аккаунта. Очередь живёт у тебя, звук отправляешь через AirPlay или Bluetooth.';

  @override
  String get partyNameLabel => 'Название вечеринки';

  @override
  String get startParty => 'НАЧАТЬ ВЕЧЕРИНКУ';

  @override
  String get back => 'НАЗАД';

  @override
  String get qrForGuests => 'QR для гостей';

  @override
  String get endParty => 'Завершить вечеринку';

  @override
  String get endPartyQuestion => 'Завершить вечеринку?';

  @override
  String get endPartyWarning => 'Гости будут отключены, а очередь очищена.';

  @override
  String get no => 'НЕТ';

  @override
  String get endAction => 'ЗАВЕРШИТЬ';

  @override
  String get tabQueue => 'ОЧЕРЕДЬ';

  @override
  String get tabGuests => 'ГОСТИ';

  @override
  String get tabSearch => 'ПОИСК';

  @override
  String get copyLink => 'КОПИРОВАТЬ ССЫЛКУ';

  @override
  String get queueEmpty => 'Очередь пуста';

  @override
  String get readyPressPlay => 'Готово – нажми ▶';

  @override
  String addedBy(String name) {
    return 'добавил(а) $name';
  }

  @override
  String get keepGoing => 'БЕЗ ОСТАНОВКИ';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Треки вне диапазона останутся в очереди, но сами не заиграют.';

  @override
  String get turnOff => 'ВЫКЛЮЧИТЬ';

  @override
  String get lockAction => 'ЗАФИКСИРОВАТЬ';

  @override
  String get queueEmptyHint =>
      'Пока ничего. Добавь трек или покажи гостям QR-код.';

  @override
  String get vetoBadge => 'ВЕТО';

  @override
  String get vetoMenu => 'Вето';

  @override
  String get playNow => 'Играть сейчас';

  @override
  String get playNext => 'Играть следующим';

  @override
  String get unpin => 'Открепить';

  @override
  String get noGuestsYet => 'Пока никто не пришёл';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · голос ×$weight, может наложить вето';
  }

  @override
  String get guestRole => 'гость';

  @override
  String get removeCoDj => 'Снять co-DJ';

  @override
  String get promoteCoDj => 'Сделать co-DJ';

  @override
  String get blockGuest => 'Заблокировать';

  @override
  String get searchSoundCloudHint => 'Искать в SoundCloud…';

  @override
  String trackAdded(String title) {
    return '«$title» добавлен';
  }

  @override
  String get playlistSearchHint => 'Исполнитель или Исполнитель - Песня...';

  @override
  String get playlistIdle => 'Введи группу или песню';

  @override
  String searchingFor(String query) {
    return 'Ищу «$query»…';
  }

  @override
  String get similarByBpm => 'Похожие (по BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Не нашёл следующий трек – добавь какой-нибудь в очередь';

  @override
  String get toastPickingNext => 'Выбираю следующий трек…';

  @override
  String toastCannotPlay(String title) {
    return 'Не удаётся воспроизвести «$title» – пропускаю';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay недоступен: $error';
  }
}
