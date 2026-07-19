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
}
