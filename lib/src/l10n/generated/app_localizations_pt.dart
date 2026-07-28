// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Chronus';

  @override
  String get navProjects => 'Projetos';

  @override
  String get navSettings => 'Configurações';

  @override
  String get projectsEmpty => 'Nenhum projeto ainda. Crie o primeiro.';

  @override
  String get projectsNewTitle => 'Novo projeto';

  @override
  String get projectNameLabel => 'Nome do projeto';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionCreate => 'Criar';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

  @override
  String get settingsAnalyst => 'Analista padrão';

  @override
  String get settingsAnalystEmpty => 'Não definido';

  @override
  String get settingsUnit => 'Unidade de tempo';

  @override
  String get settingsUnitSeconds => 'Segundos';

  @override
  String get settingsUnitDecimalMinutes => 'Minutos decimais';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get projectEditTitle => 'Editar projeto';

  @override
  String get projectNotesLabel => 'Observações';

  @override
  String get deleteProjectTitle => 'Excluir projeto';

  @override
  String deleteProjectMessage(String name) {
    return 'Excluir $name e todos os seus estudos? Isso não pode ser desfeito.';
  }

  @override
  String get studiesSectionTitle => 'Estudos';

  @override
  String get studiesEmpty => 'Nenhum estudo ainda. Crie o primeiro.';

  @override
  String get studyNewTitle => 'Novo estudo';

  @override
  String get studyNameLabel => 'Nome do estudo';

  @override
  String get studyTypeLabel => 'Tipo de estudo';

  @override
  String get studyTypeTime => 'Estudo de Tempo';

  @override
  String get studyTypeSampling => 'Estudo por Amostragem';

  @override
  String get deleteStudyTitle => 'Excluir estudo';

  @override
  String deleteStudyMessage(String name) {
    return 'Excluir $name? Isso não pode ser desfeito.';
  }

  @override
  String get studyFieldType => 'Tipo';

  @override
  String get studyFieldDate => 'Data';

  @override
  String get studyFieldAnalyst => 'Analista';

  @override
  String get studyOperationsSection => 'Operações';

  @override
  String get studyOperationsPending =>
      'As operações são adicionadas ao montar a sequência.';

  @override
  String get studyEditTitle => 'Editar estudo';

  @override
  String get studyDetailsSection => 'Detalhes';

  @override
  String get studyFieldProcessType => 'Tipo de processo';

  @override
  String get studyFieldPartProduct => 'Peça / Produto';

  @override
  String get studyFieldProcessOperation => 'Processo / Operação';

  @override
  String get studyFieldMachine => 'Máquina / Posto';

  @override
  String get studyFieldLineCell => 'Linha / Célula';

  @override
  String get studyFieldOperator => 'Operador';

  @override
  String get studyFieldShift => 'Turno';

  @override
  String get studyFieldWorkOrder => 'Ordem de produção';

  @override
  String get studyFieldNotes => 'Observações';

  @override
  String get processTypeNone => 'Nenhum';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get catalogEmpty => 'Nenhuma operação ainda. Adicione a primeira.';

  @override
  String get catalogNewTitle => 'Nova operação';

  @override
  String get catalogEditTitle => 'Editar operação';

  @override
  String get operationNameLabel => 'Nome da operação';

  @override
  String get operationCategoryLabel => 'Tipo';

  @override
  String get operationSubtypeLabel => 'Subtipo';

  @override
  String get operationReferenceStandardLabel => 'Tempo padrão de referência';

  @override
  String get subtypeNewTitle => 'Novo subtipo';

  @override
  String get subtypeNameLabel => 'Nome do subtipo';

  @override
  String get deleteOperationTitle => 'Excluir operação';

  @override
  String deleteOperationMessage(String name) {
    return 'Excluir $name? Isso não pode ser desfeito.';
  }

  @override
  String get categorySetup => 'Preparação';

  @override
  String get categoryProductive => 'Produtivo';

  @override
  String get categoryUnproductive => 'Improdutivo';

  @override
  String get wasteWaiting => 'Espera';

  @override
  String get wasteMotion => 'Movimentação';

  @override
  String get wasteTransportation => 'Transporte';

  @override
  String get wasteOverProcessing => 'Superprocessamento';

  @override
  String get wasteOverproduction => 'Superprodução';

  @override
  String get wasteInventory => 'Estoque';

  @override
  String get wasteDefects => 'Defeitos';

  @override
  String get sequenceEmpty =>
      'Nenhuma operação ainda. Adicione a partir do catálogo.';

  @override
  String get addOperationTitle => 'Adicionar operação';

  @override
  String get catalogPickerEmpty =>
      'Seu catálogo está vazio. Adicione operações na aba Catálogo primeiro.';

  @override
  String get customOperationTitle => 'Operação personalizada';

  @override
  String get filterAll => 'Todos';

  @override
  String get navTemplates => 'Modelos';

  @override
  String get templatesEmpty => 'Nenhum modelo ainda. Crie o primeiro.';

  @override
  String get templateNewTitle => 'Novo modelo';

  @override
  String get templateEditTitle => 'Editar modelo';

  @override
  String get templateNameLabel => 'Nome do modelo';

  @override
  String get templateDefaultType => 'Tipo de estudo padrão';

  @override
  String get deleteTemplateTitle => 'Excluir modelo';

  @override
  String deleteTemplateMessage(String name) {
    return 'Excluir $name? Isso não pode ser desfeito.';
  }

  @override
  String get createStudyAction => 'Criar estudo';

  @override
  String get instantiateTitle => 'Criar estudo a partir do modelo';

  @override
  String get fieldProject => 'Projeto';

  @override
  String get instantiateNoProjects => 'Crie um projeto primeiro.';

  @override
  String get templateStudyCreated => 'Estudo criado.';

  @override
  String get saveAsTemplateAction => 'Salvar como modelo';

  @override
  String get searchHint => 'Buscar operações';

  @override
  String get timingTitle => 'Cronometragem';

  @override
  String get timingStart => 'Iniciar cronometragem';

  @override
  String get timingContinue => 'Continuar cronometragem';

  @override
  String get timingView => 'Ver cronometragem';

  @override
  String timingLapNext(String name) {
    return 'Encerrar e iniciar:\n$name';
  }

  @override
  String get timingLapFinal => 'Encerrar operação final';

  @override
  String get timingUnplanned => 'Não planejada';

  @override
  String get timingUnplannedTag => 'não planejada';

  @override
  String get timingFinish => 'Finalizar';

  @override
  String get timingInsertUnplannedTitle => 'Inserir operação não planejada';

  @override
  String get timingComplete => 'Estudo concluído';

  @override
  String get timingTotalTime => 'Tempo total';

  @override
  String get timingValueAddedRatio => 'Índice de valor agregado';

  @override
  String get timingDiscard => 'Descartar cronometragem';

  @override
  String get timingDiscardTitle => 'Descartar cronometragem';

  @override
  String get timingDiscardMessage =>
      'Excluir todos os tempos registrados deste estudo? Isso não pode ser desfeito.';

  @override
  String get timingNoOperations => 'Adicione operações antes de cronometrar.';

  @override
  String get timingNoSegments => 'Nenhuma operação registrada ainda.';

  @override
  String get workspaceTotalLabel => 'Total';

  @override
  String workspaceExpectedCoverage(int withReference, int total) {
    return '$withReference de $total operações';
  }

  @override
  String get settingsAlertSounds => 'Alertas sonoros';

  @override
  String get settingsAlertSoundsSubtitle =>
      'Tocar um som quando uma operação se aproxima ou ultrapassa o tempo previsto';

  @override
  String timedProgress(int done, int total) {
    return '$done / $total cronometradas';
  }

  @override
  String get colOperation => 'Nome da operação';

  @override
  String get colExpected => 'Previsto';

  @override
  String get colActual => 'Real';

  @override
  String get tooltipStart => 'Iniciar';

  @override
  String get tooltipResume => 'Retomar';

  @override
  String get tooltipPause => 'Pausar';

  @override
  String get tooltipStop => 'Parar';

  @override
  String get tooltipStopNext => 'Parar e iniciar próxima';

  @override
  String get tooltipReset => 'Zerar';

  @override
  String get resetConfirmTitle => 'Zerar operação';

  @override
  String resetConfirmMessage(String name) {
    return 'Descartar o tempo medido de $name?';
  }

  @override
  String get interruptionTitle => 'Operação pausada';

  @override
  String get interruptionMessage =>
      'Registrar esta interrupção como uma operação improdutiva?';

  @override
  String get interruptionLog => 'Registrar interrupção';

  @override
  String get interruptionSkip => 'Agora não';

  @override
  String get manualTimeTitle => 'Informar tempo real';

  @override
  String get manualClear => 'Remover ajuste manual';

  @override
  String get manualBadge => 'manual';

  @override
  String get actionDuplicate => 'Duplicar';

  @override
  String get noteAction => 'Nota';

  @override
  String get noteDialogTitle => 'Nota da operação';

  @override
  String get noteHint => 'Comentários sobre esta operação';

  @override
  String get photosAction => 'Fotos';

  @override
  String get photosEmpty => 'Nenhuma foto ainda.';

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get addPhotoCamera => 'Tirar foto';

  @override
  String get addPhotoLibrary => 'Escolher da galeria';

  @override
  String get captionLabel => 'Legenda';

  @override
  String get deletePhotoTitle => 'Excluir foto';

  @override
  String get deletePhotoMessage =>
      'Excluir esta foto? Isso não pode ser desfeito.';

  @override
  String get reportTitle => 'Relatório';

  @override
  String get reportTotalElapsed => 'Tempo decorrido';

  @override
  String get reportWorkContent => 'Conteúdo de trabalho';

  @override
  String get reportSimultaneous => 'Simultâneo';

  @override
  String get reportUnattributed => 'Não atribuído';

  @override
  String get timelineNotMeasured => 'não medido';

  @override
  String get timelineRelativeAxis =>
      'Sequência — sem cronometragem ao vivo, tempos relativos';

  @override
  String get reportEfficiency => 'Eficiência (%)';

  @override
  String get reportRollupTitle => 'Distribuição por categoria';

  @override
  String get reportTimelineTitle => 'Linha do tempo';

  @override
  String get reportParetoTitle => 'Pareto de desperdícios';

  @override
  String get colStart => 'Início';

  @override
  String get colEnd => 'Fim';

  @override
  String get colObserved => 'Tempo observado';

  @override
  String get colReference => 'Tempo de referência';

  @override
  String get colNotes => 'Notas';

  @override
  String get colImages => 'Imagens';

  @override
  String get reportEmpty => 'Cronometre operações para ver o relatório.';

  @override
  String get wasteUnlabeled => 'Sem subtipo';

  @override
  String get settingsDataSection => 'Dados';

  @override
  String get backupAction => 'Fazer backup';

  @override
  String get backupSubtitle => 'Salvar tudo em um arquivo .chronus';

  @override
  String get backupDone => 'Backup salvo.';

  @override
  String get restoreAction => 'Restaurar';

  @override
  String get restoreSubtitle =>
      'Substituir todos os dados de um arquivo .chronus';

  @override
  String get restoreConfirmTitle => 'Restaurar do backup?';

  @override
  String get restoreConfirmMessage =>
      'Isso substitui todos os projetos, estudos e fotos atualmente no Chronus. Não pode ser desfeito — faça um backup antes se tiver dúvida.';

  @override
  String restoreDone(String date) {
    return 'Backup de $date restaurado.';
  }

  @override
  String get restoreErrorNotBundle =>
      'Esse arquivo não é um backup do Chronus.';

  @override
  String get restoreErrorDamaged =>
      'Esse backup está incompleto ou corrompido; nada foi alterado.';

  @override
  String get restoreErrorTooNew =>
      'Esse backup foi criado por uma versão mais recente do Chronus. Atualize o app e tente novamente.';

  @override
  String get exportAction => 'Exportar';

  @override
  String get exportPdf => 'PDF — relatório';

  @override
  String get exportXlsx => 'Excel — dados';

  @override
  String get exportInProgress => 'Preparando exportação…';

  @override
  String get exportDone => 'Exportação pronta.';

  @override
  String exportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String get actionClose => 'Fechar';

  @override
  String get shortcutsTitle => 'Atalhos de teclado';

  @override
  String get shortcutsTooltip => 'Atalhos de teclado (F1)';

  @override
  String get shortcutsKeySpace => 'Espaço';

  @override
  String get shortcutsKeyArrows => '↑ ↓';

  @override
  String get shortcutsKeyEnter => 'Enter';

  @override
  String get shortcutsKeyS => 'S';

  @override
  String get shortcutsKeyEsc => 'Esc';

  @override
  String get shortcutsLap =>
      'Para a operação que está rodando e inicia a próxima, sem intervalo entre as duas. Se nada estiver rodando, inicia a primeira operação ainda não cronometrada.';

  @override
  String get shortcutsMove => 'Escolher a linha.';

  @override
  String get shortcutsToggle => 'Iniciar ou pausar a linha escolhida.';

  @override
  String get shortcutsStop => 'Parar a linha escolhida.';

  @override
  String get shortcutsClear => 'Desmarcar a linha escolhida.';

  @override
  String get shortcutsConcurrencyNote =>
      'Com duas ou mais operações rodando ao mesmo tempo, o Espaço não faz nada: qual delas é a “atual” fica realmente ambíguo, e parar o cronômetro do operador errado estragaria a medição. Escolha a linha e aperte Enter.';

  @override
  String get lapAmbiguous =>
      'Várias operações rodando — escolha a linha e aperte Enter.';

  @override
  String get lapNothingToStart => 'Não há mais nada para iniciar.';

  @override
  String get snapshotsTitle => 'Cópias automáticas';

  @override
  String get snapshotsSubtitle =>
      'Feitas sozinhas, uma por dia. Só estudos e projetos — as fotos não entram, e não são alteradas por uma restauração.';

  @override
  String get snapshotRestoreConfirmTitle => 'Restaurar esta cópia?';

  @override
  String snapshotRestoreConfirmMessage(String date) {
    return 'Isso substitui todos os projetos e estudos pelos de $date. As fotos ficam como estão. Não pode ser desfeito.';
  }

  @override
  String snapshotRestoreDone(String date) {
    return 'Cópia de $date restaurada.';
  }

  @override
  String get orphanedTimingTitle => 'Cronômetros deixados rodando';

  @override
  String orphanedTimingMessage(int count, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operações estão contando',
      one: '1 operação está contando',
    );
    return '$_temp0 desde $since, porque o Chronus foi fechado sem parar o cronômetro. Esse tempo nunca foi encerrado, então não pode ser medido.';
  }

  @override
  String get orphanedTimingKeep => 'Continuar contando';

  @override
  String get orphanedTimingDiscard => 'Descartar esse tempo';

  @override
  String get settingsDiagnosticsSection => 'Diagnóstico';

  @override
  String get diagnosticsBuild => 'Versão';

  @override
  String get diagnosticsSave => 'Salvar diagnóstico';

  @override
  String get diagnosticsSaveSubtitle =>
      'Um arquivo de texto com o histórico do app, para enviar';

  @override
  String get diagnosticsSaved => 'Diagnóstico salvo.';

  @override
  String get diagnosticsOpenFolder => 'Abrir pasta de dados';

  @override
  String get diagnosticsOpenFolderSubtitle =>
      'Onde ficam o banco de dados, as fotos e os backups';

  @override
  String diagnosticsFolderFailed(String error) {
    return 'Não foi possível abrir a pasta: $error';
  }

  @override
  String get feedbackAction => 'Enviar feedback';

  @override
  String get feedbackSubtitle =>
      'Anote o que atrapalhou; vai junto com o diagnóstico';

  @override
  String get feedbackHint => 'O que aconteceu?';

  @override
  String get feedbackSaved =>
      'Anotado. Vai junto quando você salvar o diagnóstico.';

  @override
  String get passesTitle => 'Tomadas';

  @override
  String passLabel(int number) {
    return 'Tomada $number';
  }

  @override
  String get passAdd => 'Nova tomada';

  @override
  String passTimedCount(int timed, int total) {
    return '$timed de $total cronometradas';
  }

  @override
  String get passNothingTimed => 'Nada cronometrado ainda';

  @override
  String get passExcludedBadge => 'Excluída';

  @override
  String get passExclude => 'Excluir das estatísticas';

  @override
  String get passInclude => 'Voltar para as estatísticas';

  @override
  String passExcludeTitle(String pass) {
    return 'Excluir a $pass?';
  }

  @override
  String get passExcludeMessage =>
      'Ela mantém as medições e o relatório próprio — só fica de fora das médias. Você pode voltar atrás quando quiser.';

  @override
  String get passExcludeReasonHint =>
      'Por quê? (ex.: linha parada por falta de material)';

  @override
  String get passDelete => 'Excluir tomada';

  @override
  String get passDeleteBlocked =>
      'Esta tomada tem medições. Prefira excluí-la das estatísticas — assim a evidência fica registrada.';

  @override
  String get passDeleteLastBlocked => 'Um estudo mantém pelo menos uma tomada.';

  @override
  String passDeleteConfirmTitle(String pass) {
    return 'Apagar a $pass?';
  }

  @override
  String get passDeleteConfirmMessage =>
      'Nada foi cronometrado nela. O número não será reaproveitado.';

  @override
  String get passReport => 'Relatório desta tomada';

  @override
  String get samplingReportTitle => 'Relatório de amostragem';

  @override
  String get samplingReportEmpty =>
      'Cronometre uma operação em ao menos uma tomada para ver o relatório.';

  @override
  String samplingCriteria(String confidence, String precision) {
    return '$confidence% de confiança · ±$precision%';
  }

  @override
  String samplingPassesTaken(int taken) {
    return '$taken tomadas realizadas';
  }

  @override
  String samplingAdequate(int required) {
    return 'Adequado — $required necessárias';
  }

  @override
  String samplingNotAdequate(int shortfall) {
    return 'Não adequado — faltam $shortfall tomadas';
  }

  @override
  String get samplingNotDeterminable =>
      'Ainda não há tomadas suficientes para julgar';

  @override
  String get samplingNothingTimed => 'Nada cronometrado ainda';

  @override
  String samplingGovernedBy(String operation) {
    return 'Determinado por: $operation';
  }

  @override
  String samplingNeverTimed(String operations) {
    return 'Nunca cronometradas: $operations';
  }

  @override
  String get samplingStatisticsTitle => 'Estatísticas por operação';

  @override
  String get samplingReadingsTitle => 'Leituras';

  @override
  String get samplingMean => 'Média';

  @override
  String get samplingRange => 'Amplitude';

  @override
  String get samplingStdDev => 'Desvio padrão';

  @override
  String get samplingCv => 'CV';

  @override
  String get samplingRequired => 'Necessárias';

  @override
  String get samplingCount => 'n';

  @override
  String get samplingUnplannedNote =>
      'Não planejada — aparece, mas não entra no veredito';

  @override
  String samplingExcludedNote(int count) {
    return '$count leituras excluídas';
  }

  @override
  String samplingManualNote(int count) {
    return '$count digitadas';
  }

  @override
  String get samplingMeanWorkContent => 'Conteúdo de trabalho (tomada média)';

  @override
  String get readingExclude => 'Excluir esta leitura';

  @override
  String get readingInclude => 'Voltar com esta leitura';

  @override
  String readingExcludeTitle(String operation, int pass) {
    return 'Excluir $operation, tomada $pass?';
  }

  @override
  String get readingExcludeMessage =>
      'A medição continua registrada e ainda aparece no relatório da própria tomada. Ela só fica de fora das médias.';

  @override
  String get readingExcludedByPass => 'Excluída junto com a tomada inteira.';

  @override
  String get studyCriteriaSection => 'Tamanho da amostra';

  @override
  String get studyConfidenceLevel => 'Nível de confiança';

  @override
  String get studyRelativePrecision => 'Precisão (± % da média)';
}
