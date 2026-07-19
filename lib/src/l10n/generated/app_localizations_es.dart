// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chronus';

  @override
  String get navProjects => 'Proyectos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get projectsEmpty => 'Aún no hay proyectos. Crea el primero.';

  @override
  String get projectsNewTitle => 'Nuevo proyecto';

  @override
  String get projectNameLabel => 'Nombre del proyecto';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionCreate => 'Crear';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsAnalyst => 'Analista predeterminado';

  @override
  String get settingsAnalystEmpty => 'Sin definir';

  @override
  String get settingsUnit => 'Unidad de tiempo';

  @override
  String get settingsUnitSeconds => 'Segundos';

  @override
  String get settingsUnitDecimalMinutes => 'Minutos decimales';

  @override
  String get actionSave => 'Guardar';
}
