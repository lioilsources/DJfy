// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · sıra: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Parti $code';
  }

  @override
  String get addDeck => 'DECK EKLE';

  @override
  String get deckDropHint => 'Bir parçayı buraya sürükle';

  @override
  String get deckWaitingForQueue => 'Sırayı bekliyor';

  @override
  String get dspUnavailable => 'DSP kullanılamıyor (HLS yayını)';

  @override
  String get bpmUnknown => 'BPM bilinmiyor';

  @override
  String get genericError => 'Hata';

  @override
  String get partyTagline => 'Telefonun DJ. Hoparlör sadece hoparlör.';

  @override
  String get partyIntro =>
      'Konuklar QR kodu tarar, tarayıcıda arar ve oy verir – uygulama ve hesap olmadan. Sıra sende durur, sesi AirPlay veya Bluetooth ile gönderirsin.';

  @override
  String get partyNameLabel => 'Parti adı';

  @override
  String get startParty => 'PARTİ BAŞLAT';

  @override
  String get back => 'GERİ';

  @override
  String get qrForGuests => 'Konuklar için QR';

  @override
  String get endParty => 'Partiyi bitir';

  @override
  String get endPartyQuestion => 'Parti bitirilsin mi?';

  @override
  String get endPartyWarning =>
      'Konukların bağlantısı kesilir ve sıra silinir.';

  @override
  String get no => 'HAYIR';

  @override
  String get endAction => 'BİTİR';

  @override
  String get tabQueue => 'SIRA';

  @override
  String get tabGuests => 'KONUKLAR';

  @override
  String get tabSearch => 'ARA';

  @override
  String get copyLink => 'BAĞLANTIYI KOPYALA';

  @override
  String get queueEmpty => 'Sıra boş';

  @override
  String get readyPressPlay => 'Hazır – ▶ tuşuna bas';

  @override
  String addedBy(String name) {
    return 'ekleyen: $name';
  }

  @override
  String get keepGoing => 'DURMADAN';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Aralık dışındaki parçalar sırada kalır ama kendiliğinden çalmaz.';

  @override
  String get turnOff => 'KAPAT';

  @override
  String get lockAction => 'KİLİTLE';

  @override
  String get queueEmptyHint =>
      'Henüz bir şey yok. Bir parça ekle ya da konuklara QR kodu göster.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Şimdi çal';

  @override
  String get playNext => 'Sıradaki olarak çal';

  @override
  String get unpin => 'Sabitlemeyi kaldır';

  @override
  String get noGuestsYet => 'Henüz kimse gelmedi';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · oy ×$weight, veto edebilir';
  }

  @override
  String get guestRole => 'konuk';

  @override
  String get removeCoDj => 'co-DJ\'liği kaldır';

  @override
  String get promoteCoDj => 'co-DJ yap';

  @override
  String get blockGuest => 'Engelle';

  @override
  String get searchSoundCloudHint => 'SoundCloud\'da ara…';

  @override
  String trackAdded(String title) {
    return '“$title” eklendi';
  }

  @override
  String get playlistSearchHint => 'Sanatçı veya Sanatçı - Şarkı...';

  @override
  String get playlistIdle => 'Bir grup ya da şarkı yaz';

  @override
  String searchingFor(String query) {
    return '“$query” aranıyor…';
  }

  @override
  String get similarByBpm => 'Benzerler (BPM\'e göre)';

  @override
  String errorWithMessage(String message) {
    return 'Hata: $message';
  }

  @override
  String get toastNoNextTrack => 'Başka parça bulunamadı – sıraya bir şey ekle';

  @override
  String get toastPickingNext => 'Sonraki parça seçiliyor…';

  @override
  String toastCannotPlay(String title) {
    return '“$title” çalınamıyor – atlanıyor';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay kullanılamıyor: $error';
  }
}
