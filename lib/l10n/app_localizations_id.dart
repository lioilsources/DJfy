// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · antrean: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Pesta $code';
  }

  @override
  String get addDeck => 'TAMBAH DECK';

  @override
  String get deckDropHint => 'Seret trek ke sini';

  @override
  String get deckWaitingForQueue => 'Menunggu antrean';

  @override
  String get dspUnavailable => 'DSP tidak tersedia (stream HLS)';

  @override
  String get bpmUnknown => 'BPM tidak diketahui';

  @override
  String get genericError => 'Kesalahan';

  @override
  String get partyTagline => 'Ponselmu adalah DJ. Speaker hanyalah speaker.';

  @override
  String get partyIntro =>
      'Tamu memindai kode QR, mencari, dan memilih di browser – tanpa aplikasi dan tanpa akun. Antrean ada di ponselmu, suara dikirim lewat AirPlay atau Bluetooth.';

  @override
  String get partyNameLabel => 'Nama pesta';

  @override
  String get startParty => 'MULAI PESTA';

  @override
  String get back => 'KEMBALI';

  @override
  String get qrForGuests => 'QR untuk tamu';

  @override
  String get endParty => 'Akhiri pesta';

  @override
  String get endPartyQuestion => 'Akhiri pesta?';

  @override
  String get endPartyWarning => 'Tamu akan terputus dan antrean akan dihapus.';

  @override
  String get no => 'TIDAK';

  @override
  String get endAction => 'AKHIRI';

  @override
  String get tabQueue => 'ANTREAN';

  @override
  String get tabGuests => 'TAMU';

  @override
  String get tabSearch => 'CARI';

  @override
  String get copyLink => 'SALIN TAUTAN';

  @override
  String get queueEmpty => 'Antrean kosong';

  @override
  String get readyPressPlay => 'Siap – tekan ▶';

  @override
  String addedBy(String name) {
    return 'ditambahkan oleh $name';
  }

  @override
  String get keepGoing => 'NONSTOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Trek di luar rentang tetap di antrean, tetapi tidak diputar sendiri.';

  @override
  String get turnOff => 'MATIKAN';

  @override
  String get lockAction => 'KUNCI';

  @override
  String get queueEmptyHint =>
      'Belum ada apa-apa. Tambahkan trek atau tunjukkan QR ke tamu.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Putar sekarang';

  @override
  String get playNext => 'Putar berikutnya';

  @override
  String get unpin => 'Lepas sematan';

  @override
  String get noGuestsYet => 'Belum ada yang datang';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · suara ×$weight, bisa memveto';
  }

  @override
  String get guestRole => 'tamu';

  @override
  String get removeCoDj => 'Cabut co-DJ';

  @override
  String get promoteCoDj => 'Jadikan co-DJ';

  @override
  String get blockGuest => 'Blokir';

  @override
  String get searchSoundCloudHint => 'Cari di SoundCloud…';

  @override
  String trackAdded(String title) {
    return '“$title” ditambahkan';
  }

  @override
  String get playlistSearchHint => 'Artis atau Artis - Lagu...';

  @override
  String get playlistIdle => 'Masukkan band atau lagu';

  @override
  String searchingFor(String query) {
    return 'Mencari “$query”…';
  }

  @override
  String get similarByBpm => 'Serupa (urut BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Tidak menemukan trek berikutnya – tambahkan satu ke antrean';

  @override
  String get toastPickingNext => 'Memilih trek berikutnya…';

  @override
  String toastCannotPlay(String title) {
    return 'Tidak bisa memutar “$title” – dilewati';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay tidak tersedia: $error';
  }
}
