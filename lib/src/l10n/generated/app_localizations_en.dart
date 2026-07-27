// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chronus';

  @override
  String get navProjects => 'Projects';

  @override
  String get navSettings => 'Settings';

  @override
  String get projectsEmpty => 'No projects yet. Create your first one.';

  @override
  String get projectsNewTitle => 'New project';

  @override
  String get projectNameLabel => 'Project name';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionCreate => 'Create';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsAnalyst => 'Default analyst';

  @override
  String get settingsAnalystEmpty => 'Not set';

  @override
  String get settingsUnit => 'Time unit';

  @override
  String get settingsUnitSeconds => 'Seconds';

  @override
  String get settingsUnitDecimalMinutes => 'Decimal minutes';

  @override
  String get actionSave => 'Save';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get projectEditTitle => 'Edit project';

  @override
  String get projectNotesLabel => 'Notes';

  @override
  String get deleteProjectTitle => 'Delete project';

  @override
  String deleteProjectMessage(String name) {
    return 'Delete $name and all its studies? This cannot be undone.';
  }

  @override
  String get studiesSectionTitle => 'Studies';

  @override
  String get studiesEmpty => 'No studies yet. Create the first one.';

  @override
  String get studyNewTitle => 'New study';

  @override
  String get studyNameLabel => 'Study name';

  @override
  String get studyTypeLabel => 'Study type';

  @override
  String get studyTypeTime => 'Time Study';

  @override
  String get studyTypeSampling => 'Sampling Study';

  @override
  String get deleteStudyTitle => 'Delete study';

  @override
  String deleteStudyMessage(String name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get studyFieldType => 'Type';

  @override
  String get studyFieldDate => 'Date';

  @override
  String get studyFieldAnalyst => 'Analyst';

  @override
  String get studyOperationsSection => 'Operations';

  @override
  String get studyOperationsPending =>
      'Operations are added when you build the sequence.';

  @override
  String get studyEditTitle => 'Edit study';

  @override
  String get studyDetailsSection => 'Details';

  @override
  String get studyFieldProcessType => 'Process type';

  @override
  String get studyFieldPartProduct => 'Part / Product';

  @override
  String get studyFieldProcessOperation => 'Process / Operation';

  @override
  String get studyFieldMachine => 'Machine / Workstation';

  @override
  String get studyFieldLineCell => 'Line / Cell';

  @override
  String get studyFieldOperator => 'Operator';

  @override
  String get studyFieldShift => 'Shift';

  @override
  String get studyFieldWorkOrder => 'Work order #';

  @override
  String get studyFieldNotes => 'Notes';

  @override
  String get processTypeNone => 'None';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get catalogEmpty => 'No operations yet. Add the first one.';

  @override
  String get catalogNewTitle => 'New operation';

  @override
  String get catalogEditTitle => 'Edit operation';

  @override
  String get operationNameLabel => 'Operation name';

  @override
  String get operationCategoryLabel => 'Type';

  @override
  String get operationSubtypeLabel => 'Subtype';

  @override
  String get operationReferenceStandardLabel => 'Reference standard time';

  @override
  String get subtypeNewTitle => 'New subtype';

  @override
  String get subtypeNameLabel => 'Subtype name';

  @override
  String get deleteOperationTitle => 'Delete operation';

  @override
  String deleteOperationMessage(String name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get categorySetup => 'Setup';

  @override
  String get categoryProductive => 'Productive';

  @override
  String get categoryUnproductive => 'Unproductive';

  @override
  String get wasteWaiting => 'Waiting';

  @override
  String get wasteMotion => 'Motion';

  @override
  String get wasteTransportation => 'Transportation';

  @override
  String get wasteOverProcessing => 'Over-processing';

  @override
  String get wasteOverproduction => 'Overproduction';

  @override
  String get wasteInventory => 'Inventory';

  @override
  String get wasteDefects => 'Defects';

  @override
  String get sequenceEmpty => 'No operations yet. Add them from the catalog.';

  @override
  String get addOperationTitle => 'Add operation';

  @override
  String get catalogPickerEmpty =>
      'Your catalog is empty. Add operations in the Catalog tab first.';

  @override
  String get customOperationTitle => 'Custom operation';

  @override
  String get filterAll => 'All';

  @override
  String get navTemplates => 'Templates';

  @override
  String get templatesEmpty => 'No templates yet. Create the first one.';

  @override
  String get templateNewTitle => 'New template';

  @override
  String get templateEditTitle => 'Edit template';

  @override
  String get templateNameLabel => 'Template name';

  @override
  String get templateDefaultType => 'Default study type';

  @override
  String get deleteTemplateTitle => 'Delete template';

  @override
  String deleteTemplateMessage(String name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get createStudyAction => 'Create study';

  @override
  String get instantiateTitle => 'Create study from template';

  @override
  String get fieldProject => 'Project';

  @override
  String get instantiateNoProjects => 'Create a project first.';

  @override
  String get templateStudyCreated => 'Study created.';

  @override
  String get saveAsTemplateAction => 'Save as template';

  @override
  String get searchHint => 'Search operations';

  @override
  String get timingTitle => 'Timing';

  @override
  String get timingStart => 'Start timing';

  @override
  String get timingContinue => 'Continue timing';

  @override
  String get timingView => 'View timing';

  @override
  String timingLapNext(String name) {
    return 'End & start:\n$name';
  }

  @override
  String get timingLapFinal => 'End final operation';

  @override
  String get timingUnplanned => 'Unplanned';

  @override
  String get timingUnplannedTag => 'unplanned';

  @override
  String get timingFinish => 'Finish';

  @override
  String get timingInsertUnplannedTitle => 'Insert unplanned operation';

  @override
  String get timingComplete => 'Study complete';

  @override
  String get timingTotalTime => 'Total time';

  @override
  String get timingValueAddedRatio => 'Value-added ratio';

  @override
  String get timingDiscard => 'Discard timing';

  @override
  String get timingDiscardTitle => 'Discard timing';

  @override
  String get timingDiscardMessage =>
      'Delete all recorded times for this study? This cannot be undone.';

  @override
  String get timingNoOperations => 'Add operations before timing.';

  @override
  String get timingNoSegments => 'No operations recorded yet.';

  @override
  String get workspaceTotalLabel => 'Total';

  @override
  String workspaceExpectedCoverage(int withReference, int total) {
    return '$withReference of $total ops';
  }

  @override
  String get settingsAlertSounds => 'Alert sounds';

  @override
  String get settingsAlertSoundsSubtitle =>
      'Sound when an operation nears or passes its expected time';

  @override
  String timedProgress(int done, int total) {
    return '$done / $total timed';
  }

  @override
  String get colOperation => 'Operation Name';

  @override
  String get colExpected => 'Expected';

  @override
  String get colActual => 'Actual';

  @override
  String get tooltipStart => 'Start';

  @override
  String get tooltipResume => 'Resume';

  @override
  String get tooltipPause => 'Pause';

  @override
  String get tooltipStop => 'Stop';

  @override
  String get tooltipStopNext => 'Stop & start next';

  @override
  String get tooltipReset => 'Reset';

  @override
  String get resetConfirmTitle => 'Reset operation';

  @override
  String resetConfirmMessage(String name) {
    return 'Discard the measured time for $name?';
  }

  @override
  String get interruptionTitle => 'Operation paused';

  @override
  String get interruptionMessage =>
      'Log this interruption as an unproductive operation?';

  @override
  String get interruptionLog => 'Log interruption';

  @override
  String get interruptionSkip => 'Not now';

  @override
  String get manualTimeTitle => 'Enter actual time';

  @override
  String get manualClear => 'Clear override';

  @override
  String get manualBadge => 'manual';

  @override
  String get actionDuplicate => 'Duplicate';

  @override
  String get noteAction => 'Note';

  @override
  String get noteDialogTitle => 'Operation note';

  @override
  String get noteHint => 'Comments about this operation';

  @override
  String get photosAction => 'Photos';

  @override
  String get photosEmpty => 'No photos yet.';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get addPhotoCamera => 'Take photo';

  @override
  String get addPhotoLibrary => 'Choose from library';

  @override
  String get captionLabel => 'Caption';

  @override
  String get deletePhotoTitle => 'Delete photo';

  @override
  String get deletePhotoMessage => 'Delete this photo? This cannot be undone.';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportTotalElapsed => 'Total elapsed';

  @override
  String get reportWorkContent => 'Work content';

  @override
  String get reportSimultaneous => 'Simultaneous';

  @override
  String get reportUnattributed => 'Unattributed';

  @override
  String get timelineNotMeasured => 'not measured';

  @override
  String get timelineRelativeAxis =>
      'Sequence — no live timing, times are relative';

  @override
  String get reportEfficiency => 'Efficiency (%)';

  @override
  String get reportRollupTitle => 'Category breakdown';

  @override
  String get reportTimelineTitle => 'Timeline';

  @override
  String get reportParetoTitle => 'Waste Pareto';

  @override
  String get colStart => 'Start';

  @override
  String get colEnd => 'End';

  @override
  String get colObserved => 'Observed Time';

  @override
  String get colReference => 'Reference Time';

  @override
  String get colNotes => 'Notes';

  @override
  String get colImages => 'Images';

  @override
  String get reportEmpty => 'Time some operations to see the report.';

  @override
  String get wasteUnlabeled => 'Unlabeled';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get backupAction => 'Back up';

  @override
  String get backupSubtitle => 'Save everything to a .chronus file';

  @override
  String get backupDone => 'Backup saved.';

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreSubtitle => 'Replace all data from a .chronus file';

  @override
  String get restoreConfirmTitle => 'Restore from backup?';

  @override
  String get restoreConfirmMessage =>
      'This replaces every project, study and photo currently in Chronus. It cannot be undone — back up first if you are unsure.';

  @override
  String restoreDone(String date) {
    return 'Restored the backup from $date.';
  }

  @override
  String get restoreErrorNotBundle => 'That file is not a Chronus backup.';

  @override
  String get restoreErrorDamaged =>
      'That backup is incomplete or damaged, so nothing was changed.';

  @override
  String get restoreErrorTooNew =>
      'That backup was made by a newer version of Chronus. Update the app, then try again.';

  @override
  String get exportAction => 'Export';

  @override
  String get exportPdf => 'PDF — report';

  @override
  String get exportXlsx => 'Excel — data';

  @override
  String get exportInProgress => 'Preparing export…';

  @override
  String get exportDone => 'Export ready.';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get actionClose => 'Close';

  @override
  String get shortcutsTitle => 'Keyboard shortcuts';

  @override
  String get shortcutsTooltip => 'Keyboard shortcuts (F1)';

  @override
  String get shortcutsKeySpace => 'Space';

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
      'Stop the running operation and start the next one, with no gap between them. If nothing is running, starts the first operation not yet timed.';

  @override
  String get shortcutsMove => 'Pick a row.';

  @override
  String get shortcutsToggle => 'Start or pause the picked row.';

  @override
  String get shortcutsStop => 'Stop the picked row.';

  @override
  String get shortcutsClear => 'Clear the picked row.';

  @override
  String get shortcutsConcurrencyNote =>
      'With two or more operations running at once, Space does nothing: which one is “current” is genuinely ambiguous, and stopping the wrong operator\'s timer would ruin the measurement. Pick the row and press Enter.';

  @override
  String get lapAmbiguous =>
      'Several operations running — pick the row and press Enter.';

  @override
  String get lapNothingToStart => 'Nothing left to start.';

  @override
  String get snapshotsTitle => 'Automatic copies';

  @override
  String get snapshotsSubtitle =>
      'Made on their own, once a day. Studies and projects only — photos are not included, and are never changed by a restore.';

  @override
  String get snapshotRestoreConfirmTitle => 'Restore this copy?';

  @override
  String snapshotRestoreConfirmMessage(String date) {
    return 'This replaces every project and study with the ones from $date. Photos are left as they are. It cannot be undone.';
  }

  @override
  String snapshotRestoreDone(String date) {
    return 'Copy from $date restored.';
  }

  @override
  String get orphanedTimingTitle => 'Timers left running';

  @override
  String orphanedTimingMessage(int count, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operations have been counting',
      one: '1 operation has been counting',
    );
    return '$_temp0 since $since, because Chronus was closed without stopping the timer. That time was never ended, so it cannot be measured.';
  }

  @override
  String get orphanedTimingKeep => 'Keep timing';

  @override
  String get orphanedTimingDiscard => 'Discard that time';

  @override
  String get settingsDiagnosticsSection => 'Diagnostics';

  @override
  String get diagnosticsBuild => 'Version';

  @override
  String get diagnosticsSave => 'Save diagnostics';

  @override
  String get diagnosticsSaveSubtitle =>
      'A text file with the app\'s history, to send on';

  @override
  String get diagnosticsSaved => 'Diagnostics saved.';

  @override
  String get diagnosticsOpenFolder => 'Open data folder';

  @override
  String get diagnosticsOpenFolderSubtitle =>
      'Where the database, photos and backups live';

  @override
  String diagnosticsFolderFailed(String error) {
    return 'Could not open the folder: $error';
  }

  @override
  String get feedbackAction => 'Send feedback';

  @override
  String get feedbackSubtitle =>
      'Note what got in the way; it travels with the diagnostics';

  @override
  String get feedbackHint => 'What happened?';

  @override
  String get feedbackSaved => 'Noted. It goes along when you save diagnostics.';

  @override
  String get passesTitle => 'Passes';

  @override
  String passLabel(int number) {
    return 'Pass $number';
  }

  @override
  String get passAdd => 'New pass';

  @override
  String passTimedCount(int timed, int total) {
    return '$timed of $total timed';
  }

  @override
  String get passNothingTimed => 'Nothing timed yet';

  @override
  String get passExcludedBadge => 'Excluded';

  @override
  String get passExclude => 'Exclude from statistics';

  @override
  String get passInclude => 'Put back in the statistics';

  @override
  String passExcludeTitle(String pass) {
    return 'Exclude $pass?';
  }

  @override
  String get passExcludeMessage =>
      'It keeps its measurements and its own report — it is only left out of the averages. You can put it back at any time.';

  @override
  String get passExcludeReasonHint => 'Why? (e.g. line starved)';

  @override
  String get passDelete => 'Delete pass';

  @override
  String get passDeleteBlocked =>
      'This pass has measurements. Exclude it instead — that keeps the evidence.';

  @override
  String get passDeleteLastBlocked => 'A study keeps at least one pass.';

  @override
  String passDeleteConfirmTitle(String pass) {
    return 'Delete $pass?';
  }

  @override
  String get passDeleteConfirmMessage =>
      'Nothing was timed in it. The number is not used again.';
}
