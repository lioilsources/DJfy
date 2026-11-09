// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · file : $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Soirée $code';
  }

  @override
  String get addDeck => 'AJOUTER UNE PLATINE';

  @override
  String get deckDropHint => 'Glisse un morceau ici';

  @override
  String get deckWaitingForQueue => 'En attente de la file';

  @override
  String get dspUnavailable => 'DSP indisponible (flux HLS)';

  @override
  String get bpmUnknown => 'BPM inconnu';

  @override
  String get genericError => 'Erreur';

  @override
  String get partyTagline =>
      'Ton téléphone est le DJ. L’enceinte n’est qu’une enceinte.';

  @override
  String get partyIntro =>
      'Les invités scannent le QR code, cherchent et votent dans leur navigateur – sans appli ni compte. La file reste chez toi, le son part en AirPlay ou Bluetooth.';

  @override
  String get partyNameLabel => 'Nom de la soirée';

  @override
  String get startParty => 'LANCER LA SOIRÉE';

  @override
  String get back => 'RETOUR';

  @override
  String get qrForGuests => 'QR pour les invités';

  @override
  String get endParty => 'Terminer la soirée';

  @override
  String get endPartyQuestion => 'Terminer la soirée ?';

  @override
  String get endPartyWarning =>
      'Les invités seront déconnectés et la file sera effacée.';

  @override
  String get no => 'NON';

  @override
  String get endAction => 'TERMINER';

  @override
  String get tabQueue => 'FILE';

  @override
  String get tabGuests => 'INVITÉS';

  @override
  String get tabSearch => 'RECHERCHE';

  @override
  String get copyLink => 'COPIER LE LIEN';

  @override
  String get queueEmpty => 'La file est vide';

  @override
  String get readyPressPlay => 'Prêt – appuie sur ▶';

  @override
  String addedBy(String name) {
    return 'ajouté par $name';
  }

  @override
  String get keepGoing => 'NON-STOP';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Les morceaux hors plage restent dans la file mais ne se lancent pas seuls.';

  @override
  String get turnOff => 'DÉSACTIVER';

  @override
  String get lockAction => 'VERROUILLER';

  @override
  String get queueEmptyHint =>
      'Rien pour l’instant. Ajoute un morceau ou montre le QR code aux invités.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Veto';

  @override
  String get playNow => 'Jouer maintenant';

  @override
  String get playNext => 'Jouer ensuite';

  @override
  String get unpin => 'Désépingler';

  @override
  String get noGuestsYet => 'Personne n’est encore arrivé';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · vote ×$weight, peut mettre son veto';
  }

  @override
  String get guestRole => 'invité';

  @override
  String get removeCoDj => 'Retirer co-DJ';

  @override
  String get promoteCoDj => 'Promouvoir co-DJ';

  @override
  String get blockGuest => 'Bloquer';

  @override
  String get searchSoundCloudHint => 'Rechercher sur SoundCloud…';

  @override
  String trackAdded(String title) {
    return '« $title » ajouté';
  }

  @override
  String get playlistSearchHint => 'Artiste ou Artiste - Titre...';

  @override
  String get playlistIdle => 'Saisis un groupe ou un titre';

  @override
  String searchingFor(String query) {
    return 'Recherche de « $query »…';
  }

  @override
  String get similarByBpm => 'Similaires (triés par BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get toastNoNextTrack =>
      'Aucun autre morceau trouvé – ajoutes-en un à la file';

  @override
  String get toastPickingNext => 'Choix du morceau suivant…';

  @override
  String toastCannotPlay(String title) {
    return 'Impossible de lire « $title » – on passe';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relais indisponible : $error';
  }
}
