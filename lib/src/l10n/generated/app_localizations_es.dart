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
  String get operationCategoryLabel => 'Tipo';

  @override
  String get operationSubtypeLabel => 'Subtipo';

  @override
  String get operationReferenceStandardLabel => 'Tiempo estándar de referencia';

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
  String get categoryProductive => 'Productivo';

  @override
  String get categoryUnproductive => 'Improductivo';

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

  @override
  String get sequenceEmpty =>
      'Aún no hay operaciones. Agrégalas desde el catálogo.';

  @override
  String get addOperationTitle => 'Agregar operación';

  @override
  String get catalogPickerEmpty =>
      'Tu catálogo está vacío. Agrega operaciones en la pestaña Catálogo primero.';

  @override
  String get customOperationTitle => 'Operación personalizada';

  @override
  String get filterAll => 'Todos';

  @override
  String get navTemplates => 'Plantillas';

  @override
  String get templatesEmpty => 'Aún no hay plantillas. Crea la primera.';

  @override
  String get templateNewTitle => 'Nueva plantilla';

  @override
  String get templateEditTitle => 'Editar plantilla';

  @override
  String get templateNameLabel => 'Nombre de la plantilla';

  @override
  String get templateDefaultType => 'Tipo de estudio predeterminado';

  @override
  String get deleteTemplateTitle => 'Eliminar plantilla';

  @override
  String deleteTemplateMessage(String name) {
    return '¿Eliminar $name? Esto no se puede deshacer.';
  }

  @override
  String get createStudyAction => 'Crear estudio';

  @override
  String get instantiateTitle => 'Crear estudio desde la plantilla';

  @override
  String get fieldProject => 'Proyecto';

  @override
  String get instantiateNoProjects => 'Crea un proyecto primero.';

  @override
  String get templateStudyCreated => 'Estudio creado.';

  @override
  String get saveAsTemplateAction => 'Guardar como plantilla';

  @override
  String get searchHint => 'Buscar operaciones';

  @override
  String get timingTitle => 'Cronometraje';

  @override
  String get timingStart => 'Iniciar cronometraje';

  @override
  String get timingContinue => 'Continuar cronometraje';

  @override
  String get timingView => 'Ver cronometraje';

  @override
  String timingLapNext(String name) {
    return 'Terminar e iniciar:\n$name';
  }

  @override
  String get timingLapFinal => 'Terminar operación final';

  @override
  String get timingUnplanned => 'No planificada';

  @override
  String get timingUnplannedTag => 'no planificada';

  @override
  String get timingFinish => 'Finalizar';

  @override
  String get timingInsertUnplannedTitle => 'Insertar operación no planificada';

  @override
  String get timingComplete => 'Estudio completado';

  @override
  String get timingTotalTime => 'Tiempo total';

  @override
  String get timingValueAddedRatio => 'Índice de valor añadido';

  @override
  String get timingDiscard => 'Descartar cronometraje';

  @override
  String get timingDiscardTitle => 'Descartar cronometraje';

  @override
  String get timingDiscardMessage =>
      '¿Eliminar todos los tiempos registrados de este estudio? Esto no se puede deshacer.';

  @override
  String get timingNoOperations => 'Añade operaciones antes de cronometrar.';

  @override
  String get timingNoSegments => 'Aún no hay operaciones registradas.';

  @override
  String get workspaceTotalLabel => 'Total';

  @override
  String workspaceExpectedCoverage(int withReference, int total) {
    return '$withReference de $total operaciones';
  }

  @override
  String get settingsAlertSounds => 'Alertas sonoras';

  @override
  String get settingsAlertSoundsSubtitle =>
      'Reproducir un sonido cuando una operación se acerca o supera el tiempo previsto';

  @override
  String timedProgress(int done, int total) {
    return '$done / $total cronometradas';
  }

  @override
  String get colOperation => 'Nombre de la operación';

  @override
  String get colExpected => 'Previsto';

  @override
  String get colActual => 'Real';

  @override
  String get tooltipStart => 'Iniciar';

  @override
  String get tooltipResume => 'Reanudar';

  @override
  String get tooltipPause => 'Pausar';

  @override
  String get tooltipStop => 'Detener';

  @override
  String get tooltipStopNext => 'Detener e iniciar siguiente';

  @override
  String get tooltipReset => 'Reiniciar';

  @override
  String get resetConfirmTitle => 'Reiniciar operación';

  @override
  String resetConfirmMessage(String name) {
    return '¿Descartar el tiempo medido de $name?';
  }

  @override
  String get interruptionTitle => 'Operación pausada';

  @override
  String get interruptionMessage =>
      '¿Registrar esta interrupción como una operación no productiva?';

  @override
  String get interruptionLog => 'Registrar interrupción';

  @override
  String get interruptionSkip => 'Ahora no';

  @override
  String get manualTimeTitle => 'Introducir tiempo real';

  @override
  String get manualClear => 'Quitar ajuste manual';

  @override
  String get manualBadge => 'manual';

  @override
  String get actionDuplicate => 'Duplicar';

  @override
  String get noteAction => 'Nota';

  @override
  String get noteDialogTitle => 'Nota de la operación';

  @override
  String get noteHint => 'Comentarios sobre esta operación';

  @override
  String get photosAction => 'Fotos';

  @override
  String get photosEmpty => 'Aún no hay fotos.';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get addPhotoCamera => 'Tomar foto';

  @override
  String get addPhotoLibrary => 'Elegir de la galería';

  @override
  String get captionLabel => 'Leyenda';

  @override
  String get deletePhotoTitle => 'Eliminar foto';

  @override
  String get deletePhotoMessage =>
      '¿Eliminar esta foto? Esto no se puede deshacer.';

  @override
  String get reportTitle => 'Informe';

  @override
  String get reportTotalElapsed => 'Tiempo transcurrido';

  @override
  String get reportWorkContent => 'Contenido de trabajo';

  @override
  String get reportSimultaneous => 'Simultáneo';

  @override
  String get reportUnattributed => 'No atribuido';

  @override
  String get timelineNotMeasured => 'no medido';

  @override
  String get timelineRelativeAxis =>
      'Secuencia — sin cronometraje en vivo, tiempos relativos';

  @override
  String get reportEfficiency => 'Eficiencia (%)';

  @override
  String get reportRollupTitle => 'Distribución por categoría';

  @override
  String get reportTimelineTitle => 'Línea de tiempo';

  @override
  String get reportParetoTitle => 'Pareto de desperdicios';

  @override
  String get colStart => 'Inicio';

  @override
  String get colEnd => 'Fin';

  @override
  String get colObserved => 'Tiempo observado';

  @override
  String get colReference => 'Tiempo de referencia';

  @override
  String get colNotes => 'Notas';

  @override
  String get colImages => 'Imágenes';

  @override
  String get reportEmpty => 'Cronometra operaciones para ver el informe.';

  @override
  String get wasteUnlabeled => 'Sin subtipo';

  @override
  String get settingsDataSection => 'Datos';

  @override
  String get backupAction => 'Crear copia de seguridad';

  @override
  String get backupSubtitle => 'Guardar todo en un archivo .chronus';

  @override
  String get backupDone => 'Copia de seguridad guardada.';

  @override
  String get restoreAction => 'Restaurar';

  @override
  String get restoreSubtitle =>
      'Reemplazar todos los datos desde un archivo .chronus';

  @override
  String get restoreConfirmTitle => '¿Restaurar desde la copia de seguridad?';

  @override
  String get restoreConfirmMessage =>
      'Esto reemplaza todos los proyectos, estudios y fotos que hay en Chronus. No se puede deshacer: crea una copia antes si tienes dudas.';

  @override
  String restoreDone(String date) {
    return 'Copia de seguridad del $date restaurada.';
  }

  @override
  String get restoreErrorNotBundle =>
      'Ese archivo no es una copia de seguridad de Chronus.';

  @override
  String get restoreErrorDamaged =>
      'Esa copia de seguridad está incompleta o dañada; no se cambió nada.';

  @override
  String get restoreErrorTooNew =>
      'Esa copia de seguridad se creó con una versión más reciente de Chronus. Actualiza la app e inténtalo de nuevo.';

  @override
  String get exportAction => 'Exportar';

  @override
  String get exportPdf => 'PDF — informe';

  @override
  String get exportXlsx => 'Excel — datos';

  @override
  String get exportInProgress => 'Preparando la exportación…';

  @override
  String get exportDone => 'Exportación lista.';

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get snapshotsTitle => 'Copias automáticas';

  @override
  String get snapshotsSubtitle =>
      'Se hacen solas, una por día. Solo estudios y proyectos — las fotos no se incluyen, y una restauración no las modifica.';

  @override
  String get snapshotRestoreConfirmTitle => '¿Restaurar esta copia?';

  @override
  String snapshotRestoreConfirmMessage(String date) {
    return 'Esto reemplaza todos los proyectos y estudios por los del $date. Las fotos quedan como están. No se puede deshacer.';
  }

  @override
  String snapshotRestoreDone(String date) {
    return 'Copia del $date restaurada.';
  }

  @override
  String get orphanedTimingTitle => 'Cronómetros que quedaron activos';

  @override
  String orphanedTimingMessage(int count, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operaciones llevan contando',
      one: '1 operación lleva contando',
    );
    return '$_temp0 desde $since, porque Chronus se cerró sin detener el cronómetro. Ese tiempo nunca se cerró, así que no puede medirse.';
  }

  @override
  String get orphanedTimingKeep => 'Seguir contando';

  @override
  String get orphanedTimingDiscard => 'Descartar ese tiempo';

  @override
  String get settingsDiagnosticsSection => 'Diagnóstico';

  @override
  String get diagnosticsBuild => 'Versión';

  @override
  String get diagnosticsSave => 'Guardar diagnóstico';

  @override
  String get diagnosticsSaveSubtitle =>
      'Un archivo de texto con el historial de la app, para enviar';

  @override
  String get diagnosticsSaved => 'Diagnóstico guardado.';

  @override
  String get diagnosticsOpenFolder => 'Abrir carpeta de datos';

  @override
  String get diagnosticsOpenFolderSubtitle =>
      'Donde están la base de datos, las fotos y las copias';

  @override
  String diagnosticsFolderFailed(String error) {
    return 'No se pudo abrir la carpeta: $error';
  }

  @override
  String get feedbackAction => 'Enviar comentarios';

  @override
  String get feedbackSubtitle =>
      'Anota qué te estorbó; va junto con el diagnóstico';

  @override
  String get feedbackHint => '¿Qué pasó?';

  @override
  String get feedbackSaved =>
      'Anotado. Se envía junto al guardar el diagnóstico.';
}
