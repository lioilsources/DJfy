// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · cua: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Festa $code';
  }

  @override
  String get addDeck => 'AFEGIR DECK';

  @override
  String get deckDropHint => 'Arrossega una pista aquí';

  @override
  String get deckWaitingForQueue => 'Esperant la cua';

  @override
  String get dspUnavailable => 'DSP no disponible (stream HLS)';

  @override
  String get bpmUnknown => 'BPM desconegut';

  @override
  String get genericError => 'Error';

  @override
  String get partyTagline =>
      'El teu mòbil és el DJ. L’altaveu només és un altaveu.';

  @override
  String get partyIntro =>
      'Els convidats escanegen el QR, cerquen i voten al navegador – sense app i sense compte. La cua viu al teu mòbil i el so l’envies per AirPlay o Bluetooth.';

  @override
  String get partyNameLabel => 'Nom de la festa';

  @override
  String get startParty => 'CREAR FESTA';

  @override
  String get back => 'ENRERE';

  @override
  String get qrForGuests => 'QR per als convidats';

  @override
  String get endParty => 'Acabar la festa';

  @override
  String get endPartyQuestion => 'Vols acabar la festa?';

  @override
  String get endPartyWarning =>
      'Els convidats es desconnectaran i la cua s’esborrarà.';

  @override
  String get no => 'NO';

  @override
  String get endAction => 'ACABAR';

  @override
  String get tabQueue => 'CUA';

  @override
  String get tabGuests => 'CONVIDATS';

  @override
  String get tabSearch => 'CERCAR';

  @override
  String get copyLink => 'COPIAR ENLLAÇ';

  @override
  String get queueEmpty => 'La cua és buida';

  @override
  String get readyPressPlay => 'A punt – prem ▶';

  @override
  String addedBy(String name) {
    return 'afegida per $name';
  }

  @override
  String get keepGoing => 'SENSE PARAR';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Les pistes fora del rang es queden a la cua, però no sonaran soles.';

  @override
  String get turnOff => 'DESACTIVAR';

  @override
  String get lockAction => 'BLOQUEJAR';

  @override
  String get queueEmptyHint =>
      'Encara res. Afegeix una pista o ensenya el QR als convidats.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Vetar';

  @override
  String get playNow => 'Reprodueix ara';

  @override
  String get playNext => 'Reprodueix després';

  @override
  String get unpin => 'Desfixa';

  @override
  String get noGuestsYet => 'Encara no ha arribat ningú';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · vot ×$weight, pot vetar';
  }

  @override
  String get guestRole => 'convidat';

  @override
  String get removeCoDj => 'Treure co-DJ';

  @override
  String get promoteCoDj => 'Fer co-DJ';

  @override
  String get blockGuest => 'Bloquejar';

  @override
  String get searchSoundCloudHint => 'Cerca a SoundCloud…';

  @override
  String trackAdded(String title) {
    return '«$title» afegida';
  }

  @override
  String get playlistSearchHint => 'Artista o Artista - Cançó...';

  @override
  String get playlistIdle => 'Escriu un grup o una cançó';

  @override
  String searchingFor(String query) {
    return 'Cercant «$query»…';
  }

  @override
  String get similarByBpm => 'Semblants (ordenades per BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get toastNoNextTrack =>
      'No he trobat cap altra pista – afegeix-ne una a la cua';

  @override
  String get toastPickingNext => 'Triant la pista següent…';

  @override
  String toastCannotPlay(String title) {
    return 'No es pot reproduir «$title» – la salto';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay no disponible: $error';
  }
}
