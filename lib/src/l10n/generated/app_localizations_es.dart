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

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get projectEditTitle => 'Editar proyecto';

  @override
  String get projectNotesLabel => 'Notas';

  @override
  String get deleteProjectTitle => 'Eliminar proyecto';

  @override
  String deleteProjectMessage(String name) {
    return '¿Eliminar $name y todos sus estudios? Esto no se puede deshacer.';
  }

  @override
  String get studiesSectionTitle => 'Estudios';

  @override
  String get studiesEmpty => 'Aún no hay estudios. Crea el primero.';

  @override
  String get studyNewTitle => 'Nuevo estudio';

  @override
  String get studyNameLabel => 'Nombre del estudio';

  @override
  String get studyTypeLabel => 'Tipo de estudio';

  @override
  String get studyTypeTime => 'Estudio de Tiempo';

  @override
  String get studyTypeSampling => 'Estudio por Muestreo';

  @override
  String get deleteStudyTitle => 'Eliminar estudio';

  @override
  String deleteStudyMessage(String name) {
    return '¿Eliminar $name? Esto no se puede deshacer.';
  }

  @override
  String get studyFieldType => 'Tipo';

  @override
  String get studyFieldDate => 'Fecha';

  @override
  String get studyFieldAnalyst => 'Analista';

  @override
  String get studyOperationsSection => 'Operaciones';

  @override
  String get studyOperationsPending =>
      'Las operaciones se agregan al construir la secuencia.';
}
