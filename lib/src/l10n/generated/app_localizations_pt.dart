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
}
