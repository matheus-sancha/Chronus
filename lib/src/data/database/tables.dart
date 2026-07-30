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

  TextColumn get notes => text().nullable()();

  /// Sample-size criteria for a Sampling Study, **stored per study rather than
  /// as a global preference** (DESIGN.md §11.5).
  ///
  /// Same reasoning as snapshotting reference standards (§3.3): the criteria a
  /// study was judged against belong to that study. A global setting would
  /// silently re-judge every past study when someone changed it, so a report
  /// that read "adequate" could later read otherwise with no record of which
  /// criteria produced the original verdict.
  ///
  /// [confidenceLevel] is a probability (0,1) — 0.95 for 95 %. [relativePrecision]
  /// is a fraction of the mean — 0.05 for ±5 %. Both are meaningless for a Time
  /// Study and simply unused there.
  RealColumn get confidenceLevel =>
      real().withDefault(const Constant(0.95))();
  RealColumn get relativePrecision =>
      real().withDefault(const Constant(0.05))();

  /// The sequence index the next pass will take — a counter, not a count
  /// (DESIGN.md §11.3).
  ///
  /// Pass numbers are never reused, and `MAX(sequenceIndex) + 1` cannot deliver
  /// that: deleting the highest pass would hand its number straight back to the
  /// next one. Only a value that does not depend on which rows still exist can,
  /// so it lives here and only ever goes up. Starts at 1 because creating a
  /// study also creates pass 0 (§11.1).
  IntColumn get nextPassIndex => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The study's planned operation SEQUENCE — the per-study snapshot of catalog
/// definitions, with a hidden [catalogOperationId] link for cross-study grouping.
/// Shared by all observations. Unplanned ops inserted mid-run are stored here too,
/// flagged [isUnplanned]. Timing is per-observation in [OperationInstances].
class StudyOperations extends Table {
  TextColumn get id => text()();
  TextColumn get studyId =>
      text().references(Studies, #id, onDelete: KeyAction.cascade)();

  /// The catalog operation this was snapshotted from — **a value, not a
  /// reference** (DESIGN.md §11.8). Deliberately carries no foreign key.
  ///
  /// It is the key cross-study comparison groups by, and §3.3 promises it keeps
  /// working. As a foreign key with `setNull` it did not: deleting a catalog
  /// operation silently unmatched every study that had ever used it, with
  /// nothing said. Every other field here is already a snapshot for exactly this
  /// reason — the id was the one left live. Null means the operation was never
  /// from the catalog (added custom, or unplanned), which is the only reason it
  /// can be null now.
  TextColumn get catalogOperationId => text().nullable()();

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

  /// Position in the study, from 0. **Never renumbered and never reused**
  /// (DESIGN.md §11.3): "Pass 4" in an exported file or a written note has to
  /// mean the same pass forever, so a removed pass leaves a labelled gap rather
  /// than shifting the ones after it. Displayed as `sequenceIndex + 1`.
  IntColumn get sequenceIndex => integer()();
  DateTimeColumn get performedAt => dateTime()();
  TextColumn get notes => text().nullable()();

  /// When this whole pass was excluded from the statistics, or null if it counts
  /// (DESIGN.md §11.3).
  ///
  /// Excluding is **not** deleting: the pass keeps its measurements, its own
  /// report and its rows in the Segments sheet — it is only out of the aggregate
  /// mean, deviation, CV and sample-size verdict. Reversible, and the reason is
  /// recorded next to it, because "the line was starved" is the difference
  /// between a discarded pass and a suspicious one.
  DateTimeColumn get excludedAt => dateTime().nullable()();
  TextColumn get exclusionReason => text().nullable()();

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
/// a paper study be transcribed with no live timing at all.
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
  TextColumn get notes => text().nullable()();

  /// When this single reading was excluded from the statistics, or null if it
  /// counts (DESIGN.md §11.3).
  ///
  /// The finer grain of the pass-level flag above, for the ordinary case: one
  /// operation went wrong in an otherwise good pass. Cronoanálise discards
  /// anomalous readings before computing a mean, and without this the only ways
  /// to do that were to delete the whole pass — losing every other operation's
  /// good reading in it — or to type an override, inventing a number.
  ///
  /// The app may **flag** candidates (a reading beyond ±3s) and must never act
  /// on them: only the analyst knows whether a long cycle was legitimate, which
  /// is §10.4's reasoning about abandoned segments applied to a measured one.
  DateTimeColumn get excludedAt => dateTime().nullable()();
  TextColumn get exclusionReason => text().nullable()();

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

  /// Sound when an operation nears or passes its reference standard (§3.6).
  BoolColumn get alertSoundsEnabled =>
      boolean().withDefault(const Constant(true))();

  /// When the starter catalog was seeded, or null if it never was (§9).
  ///
  /// A record that the offer was *made*, not that the rows still exist. Seeding
  /// is guarded on an empty catalog, which alone would refill it for someone who
  /// deliberately emptied theirs — this is what makes "no thanks" stick across
  /// the next drop.
  DateTimeColumn get starterCatalogSeededAt => dateTime().nullable()();

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
