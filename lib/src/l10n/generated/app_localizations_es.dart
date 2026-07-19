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

  @override
  String get studyEditTitle => 'Editar estudio';

  @override
  String get studyDetailsSection => 'Detalles';

  @override
  String get studyFieldAllowance => 'Tolerancia %';

  @override
  String get studyFieldProcessType => 'Tipo de proceso';

  @override
  String get studyFieldPartProduct => 'Pieza / Producto';

  @override
  String get studyFieldProcessOperation => 'Proceso / Operación';

  @override
  String get studyFieldMachine => 'Máquina / Puesto';

  @override
  String get studyFieldLineCell => 'Línea / Celda';

  @override
  String get studyFieldOperator => 'Operador';

  @override
  String get studyFieldShift => 'Turno';

  @override
  String get studyFieldWorkOrder => 'Orden de trabajo';

  @override
  String get studyFieldNotes => 'Notas';

  @override
  String get processTypeNone => 'Ninguno';

  @override
  String get studyAllowanceHelp =>
      'Tiempo extra para fatiga, esperas y necesidades personales. Tiempo estándar = Tiempo normal × (1 + Tolerancia %).';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get catalogEmpty => 'Aún no hay operaciones. Agrega la primera.';

  @override
  String get catalogNewTitle => 'Nueva operación';

  @override
  String get catalogEditTitle => 'Editar operación';

  @override
  String get operationNameLabel => 'Nombre de la operación';

  @override
  String get operationCategoryLabel => 'Clasificación';

  @override
  String get operationSubtypeLabel => 'Subtipo';

  @override
  String get operationReferenceStandardLabel => 'Estándar de referencia (s)';

  @override
  String get subtypeNewTitle => 'Nuevo subtipo';

  @override
  String get subtypeNameLabel => 'Nombre del subtipo';

  @override
  String get deleteOperationTitle => 'Eliminar operación';

  @override
  String deleteOperationMessage(String name) {
    return '¿Eliminar $name? Esto no se puede deshacer.';
  }

  @override
  String get categorySetup => 'Preparación';

  @override
  String get categoryValueAdded => 'Valor Añadido';

  @override
  String get categoryWaste => 'Desperdicio';

  @override
  String get wasteWaiting => 'Espera';

  @override
  String get wasteMotion => 'Movimiento';

  @override
  String get wasteTransportation => 'Transporte';

  @override
  String get wasteOverProcessing => 'Sobreprocesamiento';

  @override
  String get wasteOverproduction => 'Sobreproducción';

  @override
  String get wasteInventory => 'Inventario';

  @override
  String get wasteDefects => 'Defectos';
}
