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
  String get studyFieldAllowance => 'Allowance %';

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
  String get studyAllowanceHelp =>
      'Extra time added for fatigue, delays and personal needs. Standard time = Normal time × (1 + Allowance %).';

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
}
