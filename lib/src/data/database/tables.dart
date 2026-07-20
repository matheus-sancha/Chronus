import 'package:drift/drift.dart';

import 'enums.dart';

// All ids are string UUIDs (stable across the .chronus backup/restore bundle and
// the iOS -> Windows migration path). Precise operation timing is stored as
// absolute epoch MILLISECONDS (exact; survives backgrounding; boundary-editable);
// metadata timestamps use DateTime (second precision is fine there).

// --- Projects -------------------------------------------------------------

/// Top of the hierarchy. Groups the studies compared against one another
/// (comparison is scoped to a single project in v1).
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// --- Classification taxonomy ---------------------------------------------

/// A subtype within one fixed [OperationCategory]. The 7 wastes are seeded
/// built-ins under `unproductive`; users may add custom subtypes in any
/// category so roll-up reporting still works.
class OperationSubtypes extends Table {
  TextColumn get id => text()();
  TextColumn get category => textEnum<OperationCategory>()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// --- Operation catalog ----------------------------------------------------

/// Reusable operation definition. Adding one to a study SNAPSHOTS its fields into
/// a [StudyOperations] row (historical integrity) while keeping a hidden id link.
class CatalogOperations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get category => textEnum<OperationCategory>()();
  TextColumn get subtypeId => text()
      .nullable()
      .references(OperationSubtypes, #id, onDelete: KeyAction.setNull)();

  /// Optional pre-existing benchmark ("reference standard"), in milliseconds.
  IntColumn get referenceStandardMs => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// --- Studies --------------------------------------------------------------

class Studies extends Table {
  TextColumn get id => text()();
  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<StudyType>()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  DateTimeColumn get performedAt => dateTime()();
  TextColumn get analyst => text().nullable()();

  // Optional header metadata (fixed field set for v1).
  TextColumn get partProduct => text().nullable()();
  TextColumn get processOperation => text().nullable()();
  TextColumn get machineWorkstation => text().nullable()();
  TextColumn get lineCell => text().nullable()();
  TextColumn get operatorName => text().nullable()();
  TextColumn get shift => text().nullable()();
  TextColumn get workOrderNumber => text().nullable()();

  /// Chosen value from the editable [ProcessTypeOptions] picklist, snapshotted
  /// as text so historical studies keep their value if the option changes.
  TextColumn get processType => text().nullable()();

  /// Study-level allowance % for the standard-time chain (per-category overrides
  /// live in [StudyAllowanceOverrides]). Rating % is per operation-instance.
  RealColumn get allowancePercent => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Optional per-category allowance override. Absence => use the study default.
class StudyAllowanceOverrides extends Table {
  TextColumn get id => text()();
  TextColumn get studyId =>
      text().references(Studies, #id, onDelete: KeyAction.cascade)();
  TextColumn get category => textEnum<OperationCategory>()();
  RealColumn get allowancePercent => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {studyId, category},
      ];
}

/// The study's planned operation SEQUENCE — the per-study snapshot of catalog
/// definitions, with a hidden [catalogOperationId] link for cross-study grouping.
/// Shared by all observations. Unplanned ops inserted mid-run are stored here too,
/// flagged [isUnplanned]. Timing is per-observation in [OperationInstances].
class StudyOperations extends Table {
  TextColumn get id => text()();
  TextColumn get studyId =>
      text().references(Studies, #id, onDelete: KeyAction.cascade)();
  TextColumn get catalogOperationId => text()
      .nullable()
      .references(CatalogOperations, #id, onDelete: KeyAction.setNull)();

  /// Fractional, so an unplanned op can be inserted between two existing ones
  /// (e.g. 2.5) without renumbering the rest of the sequence.
  RealColumn get orderIndex => real()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get category => textEnum<OperationCategory>()();
  TextColumn get subtypeId => text()
      .nullable()
      .references(OperationSubtypes, #id, onDelete: KeyAction.setNull)();
  IntColumn get referenceStandardMs => integer().nullable()();
  BoolColumn get isUnplanned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One timed pass through the study's operations. Time Study = exactly one;
/// Sampling Study = N. Unifying on observation lets sampling reuse the Time Study
/// stopwatch engine unchanged.
class Observations extends Table {
  TextColumn get id => text()();
  TextColumn get studyId =>
      text().references(Studies, #id, onDelete: KeyAction.cascade)();
  IntColumn get sequenceIndex => integer()();
  DateTimeColumn get performedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {studyId, sequenceIndex},
      ];
}

/// The measured timing of one [StudyOperations] row within one [Observations].
///
/// Timing is per-operation and discrete (snapback): the operation is started,
/// paused and resumed independently, so its measured time is the SUM of one or
/// more [OperationTimeSegments] (not a single span). Multiple instances may run
/// at once (two operators, or man + machine). [manualActualMs], when set,
/// NON-DESTRUCTIVELY shadows the measured sum (segments are kept); it also lets
/// a paper study be transcribed with no live timing at all. Rating % is per
/// instance (default 100), applied in the Phase-4 standard-time chain.
class OperationInstances extends Table {
  TextColumn get id => text()();
  TextColumn get observationId =>
      text().references(Observations, #id, onDelete: KeyAction.cascade)();
  TextColumn get studyOperationId =>
      text().references(StudyOperations, #id, onDelete: KeyAction.cascade)();

  /// Manual override of the actual time, in milliseconds. Null => use the sum
  /// of [OperationTimeSegments]. Setting it never deletes segments.
  IntColumn get manualActualMs => integer().nullable()();

  /// When the operation was **stopped** (marked complete). Null while it is
  /// still pending, running, or merely paused. Lets the UI tell a paused
  /// operation (resumable) apart from a finished one, since both have no open
  /// segment. Cleared if timing resumes.
  DateTimeColumn get completedAt => dateTime().nullable()();
  RealColumn get ratingPercent => real().withDefault(const Constant(100.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {observationId, studyOperationId},
      ];
}

/// One timed interval of an [OperationInstances]. A fresh start or a resume
/// opens a segment ([endAtMs] null = currently running); a pause or stop closes
/// it. Absolute epoch milliseconds (exact; survives backgrounding; boundary-
/// editable). Observed time of the instance = Σ (endAtMs − startAtMs).
class OperationTimeSegments extends Table {
  TextColumn get id => text()();
  TextColumn get operationInstanceId =>
      text().references(OperationInstances, #id, onDelete: KeyAction.cascade)();
  IntColumn get startAtMs => integer()();
  IntColumn get endAtMs => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// --- Templates ------------------------------------------------------------

/// Reusable ordered sequence + default settings. No measured data, ever.
class Templates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get defaultStudyType => textEnum<StudyType>()();
  RealColumn get defaultAllowancePercent =>
      real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A template's ordered operations. Snapshot-based like [StudyOperations]: each
/// row carries its own fields plus an OPTIONAL hidden [catalogOperationId] link
/// (null for custom operations added directly to the template). Instantiating a
/// template copies these into [StudyOperations].
class TemplateOperations extends Table {
  TextColumn get id => text()();
  TextColumn get templateId =>
      text().references(Templates, #id, onDelete: KeyAction.cascade)();
  TextColumn get catalogOperationId => text()
      .nullable()
      .references(CatalogOperations, #id, onDelete: KeyAction.setNull)();
  RealColumn get orderIndex => real()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get category => textEnum<OperationCategory>()();
  TextColumn get subtypeId => text()
      .nullable()
      .references(OperationSubtypes, #id, onDelete: KeyAction.setNull)();
  IntColumn get referenceStandardMs => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// --- Reference data & media ----------------------------------------------

/// Editable seed list backing the Process Type single-select picker on studies.
class ProcessTypeOptions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// App-wide user settings. Single row (id always 0). Lives in the DB so it
/// travels in the .chronus backup bundle and migrates with the data.
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// null => follow the system locale; otherwise 'en' / 'pt' / 'es'.
  TextColumn get localeCode => text().nullable()();

  /// Pre-fills the Analyst field on new studies.
  TextColumn get defaultAnalyst => text().nullable()();
  TextColumn get timeUnit => textEnum<TimeUnit>()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Photos + short video attached at study / observation / operation-instance
/// level (polymorphic owner via [ownerType] + [ownerId]). Files live in the app
/// media directory; only the relative path is stored — never blobs.
class MediaAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get ownerType => textEnum<MediaOwnerType>()();
  TextColumn get ownerId => text()();
  TextColumn get kind => textEnum<MediaKind>()();
  TextColumn get relativePath => text()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
