// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · cola: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Fiesta $code';
  }

  @override
  String get addDeck => 'AÑADIR DECK';

  @override
  String get deckDropHint => 'Arrastra una pista aquí';

  @override
  String get deckWaitingForQueue => 'Esperando la cola';

  @override
  String get dspUnavailable => 'DSP no disponible (stream HLS)';

  @override
  String get bpmUnknown => 'BPM desconocido';

  @override
  String get genericError => 'Error';

  @override
  String get partyTagline =>
      'Tu móvil es el DJ. El altavoz es solo un altavoz.';

  @override
  String get partyIntro =>
      'Los invitados escanean el QR, buscan y votan en el navegador – sin app y sin cuenta. La cola vive en tu móvil y el sonido lo envías por AirPlay o Bluetooth.';

  @override
  String get partyNameLabel => 'Nombre de la fiesta';

  @override
  String get startParty => 'CREAR FIESTA';

  @override
  String get back => 'ATRÁS';

  @override
  String get qrForGuests => 'QR para invitados';

  @override
  String get endParty => 'Terminar la fiesta';

  @override
  String get endPartyQuestion => '¿Terminar la fiesta?';

  @override
  String get endPartyWarning =>
      'Los invitados se desconectarán y la cola se borrará.';

  @override
  String get no => 'NO';

  @override
  String get endAction => 'TERMINAR';

  @override
  String get tabQueue => 'COLA';

  @override
  String get tabGuests => 'INVITADOS';

  @override
  String get tabSearch => 'BUSCAR';

  @override
  String get copyLink => 'COPIAR ENLACE';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String get readyPressPlay => 'Listo – pulsa ▶';

  @override
  String addedBy(String name) {
    return 'añadida por $name';
  }

  @override
  String get keepGoing => 'SIN PARAR';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Las pistas fuera del rango se quedan en la cola, pero no sonarán solas.';

  @override
  String get turnOff => 'DESACTIVAR';

  @override
  String get lockAction => 'BLOQUEAR';

  @override
  String get queueEmptyHint =>
      'Nada todavía. Añade una pista o enseña el QR a los invitados.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Vetar';

  @override
  String get playNow => 'Reproducir ahora';

  @override
  String get playNext => 'Reproducir después';

  @override
  String get unpin => 'Desfijar';

  @override
  String get noGuestsYet => 'Todavía no ha llegado nadie';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · voto ×$weight, puede vetar';
  }

  @override
  String get guestRole => 'invitado';

  @override
  String get removeCoDj => 'Quitar co-DJ';

  @override
  String get promoteCoDj => 'Hacer co-DJ';

  @override
  String get blockGuest => 'Bloquear';

  @override
  String get searchSoundCloudHint => 'Buscar en SoundCloud…';

  @override
  String trackAdded(String title) {
    return '«$title» añadida';
  }

  @override
  String get playlistSearchHint => 'Artista o Artista - Canción...';

  @override
  String get playlistIdle => 'Escribe un grupo o una canción';

  @override
  String searchingFor(String query) {
    return 'Buscando «$query»…';
  }

  @override
  String get similarByBpm => 'Similares (ordenadas por BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get toastNoNextTrack =>
      'No encontré otra pista – añade alguna a la cola';

  @override
  String get toastPickingNext => 'Eligiendo la siguiente pista…';

  @override
  String toastCannotPlay(String title) {
    return 'No se puede reproducir «$title» – la salto';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay no disponible: $error';
  }
}
