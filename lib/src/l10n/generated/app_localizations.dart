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

  /// No description provided for @studyEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit study'**
  String get studyEditTitle;

  /// No description provided for @studyDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get studyDetailsSection;

  /// No description provided for @studyFieldProcessType.
  ///
  /// In en, this message translates to:
  /// **'Process type'**
  String get studyFieldProcessType;

  /// No description provided for @studyFieldPartProduct.
  ///
  /// In en, this message translates to:
  /// **'Part / Product'**
  String get studyFieldPartProduct;

  /// No description provided for @studyFieldProcessOperation.
  ///
  /// In en, this message translates to:
  /// **'Process / Operation'**
  String get studyFieldProcessOperation;

  /// No description provided for @studyFieldMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine / Workstation'**
  String get studyFieldMachine;

  /// No description provided for @studyFieldLineCell.
  ///
  /// In en, this message translates to:
  /// **'Line / Cell'**
  String get studyFieldLineCell;

  /// No description provided for @studyFieldOperator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get studyFieldOperator;

  /// No description provided for @studyFieldShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get studyFieldShift;

  /// No description provided for @studyFieldWorkOrder.
  ///
  /// In en, this message translates to:
  /// **'Work order #'**
  String get studyFieldWorkOrder;

  /// No description provided for @studyFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get studyFieldNotes;

  /// No description provided for @processTypeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get processTypeNone;

  /// No description provided for @navCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// No description provided for @catalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No operations yet. Add the first one.'**
  String get catalogEmpty;

  /// No description provided for @catalogNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New operation'**
  String get catalogNewTitle;

  /// No description provided for @catalogEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit operation'**
  String get catalogEditTitle;

  /// No description provided for @operationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Operation name'**
  String get operationNameLabel;

  /// No description provided for @operationCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get operationCategoryLabel;

  /// No description provided for @operationSubtypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtype'**
  String get operationSubtypeLabel;

  /// No description provided for @operationReferenceStandardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference standard time'**
  String get operationReferenceStandardLabel;

  /// No description provided for @subtypeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New subtype'**
  String get subtypeNewTitle;

  /// No description provided for @subtypeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtype name'**
  String get subtypeNameLabel;

  /// No description provided for @deleteOperationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete operation'**
  String get deleteOperationTitle;

  /// No description provided for @deleteOperationMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String deleteOperationMessage(String name);

  /// No description provided for @categorySetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get categorySetup;

  /// No description provided for @categoryProductive.
  ///
  /// In en, this message translates to:
  /// **'Productive'**
  String get categoryProductive;

  /// No description provided for @categoryUnproductive.
  ///
  /// In en, this message translates to:
  /// **'Unproductive'**
  String get categoryUnproductive;

  /// No description provided for @wasteWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get wasteWaiting;

  /// No description provided for @wasteMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get wasteMotion;

  /// No description provided for @wasteTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get wasteTransportation;

  /// No description provided for @wasteOverProcessing.
  ///
  /// In en, this message translates to:
  /// **'Over-processing'**
  String get wasteOverProcessing;

  /// No description provided for @wasteOverproduction.
  ///
  /// In en, this message translates to:
  /// **'Overproduction'**
  String get wasteOverproduction;

  /// No description provided for @wasteInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get wasteInventory;

  /// No description provided for @wasteDefects.
  ///
  /// In en, this message translates to:
  /// **'Defects'**
  String get wasteDefects;

  /// No description provided for @sequenceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No operations yet. Add them from the catalog.'**
  String get sequenceEmpty;

  /// No description provided for @addOperationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add operation'**
  String get addOperationTitle;

  /// No description provided for @catalogPickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your catalog is empty. Add operations in the Catalog tab first.'**
  String get catalogPickerEmpty;

  /// No description provided for @customOperationTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom operation'**
  String get customOperationTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @navTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get navTemplates;

  /// No description provided for @templatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates yet. Create the first one.'**
  String get templatesEmpty;

  /// No description provided for @templateNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get templateNewTitle;

  /// No description provided for @templateEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get templateEditTitle;

  /// No description provided for @templateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateNameLabel;

  /// No description provided for @templateDefaultType.
  ///
  /// In en, this message translates to:
  /// **'Default study type'**
  String get templateDefaultType;

  /// No description provided for @deleteTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get deleteTemplateTitle;

  /// No description provided for @deleteTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String deleteTemplateMessage(String name);

  /// No description provided for @createStudyAction.
  ///
  /// In en, this message translates to:
  /// **'Create study'**
  String get createStudyAction;

  /// No description provided for @instantiateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create study from template'**
  String get instantiateTitle;

  /// No description provided for @fieldProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get fieldProject;

  /// No description provided for @instantiateNoProjects.
  ///
  /// In en, this message translates to:
  /// **'Create a project first.'**
  String get instantiateNoProjects;

  /// No description provided for @templateStudyCreated.
  ///
  /// In en, this message translates to:
  /// **'Study created.'**
  String get templateStudyCreated;

  /// No description provided for @saveAsTemplateAction.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get saveAsTemplateAction;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search operations'**
  String get searchHint;

  /// No description provided for @timingTitle.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timingTitle;

  /// No description provided for @timingStart.
  ///
  /// In en, this message translates to:
  /// **'Start timing'**
  String get timingStart;

  /// No description provided for @timingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue timing'**
  String get timingContinue;

  /// No description provided for @timingView.
  ///
  /// In en, this message translates to:
  /// **'View timing'**
  String get timingView;

  /// The big lap-advance button while running; ends the current operation and starts the next.
  ///
  /// In en, this message translates to:
  /// **'End & start:\n{name}'**
  String timingLapNext(String name);

  /// No description provided for @timingLapFinal.
  ///
  /// In en, this message translates to:
  /// **'End final operation'**
  String get timingLapFinal;

  /// No description provided for @timingUnplanned.
  ///
  /// In en, this message translates to:
  /// **'Unplanned'**
  String get timingUnplanned;

  /// No description provided for @timingUnplannedTag.
  ///
  /// In en, this message translates to:
  /// **'unplanned'**
  String get timingUnplannedTag;

  /// No description provided for @timingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get timingFinish;

  /// No description provided for @timingInsertUnplannedTitle.
  ///
  /// In en, this message translates to:
  /// **'Insert unplanned operation'**
  String get timingInsertUnplannedTitle;

  /// No description provided for @timingComplete.
  ///
  /// In en, this message translates to:
  /// **'Study complete'**
  String get timingComplete;

  /// No description provided for @timingTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get timingTotalTime;

  /// No description provided for @timingValueAddedRatio.
  ///
  /// In en, this message translates to:
  /// **'Value-added ratio'**
  String get timingValueAddedRatio;

  /// No description provided for @timingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard timing'**
  String get timingDiscard;

  /// No description provided for @timingDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard timing'**
  String get timingDiscardTitle;

  /// No description provided for @timingDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete all recorded times for this study? This cannot be undone.'**
  String get timingDiscardMessage;

  /// No description provided for @timingNoOperations.
  ///
  /// In en, this message translates to:
  /// **'Add operations before timing.'**
  String get timingNoOperations;

  /// No description provided for @timingNoSegments.
  ///
  /// In en, this message translates to:
  /// **'No operations recorded yet.'**
  String get timingNoSegments;

  /// No description provided for @workspaceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get workspaceTotalLabel;

  /// Shown under the Expected tile when some operations have no reference standard, so the planned total is understated.
  ///
  /// In en, this message translates to:
  /// **'{withReference} of {total} ops'**
  String workspaceExpectedCoverage(int withReference, int total);

  /// No description provided for @settingsAlertSounds.
  ///
  /// In en, this message translates to:
  /// **'Alert sounds'**
  String get settingsAlertSounds;

  /// No description provided for @settingsAlertSoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sound when an operation nears or passes its expected time'**
  String get settingsAlertSoundsSubtitle;

  /// No description provided for @timedProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} timed'**
  String timedProgress(int done, int total);

  /// No description provided for @colOperation.
  ///
  /// In en, this message translates to:
  /// **'Operation Name'**
  String get colOperation;

  /// No description provided for @colExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get colExpected;

  /// No description provided for @colActual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get colActual;

  /// No description provided for @tooltipStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get tooltipStart;

  /// No description provided for @tooltipResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get tooltipResume;

  /// No description provided for @tooltipPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get tooltipPause;

  /// No description provided for @tooltipStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get tooltipStop;

  /// No description provided for @tooltipStopNext.
  ///
  /// In en, this message translates to:
  /// **'Stop & start next'**
  String get tooltipStopNext;

  /// No description provided for @tooltipReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tooltipReset;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset operation'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Discard the measured time for {name}?'**
  String resetConfirmMessage(String name);

  /// No description provided for @interruptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation paused'**
  String get interruptionTitle;

  /// No description provided for @interruptionMessage.
  ///
  /// In en, this message translates to:
  /// **'Log this interruption as an unproductive operation?'**
  String get interruptionMessage;

  /// No description provided for @interruptionLog.
  ///
  /// In en, this message translates to:
  /// **'Log interruption'**
  String get interruptionLog;

  /// No description provided for @interruptionSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get interruptionSkip;

  /// No description provided for @manualTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter actual time'**
  String get manualTimeTitle;

  /// No description provided for @manualClear.
  ///
  /// In en, this message translates to:
  /// **'Clear override'**
  String get manualClear;

  /// No description provided for @manualBadge.
  ///
  /// In en, this message translates to:
  /// **'manual'**
  String get manualBadge;

  /// No description provided for @actionDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get actionDuplicate;

  /// No description provided for @noteAction.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteAction;

  /// No description provided for @noteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation note'**
  String get noteDialogTitle;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Comments about this operation'**
  String get noteHint;

  /// No description provided for @photosAction.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosAction;

  /// No description provided for @photosEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photos yet.'**
  String get photosEmpty;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @addPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get addPhotoCamera;

  /// No description provided for @addPhotoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get addPhotoLibrary;

  /// No description provided for @captionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionLabel;

  /// No description provided for @deletePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhotoTitle;

  /// No description provided for @deletePhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo? This cannot be undone.'**
  String get deletePhotoMessage;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportTotalElapsed.
  ///
  /// In en, this message translates to:
  /// **'Total elapsed'**
  String get reportTotalElapsed;

  /// No description provided for @reportWorkContent.
  ///
  /// In en, this message translates to:
  /// **'Work content'**
  String get reportWorkContent;

  /// No description provided for @reportSimultaneous.
  ///
  /// In en, this message translates to:
  /// **'Simultaneous'**
  String get reportSimultaneous;

  /// No description provided for @reportUnattributed.
  ///
  /// In en, this message translates to:
  /// **'Unattributed'**
  String get reportUnattributed;

  /// No description provided for @timelineNotMeasured.
  ///
  /// In en, this message translates to:
  /// **'not measured'**
  String get timelineNotMeasured;

  /// No description provided for @timelineRelativeAxis.
  ///
  /// In en, this message translates to:
  /// **'Sequence — no live timing, times are relative'**
  String get timelineRelativeAxis;

  /// No description provided for @reportEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency (%)'**
  String get reportEfficiency;

  /// No description provided for @reportRollupTitle.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get reportRollupTitle;

  /// No description provided for @reportTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get reportTimelineTitle;

  /// No description provided for @reportParetoTitle.
  ///
  /// In en, this message translates to:
  /// **'Waste Pareto'**
  String get reportParetoTitle;

  /// No description provided for @colStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get colStart;

  /// No description provided for @colEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get colEnd;

  /// No description provided for @colObserved.
  ///
  /// In en, this message translates to:
  /// **'Observed Time'**
  String get colObserved;

  /// No description provided for @colReference.
  ///
  /// In en, this message translates to:
  /// **'Reference Time'**
  String get colReference;

  /// No description provided for @colNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get colNotes;

  /// No description provided for @colImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get colImages;

  /// No description provided for @reportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Time some operations to see the report.'**
  String get reportEmpty;

  /// No description provided for @wasteUnlabeled.
  ///
  /// In en, this message translates to:
  /// **'Unlabeled'**
  String get wasteUnlabeled;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @backupAction.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get backupAction;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save everything to a .chronus file'**
  String get backupSubtitle;

  /// No description provided for @backupDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get backupDone;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @restoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data from a .chronus file'**
  String get restoreSubtitle;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces every project, study and photo currently in Chronus. It cannot be undone — back up first if you are unsure.'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restored the backup from {date}.'**
  String restoreDone(String date);

  /// No description provided for @restoreErrorNotBundle.
  ///
  /// In en, this message translates to:
  /// **'That file is not a Chronus backup.'**
  String get restoreErrorNotBundle;

  /// No description provided for @restoreErrorDamaged.
  ///
  /// In en, this message translates to:
  /// **'That backup is incomplete or damaged, so nothing was changed.'**
  String get restoreErrorDamaged;

  /// No description provided for @restoreErrorTooNew.
  ///
  /// In en, this message translates to:
  /// **'That backup was made by a newer version of Chronus. Update the app, then try again.'**
  String get restoreErrorTooNew;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF — report'**
  String get exportPdf;

  /// No description provided for @exportXlsx.
  ///
  /// In en, this message translates to:
  /// **'Excel — data'**
  String get exportXlsx;

  /// No description provided for @exportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Preparing export…'**
  String get exportInProgress;

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'Export ready.'**
  String get exportDone;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @snapshotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic copies'**
  String get snapshotsTitle;

  /// No description provided for @snapshotsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Made on their own, once a day. Studies and projects only — photos are not included, and are never changed by a restore.'**
  String get snapshotsSubtitle;

  /// No description provided for @snapshotRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this copy?'**
  String get snapshotRestoreConfirmTitle;

  /// No description provided for @snapshotRestoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces every project and study with the ones from {date}. Photos are left as they are. It cannot be undone.'**
  String snapshotRestoreConfirmMessage(String date);

  /// No description provided for @snapshotRestoreDone.
  ///
  /// In en, this message translates to:
  /// **'Copy from {date} restored.'**
  String snapshotRestoreDone(String date);

  /// No description provided for @orphanedTimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Timers left running'**
  String get orphanedTimingTitle;

  /// No description provided for @orphanedTimingMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 operation has been counting} other{{count} operations have been counting}} since {since}, because Chronus was closed without stopping the timer. That time was never ended, so it cannot be measured.'**
  String orphanedTimingMessage(int count, String since);

  /// No description provided for @orphanedTimingKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep timing'**
  String get orphanedTimingKeep;

  /// No description provided for @orphanedTimingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard that time'**
  String get orphanedTimingDiscard;

  /// No description provided for @settingsDiagnosticsSection.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get settingsDiagnosticsSection;

  /// No description provided for @diagnosticsBuild.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get diagnosticsBuild;

  /// No description provided for @diagnosticsSave.
  ///
  /// In en, this message translates to:
  /// **'Save diagnostics'**
  String get diagnosticsSave;

  /// No description provided for @diagnosticsSaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A text file with the app\'s history, to send on'**
  String get diagnosticsSaveSubtitle;

  /// No description provided for @diagnosticsSaved.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics saved.'**
  String get diagnosticsSaved;

  /// No description provided for @diagnosticsOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Open data folder'**
  String get diagnosticsOpenFolder;

  /// No description provided for @diagnosticsOpenFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where the database, photos and backups live'**
  String get diagnosticsOpenFolderSubtitle;

  /// No description provided for @diagnosticsFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the folder: {error}'**
  String diagnosticsFolderFailed(String error);

  /// No description provided for @feedbackAction.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackAction;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Note what got in the way; it travels with the diagnostics'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get feedbackHint;

  /// No description provided for @feedbackSaved.
  ///
  /// In en, this message translates to:
  /// **'Noted. It goes along when you save diagnostics.'**
  String get feedbackSaved;
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
