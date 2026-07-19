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
}
