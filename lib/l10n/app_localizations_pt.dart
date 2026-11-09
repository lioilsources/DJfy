// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String partyBarStatus(String title, int count) {
    return '$title · fila: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Festa $code';
  }

  @override
  String get addDeck => 'ADICIONAR DECK';

  @override
  String get deckDropHint => 'Arraste uma faixa para cá';

  @override
  String get deckWaitingForQueue => 'Aguardando a fila';

  @override
  String get dspUnavailable => 'DSP indisponível (stream HLS)';

  @override
  String get bpmUnknown => 'BPM desconhecido';

  @override
  String get genericError => 'Erro';

  @override
  String get partyTagline =>
      'Seu celular é o DJ. A caixa de som é só uma caixa de som.';

  @override
  String get partyIntro =>
      'Os convidados escaneiam o QR, buscam e votam no navegador – sem app e sem conta. A fila fica com você, e o som vai por AirPlay ou Bluetooth.';

  @override
  String get partyNameLabel => 'Nome da festa';

  @override
  String get startParty => 'CRIAR FESTA';

  @override
  String get back => 'VOLTAR';

  @override
  String get qrForGuests => 'QR para convidados';

  @override
  String get endParty => 'Encerrar festa';

  @override
  String get endPartyQuestion => 'Encerrar a festa?';

  @override
  String get endPartyWarning =>
      'Os convidados serão desconectados e a fila será apagada.';

  @override
  String get no => 'NÃO';

  @override
  String get endAction => 'ENCERRAR';

  @override
  String get tabQueue => 'FILA';

  @override
  String get tabGuests => 'CONVIDADOS';

  @override
  String get tabSearch => 'BUSCAR';

  @override
  String get copyLink => 'COPIAR LINK';

  @override
  String get queueEmpty => 'A fila está vazia';

  @override
  String get readyPressPlay => 'Pronto – toque em ▶';

  @override
  String addedBy(String name) {
    return 'adicionada por $name';
  }

  @override
  String get keepGoing => 'SEM PARAR';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Faixas fora do intervalo ficam na fila, mas não tocam sozinhas.';

  @override
  String get turnOff => 'DESLIGAR';

  @override
  String get lockAction => 'TRAVAR';

  @override
  String get queueEmptyHint =>
      'Nada ainda. Adicione uma faixa ou mostre o QR aos convidados.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Vetar';

  @override
  String get playNow => 'Tocar agora';

  @override
  String get playNext => 'Tocar em seguida';

  @override
  String get unpin => 'Desafixar';

  @override
  String get noGuestsYet => 'Ninguém chegou ainda';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · voto ×$weight, pode vetar';
  }

  @override
  String get guestRole => 'convidado';

  @override
  String get removeCoDj => 'Remover co-DJ';

  @override
  String get promoteCoDj => 'Promover a co-DJ';

  @override
  String get blockGuest => 'Bloquear';

  @override
  String get searchSoundCloudHint => 'Buscar no SoundCloud…';

  @override
  String trackAdded(String title) {
    return '“$title” adicionada';
  }

  @override
  String get playlistSearchHint => 'Artista ou Artista - Música...';

  @override
  String get playlistIdle => 'Digite uma banda ou música';

  @override
  String searchingFor(String query) {
    return 'Buscando “$query”…';
  }

  @override
  String get similarByBpm => 'Parecidas (ordenadas por BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Não encontrei outra faixa – adicione alguma à fila';

  @override
  String get toastPickingNext => 'Escolhendo a próxima faixa…';

  @override
  String toastCannotPlay(String title) {
    return 'Não dá para tocar “$title” – pulando';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay indisponível: $error';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String partyBarStatus(String title, int count) {
    return '$title · fila: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Festa $code';
  }

  @override
  String get addDeck => 'ADICIONAR DECK';

  @override
  String get deckDropHint => 'Arraste uma faixa para cá';

  @override
  String get deckWaitingForQueue => 'Aguardando a fila';

  @override
  String get dspUnavailable => 'DSP indisponível (stream HLS)';

  @override
  String get bpmUnknown => 'BPM desconhecido';

  @override
  String get genericError => 'Erro';

  @override
  String get partyTagline =>
      'Seu celular é o DJ. A caixa de som é só uma caixa de som.';

  @override
  String get partyIntro =>
      'Os convidados escaneiam o QR, buscam e votam no navegador – sem app e sem conta. A fila fica com você, e o som vai por AirPlay ou Bluetooth.';

  @override
  String get partyNameLabel => 'Nome da festa';

  @override
  String get startParty => 'CRIAR FESTA';

  @override
  String get back => 'VOLTAR';

  @override
  String get qrForGuests => 'QR para convidados';

  @override
  String get endParty => 'Encerrar festa';

  @override
  String get endPartyQuestion => 'Encerrar a festa?';

  @override
  String get endPartyWarning =>
      'Os convidados serão desconectados e a fila será apagada.';

  @override
  String get no => 'NÃO';

  @override
  String get endAction => 'ENCERRAR';

  @override
  String get tabQueue => 'FILA';

  @override
  String get tabGuests => 'CONVIDADOS';

  @override
  String get tabSearch => 'BUSCAR';

  @override
  String get copyLink => 'COPIAR LINK';

  @override
  String get queueEmpty => 'A fila está vazia';

  @override
  String get readyPressPlay => 'Pronto – toque em ▶';

  @override
  String addedBy(String name) {
    return 'adicionada por $name';
  }

  @override
  String get keepGoing => 'SEM PARAR';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'Faixas fora do intervalo ficam na fila, mas não tocam sozinhas.';

  @override
  String get turnOff => 'DESLIGAR';

  @override
  String get lockAction => 'TRAVAR';

  @override
  String get queueEmptyHint =>
      'Nada ainda. Adicione uma faixa ou mostre o QR aos convidados.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Vetar';

  @override
  String get playNow => 'Tocar agora';

  @override
  String get playNext => 'Tocar em seguida';

  @override
  String get unpin => 'Desafixar';

  @override
  String get noGuestsYet => 'Ninguém chegou ainda';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · voto ×$weight, pode vetar';
  }

  @override
  String get guestRole => 'convidado';

  @override
  String get removeCoDj => 'Remover co-DJ';

  @override
  String get promoteCoDj => 'Promover a co-DJ';

  @override
  String get blockGuest => 'Bloquear';

  @override
  String get searchSoundCloudHint => 'Buscar no SoundCloud…';

  @override
  String trackAdded(String title) {
    return '“$title” adicionada';
  }

  @override
  String get playlistSearchHint => 'Artista ou Artista - Música...';

  @override
  String get playlistIdle => 'Digite uma banda ou música';

  @override
  String searchingFor(String query) {
    return 'Buscando “$query”…';
  }

  @override
  String get similarByBpm => 'Parecidas (ordenadas por BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Não encontrei outra faixa – adicione alguma à fila';

  @override
  String get toastPickingNext => 'Escolhendo a próxima faixa…';

  @override
  String toastCannotPlay(String title) {
    return 'Não dá para tocar “$title” – pulando';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay indisponível: $error';
  }
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String partyBarStatus(String title, int count) {
    return '$title · fila: $count';
  }

  @override
  String partyWithCode(String code) {
    return 'Festa $code';
  }

  @override
  String get addDeck => 'ADICIONAR DECK';

  @override
  String get deckDropHint => 'Arrasta uma faixa para aqui';

  @override
  String get deckWaitingForQueue => 'À espera da fila';

  @override
  String get dspUnavailable => 'DSP indisponível (stream HLS)';

  @override
  String get bpmUnknown => 'BPM desconhecido';

  @override
  String get genericError => 'Erro';

  @override
  String get partyTagline =>
      'O teu telemóvel é o DJ. A coluna é só uma coluna.';

  @override
  String get partyIntro =>
      'Os convidados leem o QR, pesquisam e votam no browser – sem app e sem conta. A fila fica contigo e o som segue por AirPlay ou Bluetooth.';

  @override
  String get partyNameLabel => 'Nome da festa';

  @override
  String get startParty => 'CRIAR FESTA';

  @override
  String get back => 'VOLTAR';

  @override
  String get qrForGuests => 'QR para convidados';

  @override
  String get endParty => 'Terminar festa';

  @override
  String get endPartyQuestion => 'Terminar a festa?';

  @override
  String get endPartyWarning =>
      'Os convidados serão desligados e a fila será apagada.';

  @override
  String get no => 'NÃO';

  @override
  String get endAction => 'TERMINAR';

  @override
  String get tabQueue => 'FILA';

  @override
  String get tabGuests => 'CONVIDADOS';

  @override
  String get tabSearch => 'PESQUISAR';

  @override
  String get copyLink => 'COPIAR LIGAÇÃO';

  @override
  String get queueEmpty => 'A fila está vazia';

  @override
  String get readyPressPlay => 'Pronto – carrega em ▶';

  @override
  String addedBy(String name) {
    return 'adicionada por $name';
  }

  @override
  String get keepGoing => 'SEM PARAR';

  @override
  String get moodLock => 'Mood lock';

  @override
  String get moodLockHint =>
      'As faixas fora do intervalo ficam na fila, mas não tocam sozinhas.';

  @override
  String get turnOff => 'DESLIGAR';

  @override
  String get lockAction => 'BLOQUEAR';

  @override
  String get queueEmptyHint =>
      'Ainda nada. Adiciona uma faixa ou mostra o QR aos convidados.';

  @override
  String get vetoBadge => 'VETO';

  @override
  String get vetoMenu => 'Vetar';

  @override
  String get playNow => 'Tocar agora';

  @override
  String get playNext => 'Tocar a seguir';

  @override
  String get unpin => 'Desafixar';

  @override
  String get noGuestsYet => 'Ainda não chegou ninguém';

  @override
  String coDjSubtitle(int weight) {
    return 'co-DJ · voto ×$weight, pode vetar';
  }

  @override
  String get guestRole => 'convidado';

  @override
  String get removeCoDj => 'Remover co-DJ';

  @override
  String get promoteCoDj => 'Promover a co-DJ';

  @override
  String get blockGuest => 'Bloquear';

  @override
  String get searchSoundCloudHint => 'Pesquisar no SoundCloud…';

  @override
  String trackAdded(String title) {
    return '«$title» adicionada';
  }

  @override
  String get playlistSearchHint => 'Artista ou Artista - Música...';

  @override
  String get playlistIdle => 'Escreve uma banda ou uma música';

  @override
  String searchingFor(String query) {
    return 'A pesquisar «$query»…';
  }

  @override
  String get similarByBpm => 'Semelhantes (por BPM)';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get toastNoNextTrack =>
      'Não encontrei outra faixa – adiciona alguma à fila';

  @override
  String get toastPickingNext => 'A escolher a próxima faixa…';

  @override
  String toastCannotPlay(String title) {
    return 'Não é possível tocar «$title» – a saltar';
  }

  @override
  String relayUnavailable(String error) {
    return 'Relay indisponível: $error';
  }
}
