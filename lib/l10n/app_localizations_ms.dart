// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · baris gilir: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Parti $code';
  }

  @override
  String get addDeck => 'TAMBAH DEK';

  @override
  String get deckDropHint => 'Seret trek ke sini';

  @override
  String get deckWaitingForQueue => 'Menunggu baris gilir';

  @override
  String get dspUnavailable => 'DSP tidak tersedia (strim HLS)';

  @override
  String get bpmUnknown => 'BPM tidak diketahui';

  @override
  String get genericError => 'Ralat';

  @override
  String get partyTagline =>
      'Telefon anda ialah DJ. Pembesar suara hanyalah pembesar suara.';

  @override
  String get partyIntro =>
      'Tetamu mengimbas kod QR, mencari dan mengundi dalam pelayar – tanpa apl dan tanpa akaun. Baris gilir kekal pada anda, bunyi dihantar melalui AirPlay atau Bluetooth.';

  @override
  String get partyNameLabel => 'Nama parti';

  @override
  String get startParty => 'MULAKAN PARTI';

  @override
  String get back => 'KEMBALI';

  @override
  String get qrForGuests => 'QR untuk tetamu';

  @override
  String get endParty => 'Tamatkan parti';

  @override
  String get endPartyQuestion => 'Tamatkan parti?';

  @override
  String get endPartyWarning =>
      'Tetamu akan diputuskan dan baris gilir akan dipadam.';

  @override
  String get no => 'TIDAK';

  @override
  String get endAction => 'TAMATKAN';

  @override
  String get tabQueue => 'BARIS GILIR';

  @override
  String get tabGuests => 'TETAMU';

  @override
  String get tabSearch => 'CARI';

  @override
  String get copyLink => 'SALIN PAUTAN';

  @override
  String get queueEmpty => 'Baris gilir kosong';

  @override
  String get readyPressPlay => 'Sedia – tekan ▶';

  @override
  String addedBy(String name) {
    return 'ditambah oleh $name';
  }

  @override
  String get keepGoing => 'TANPA HENTI';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Trek di luar julat kekal dalam baris gilir tetapi tidak dimainkan sendiri.';

  @override
  String get turnOff => 'MATIKAN';

  @override
  String get lockAction => 'KUNCI';

  @override
  String get queueEmptyHint =>
      'Belum ada apa-apa. Tambah trek atau tunjukkan QR kepada tetamu.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Main sekarang';

  @override
  String get playNext => 'Main seterusnya';

  @override
  String get unpin => 'Nyahsemat';

  @override
  String get noGuestsYet => 'Belum ada sesiapa yang tiba';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · undi ×$weight, boleh memveto';
  }

  @override
  String get guestRole => 'tetamu';

  @override
  String get removeCoDj => 'Buang co-DJ';

  @override
  String get promoteCoDj => 'Jadikan co-DJ';

  @override
  String get blockGuest => 'Sekat';

  @override
  String get searchSoundCloudHint => 'Cari di SoundCloud…';

  @override
  String trackAdded(String title) {
    return '“$title” ditambah';
  }

  @override
  String get playlistSearchHint => 'Artis atau Artis - Lagu...';

  @override
  String get playlistIdle => 'Masukkan kumpulan atau lagu';

  @override
  String searchingFor(String query) {
    return 'Mencari “$query”…';
  }

  @override
  String get similarByBpm => 'Serupa (ikut BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Ralat: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Tiada trek seterusnya ditemui – tambah satu ke baris gilir';

  @override
  String get toastPickingNext => 'Memilih trek seterusnya…';

  @override
  String toastCannotPlay(String title) {
    return 'Tidak dapat memainkan “$title” – melangkau';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay tidak tersedia: $error';
  }
}
