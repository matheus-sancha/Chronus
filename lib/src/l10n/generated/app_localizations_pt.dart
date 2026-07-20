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
  String get studyFieldAllowance => 'Tolerância %';

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
  String get studyAllowanceHelp =>
      'Tempo extra para fadiga, esperas e necessidades pessoais. Tempo padrão = Tempo normal × (1 + Tolerância %).';

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
  String timedProgress(int done, int total) {
    return '$done / $total cronometradas';
  }

  @override
  String get colOperation => 'Operação';

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
}
