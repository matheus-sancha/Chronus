import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// Application name, shown in titles.
  ///
  /// In en, this message translates to:
  /// **'Chronus'**
  String get appTitle;

  /// Label for the Projects destination.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// Label for the Settings destination.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Shown when the project list is empty.
  ///
  /// In en, this message translates to:
  /// **'No projects yet. Create your first one.'**
  String get projectsEmpty;

  /// Title of the create-project dialog.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get projectsNewTitle;

  /// Label for the project name input.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectNameLabel;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// Settings row for choosing the app language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// Settings row for the default analyst name used on new studies.
  ///
  /// In en, this message translates to:
  /// **'Default analyst'**
  String get settingsAnalyst;

  /// No description provided for @settingsAnalystEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsAnalystEmpty;

  /// Settings row for the entry/display time unit.
  ///
  /// In en, this message translates to:
  /// **'Time unit'**
  String get settingsUnit;

  /// No description provided for @settingsUnitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get settingsUnitSeconds;

  /// No description provided for @settingsUnitDecimalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Decimal minutes'**
  String get settingsUnitDecimalMinutes;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @projectEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get projectEditTitle;

  /// No description provided for @projectNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get projectNotesLabel;

  /// No description provided for @deleteProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get deleteProjectTitle;

  /// No description provided for @deleteProjectMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} and all its studies? This cannot be undone.'**
  String deleteProjectMessage(String name);

  /// No description provided for @studiesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Studies'**
  String get studiesSectionTitle;

  /// No description provided for @studiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No studies yet. Create the first one.'**
  String get studiesEmpty;

  /// No description provided for @studyNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New study'**
  String get studyNewTitle;

  /// No description provided for @studyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Study name'**
  String get studyNameLabel;

  /// No description provided for @studyTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Study type'**
  String get studyTypeLabel;

  /// No description provided for @studyTypeTime.
  ///
  /// In en, this message translates to:
  /// **'Time Study'**
  String get studyTypeTime;

  /// No description provided for @studyTypeSampling.
  ///
  /// In en, this message translates to:
  /// **'Sampling Study'**
  String get studyTypeSampling;

  /// No description provided for @deleteStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete study'**
  String get deleteStudyTitle;

  /// No description provided for @deleteStudyMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String deleteStudyMessage(String name);

  /// No description provided for @studyFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get studyFieldType;

  /// No description provided for @studyFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get studyFieldDate;

  /// No description provided for @studyFieldAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Analyst'**
  String get studyFieldAnalyst;

  /// No description provided for @studyOperationsSection.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get studyOperationsSection;

  /// No description provided for @studyOperationsPending.
  ///
  /// In en, this message translates to:
  /// **'Operations are added when you build the sequence.'**
  String get studyOperationsPending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
