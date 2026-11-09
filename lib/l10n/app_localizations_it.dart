// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · coda: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Festa $code';
  }

  @override
  String get addDeck => 'AGGIUNGI DECK';

  @override
  String get deckDropHint => 'Trascina qui un brano';

  @override
  String get deckWaitingForQueue => 'In attesa della coda';

  @override
  String get dspUnavailable => 'DSP non disponibile (stream HLS)';

  @override
  String get bpmUnknown => 'BPM sconosciuto';

  @override
  String get genericError => 'Errore';

  @override
  String get partyTagline =>
      'Il tuo telefono è il DJ. La cassa è solo una cassa.';

  @override
  String get partyIntro =>
      'Gli ospiti scansionano il QR, cercano e votano nel browser – senza app e senza account. La coda vive sul tuo telefono, l’audio lo mandi via AirPlay o Bluetooth.';

  @override
  String get partyNameLabel => 'Nome della festa';

  @override
  String get startParty => 'AVVIA LA FESTA';

  @override
  String get back => 'INDIETRO';

  @override
  String get qrForGuests => 'QR per gli ospiti';

  @override
  String get endParty => 'Termina la festa';

  @override
  String get endPartyQuestion => 'Terminare la festa?';

  @override
  String get endPartyWarning =>
      'Gli ospiti verranno disconnessi e la coda sarà cancellata.';

  @override
  String get no => 'NO';

  @override
  String get endAction => 'TERMINA';

  @override
  String get tabQueue => 'CODA';

  @override
  String get tabGuests => 'OSPITI';

  @override
  String get tabSearch => 'CERCA';

  @override
  String get copyLink => 'COPIA LINK';

  @override
  String get queueEmpty => 'La coda è vuota';

  @override
  String get readyPressPlay => 'Pronto – premi ▶';

  @override
  String addedBy(String name) {
    return 'aggiunto da $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'I brani fuori intervallo restano in coda, ma non partono da soli.';

  @override
  String get turnOff => 'DISATTIVA';

  @override
  String get lockAction => 'BLOCCA';

  @override
  String get queueEmptyHint =>
      'Ancora niente. Aggiungi un brano o mostra il QR agli ospiti.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Riproduci ora';

  @override
  String get playNext => 'Riproduci dopo';

  @override
  String get unpin => 'Sblocca';

  @override
  String get noGuestsYet => 'Non è ancora arrivato nessuno';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · voto ×$weight, può porre il veto';
  }

  @override
  String get guestRole => 'ospite';

  @override
  String get removeCoDj => 'Rimuovi co-DJ';

  @override
  String get promoteCoDj => 'Promuovi a co-DJ';

  @override
  String get blockGuest => 'Blocca';

  @override
  String get searchSoundCloudHint => 'Cerca su SoundCloud…';

  @override
  String trackAdded(String title) {
    return '«$title» aggiunto';
  }

  @override
  String get playlistSearchHint => 'Artista o Artista - Brano...';

  @override
  String get playlistIdle => 'Inserisci una band o un brano';

  @override
  String searchingFor(String query) {
    return 'Cerco «$query»…';
  }

  @override
  String get similarByBpm => 'Simili (ordinati per BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Nessun altro brano trovato – aggiungine uno alla coda';

  @override
  String get toastPickingNext => 'Scelgo il prossimo brano…';

  @override
  String toastCannotPlay(String title) {
    return 'Impossibile riprodurre «$title» – salto';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay non disponibile: $error';
  }
}
