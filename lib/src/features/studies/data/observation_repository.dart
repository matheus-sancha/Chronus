import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';
import '../../diagnostics/application/diagnostics.dart';

/// One pass, with enough about it to draw a row in the pass list without a
/// second query per pass.
///
/// [timedOperations] out of [totalOperations] is what tells the analyst a pass
/// came out short — the operation the shift interrupted, which is exactly the
/// pass they will want to look at before excluding it.
class PassSummary {
  const PassSummary({
    required this.observation,
    required this.timedOperations,
    required this.totalOperations,
  });

  final Observation observation;
  final int timedOperations;
  final int totalOperations;

  String get id => observation.id;

  /// What the analyst calls it. `sequenceIndex` is 0-based and never renumbered
  /// (DESIGN.md §11.3), so this can leave gaps — deliberately.
  int get number => observation.sequenceIndex + 1;

  bool get isExcluded => observation.excludedAt != null;

  /// True when nothing was ever measured or typed in this pass, which is the
  /// only condition under which it may be deleted rather than excluded.
  bool get isEmpty => timedOperations == 0;

  bool get isComplete =>
      totalOperations > 0 && timedOperations == totalOperations;
}

/// Data access for the passes of a study (DESIGN.md §11.1, §11.3).
///
/// Separate from [TimingRepository] on purpose: that one is the stopwatch and
/// works *inside* one pass, this one manages the set of them. Nothing here
/// touches a segment.
class ObservationRepository {
  ObservationRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Every pass of a study, in sequence order, each with its completeness.
  ///
  /// A single stream rather than one query per row: the list is rebuilt whenever
  /// any timing changes, and a per-row query would mean N+1 of them on every
  /// keystroke of a run.
  Stream<List<PassSummary>> watchPasses(String studyId) {
    final query = _db.select(_db.observations)
      ..where((t) => t.studyId.equals(studyId))
      ..orderBy([(t) => OrderingTerm.asc(t.sequenceIndex)]);

    return query.watch().asyncMap((passes) async {
      final total = await (_db.selectOnly(_db.studyOperations)
            ..addColumns([_db.studyOperations.id.count()])
            ..where(_db.studyOperations.studyId.equals(studyId)))
          .map((r) => r.read(_db.studyOperations.id.count()) ?? 0)
          .getSingle();

      // One pass over every instance of the study, bucketed in memory — cheaper
      // and simpler than a grouped join, at these row counts.
      final instances = await (_db.select(_db.operationInstances)
            ..where((t) => t.observationId.isIn(passes.map((p) => p.id))))
          .get();
      final segments = await _segmentedInstanceIds(studyId);

      final timedByPass = <String, int>{};
      for (final instance in instances) {
        // "Timed" means it carries a real time — a measured segment or a typed
        // override. An instance can exist with neither: adding a note or a photo
        // to an operation creates one.
        final timed = instance.manualActualMs != null ||
            segments.contains(instance.id);
        if (timed) {
          timedByPass[instance.observationId] =
              (timedByPass[instance.observationId] ?? 0) + 1;
        }
      }

      return [
        for (final pass in passes)
          PassSummary(
            observation: pass,
            timedOperations: timedByPass[pass.id] ?? 0,
            totalOperations: total,
          ),
      ];
    });
  }

  Stream<Observation> watchById(String id) {
    return (_db.select(_db.observations)..where((t) => t.id.equals(id)))
        .watchSingle();
  }

  /// Opens the next pass of a study.
  ///
  /// The index comes from the study's own counter, **not from
  /// `MAX(sequenceIndex) + 1`** — that would hand a deleted pass's number
  /// straight back to the next one, and numbers are never reused (DESIGN.md
  /// §11.3). Reading and bumping the counter in one transaction is also what
  /// keeps two rapid presses from producing the same index, which the
  /// `{studyId, sequenceIndex}` unique key would reject.
  Future<Observation> addPass(String studyId) async {
    final pass = await _db.transaction(() async {
      final study = await (_db.select(_db.studies)
            ..where((t) => t.id.equals(studyId)))
          .getSingle();
      final now = DateTime.now();
      final created = await _db.into(_db.observations).insertReturning(
            ObservationsCompanion.insert(
              id: _uuid.v4(),
              studyId: studyId,
              sequenceIndex: study.nextPassIndex,
              performedAt: now,
              createdAt: now,
            ),
          );
      await (_db.update(_db.studies)..where((t) => t.id.equals(studyId)))
          .write(StudiesCompanion(
              nextPassIndex: Value(study.nextPassIndex + 1)));
      return created;
    });
    Diag.event('pass.add', 'pass=${pass.sequenceIndex + 1}');
    return pass;
  }

  /// Takes a pass out of the statistics, or puts it back.
  ///
  /// Non-destructive and reversible (DESIGN.md §11.3): the measurements stay, the
  /// pass keeps its own report and its rows in the Segments sheet, and only the
  /// aggregate ignores it. [reason] is stored beside the flag because "the line
  /// was starved" is the difference between a discarded pass and a suspicious
  /// one — and the analyst reading the report in a month is usually the one who
  /// needs telling.
  Future<void> setExcluded(String id, {required bool excluded, String? reason}) {
    final trimmed = reason?.trim();
    return (_db.update(_db.observations)..where((t) => t.id.equals(id)))
        .write(ObservationsCompanion(
      excludedAt: Value(excluded ? DateTime.now() : null),
      exclusionReason: Value(
          excluded && trimmed != null && trimmed.isNotEmpty ? trimmed : null),
    ));
  }

  /// Deletes a pass that never measured anything — one opened by mistake.
  ///
  /// Returns false and does nothing if the pass holds any time, or if it is the
  /// study's only pass. A pass with measurements is **excluded, not deleted**
  /// (§11.3), and the invariant that a study always has at least one pass (§11.1)
  /// is what lets everything downstream drop its null branch. The guard lives
  /// here rather than in the UI so neither can be bypassed by a second caller.
  Future<bool> deleteIfEmpty(String id) async {
    return _db.transaction(() async {
      final pass = await (_db.select(_db.observations)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (pass == null) return false;

      final siblings = await (_db.select(_db.observations)
            ..where((t) => t.studyId.equals(pass.studyId)))
          .get();
      if (siblings.length <= 1) return false;

      final segmented = await _segmentedInstanceIds(pass.studyId);
      final instances = await (_db.select(_db.operationInstances)
            ..where((t) => t.observationId.equals(id)))
          .get();
      final holdsTime = instances.any((i) =>
          i.manualActualMs != null || segmented.contains(i.id));
      if (holdsTime) return false;

      await (_db.delete(_db.observations)..where((t) => t.id.equals(id))).go();
      Diag.event('pass.delete', 'pass=${pass.sequenceIndex + 1}');
      return true;
    });
  }

  /// Ids of every operation instance in the study that has at least one segment.
  Future<Set<String>> _segmentedInstanceIds(String studyId) async {
    final seg = _db.operationTimeSegments;
    final inst = _db.operationInstances;
    final obs = _db.observations;
    final rows = await (_db.select(seg).join([
      innerJoin(inst, inst.id.equalsExp(seg.operationInstanceId)),
      innerJoin(obs, obs.id.equalsExp(inst.observationId)),
    ])
          ..where(obs.studyId.equals(studyId)))
        .get();
    return rows.map((r) => r.readTable(inst).id).toSet();
  }
}
