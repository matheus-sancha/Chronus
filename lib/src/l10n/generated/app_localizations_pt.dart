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
  String get operationCategoryLabel => 'Classificação';

  @override
  String get operationSubtypeLabel => 'Subtipo';

  @override
  String get operationReferenceStandardLabel => 'Padrão de referência (s)';

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
  String get categoryValueAdded => 'Agrega Valor';

  @override
  String get categoryWaste => 'Desperdício';

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
}
