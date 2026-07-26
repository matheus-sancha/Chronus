import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/database.dart';
import '../../diagnostics/application/diagnostics.dart';

/// The **per-operation timing engine** (snapback model). Each operation is
/// started, paused, stopped and reset independently, and several may run at the
/// same time (two operators, or man + machine). An operation's measured time is
/// the SUM of its [OperationTimeSegment]s; pause closes the open segment, a
/// (re)start opens a new one. The database is the single source of truth, so a
/// run survives backgrounding and resumes on reopen.
///
/// Timing lives inside one [Observation] per study (created lazily on the first
/// action). The Sampling Study — many observations — reuses this same engine.
///
/// Derived state (pending / running / paused / done, observed time, wall-clock
/// total) lives in `timing_model.dart` as pure functions over the rows these
/// streams expose, so it is trivially testable and shared with the UI.
class TimingRepository {
  TimingRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // --- streams --------------------------------------------------------------

  /// The single Time Study observation for [studyId], or null before any timing.
  Stream<Observation?> watchObservation(String studyId) {
    return (_db.select(_db.observations)
          ..where((t) => t.studyId.equals(studyId))
          ..orderBy([(t) => OrderingTerm.asc(t.sequenceIndex)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Per-operation timing records within an observation.
  Stream<List<OperationInstance>> watchInstances(String observationId) {
    return (_db.select(_db.operationInstances)
          ..where((t) => t.observationId.equals(observationId)))
        .watch();
  }

  /// Every timed segment in an observation (across all its operations).
  Stream<List<OperationTimeSegment>> watchSegments(String observationId) {
    final seg = _db.operationTimeSegments;
    final inst = _db.operationInstances;
    final query = _db.select(seg).join([
      innerJoin(inst, inst.id.equalsExp(seg.operationInstanceId)),
    ])
      ..where(inst.observationId.equals(observationId));
    return query.watch().map((rows) => rows.map((r) => r.readTable(seg)).toList());
  }

  // --- per-operation controls ----------------------------------------------

  /// Start or resume timing an operation: opens a new segment. Idempotent while
  /// already running. Resuming a previously-stopped operation reopens it.
  Future<void> start({
    required String studyId,
    required String studyOperationId,
  }) async {
    await _db.transaction(() async {
      final observationId = await _ensureObservation(studyId);
      final instanceId = await _ensureInstance(observationId, studyOperationId);
      if (await _openSegment(instanceId) != null) return; // already running
      final now = DateTime.now();
      await _db.into(_db.operationTimeSegments).insert(
            OperationTimeSegmentsCompanion.insert(
              id: _uuid.v4(),
              operationInstanceId: instanceId,
              startAtMs: now.millisecondsSinceEpoch,
              createdAt: now,
            ),
          );
      await (_db.update(_db.operationInstances)
            ..where((t) => t.id.equals(instanceId)))
          .write(const OperationInstancesCompanion(completedAt: Value(null)));
    });
    // Breadcrumbs for the diagnostics log (DESIGN.md §10): ids only, never the
    // operation's name. Enough to reconstruct a run's shape — including the
    // concurrency and pauses that make timing bugs hard to describe in words.
    Diag.event('timer.start', 'op=${Diag.shortId(studyOperationId)}');
  }

  /// Pause: close the open segment. Elapsed is preserved; the operation stays
  /// resumable (not marked complete).
  Future<void> pause({
    required String studyId,
    required String studyOperationId,
  }) async {
    await _withInstance(studyId, studyOperationId, (instanceId) async {
      await _closeOpenSegment(instanceId);
    });
    Diag.event('timer.pause', 'op=${Diag.shortId(studyOperationId)}');
  }

  /// Stop: close the open segment and mark the operation complete.
  Future<void> stop({
    required String studyId,
    required String studyOperationId,
  }) async {
    await _db.transaction(() async {
      final observationId = await _ensureObservation(studyId);
      final instanceId = await _ensureInstance(observationId, studyOperationId);
      await _closeOpenSegment(instanceId);
      await (_db.update(_db.operationInstances)
            ..where((t) => t.id.equals(instanceId)))
          .write(OperationInstancesCompanion(
              completedAt: Value(DateTime.now())));
    });
    Diag.event('timer.stop', 'op=${Diag.shortId(studyOperationId)}');
  }

  /// Convenience for the common sequential path: stop the current operation and
  /// immediately start the next PENDING one (untouched, by order) at the SAME
  /// instant — so a straight run is gapless, like a lap. If nothing pending
  /// remains, it just stops. Operations already running/paused/done are skipped.
  Future<void> stopAndStartNext({
    required String studyId,
    required String studyOperationId,
  }) async {
    String? startedNext;
    await _db.transaction(() async {
      final observationId = await _ensureObservation(studyId);
      final currentId = await _ensureInstance(observationId, studyOperationId);
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      // Stop current at `nowMs` and mark it complete.
      await (_db.update(_db.operationTimeSegments)
            ..where((t) =>
                t.operationInstanceId.equals(currentId) & t.endAtMs.isNull()))
          .write(OperationTimeSegmentsCompanion(endAtMs: Value(nowMs)));
      await (_db.update(_db.operationInstances)
            ..where((t) => t.id.equals(currentId)))
          .write(OperationInstancesCompanion(completedAt: Value(DateTime.now())));

      // Open the next pending operation at the SAME instant (continuous).
      final next = await _nextPendingOperation(
          studyId, observationId, studyOperationId);
      if (next != null) {
        final nextId = await _ensureInstance(observationId, next.id);
        await _db.into(_db.operationTimeSegments).insert(
              OperationTimeSegmentsCompanion.insert(
                id: _uuid.v4(),
                operationInstanceId: nextId,
                startAtMs: nowMs,
                createdAt: DateTime.now(),
              ),
            );
        startedNext = next.id;
      }
    });
    // Logged as one event, because it is one action: the pair is what makes a
    // run gapless, and splitting it would read as a stop that happened to be
    // followed by a start.
    Diag.event(
      'timer.lap',
      'op=${Diag.shortId(studyOperationId)} '
          'next=${startedNext == null ? 'none' : Diag.shortId(startedNext!)}',
    );
  }

  /// Reset: zero & discard the operation's measured segments and clear its
  /// completion. The manual override (if any) is left untouched.
  Future<void> reset({
    required String studyId,
    required String studyOperationId,
  }) async {
    await _withInstance(studyId, studyOperationId, (instanceId) async {
      await (_db.delete(_db.operationTimeSegments)
            ..where((t) => t.operationInstanceId.equals(instanceId)))
          .go();
      await (_db.update(_db.operationInstances)
            ..where((t) => t.id.equals(instanceId)))
          .write(const OperationInstancesCompanion(completedAt: Value(null)));
    });
    // Worth a breadcrumb precisely because it destroys evidence: a report of
    // "the time was wrong" reads very differently once the log shows a reset.
    Diag.event('timer.reset', 'op=${Diag.shortId(studyOperationId)}');
  }

  // --- manual override ------------------------------------------------------

  /// Non-destructively override the actual time (segments are preserved and
  /// keep counting for audit; the override just shadows their sum).
  Future<void> setManualActual({
    required String studyId,
    required String studyOperationId,
    required int milliseconds,
  }) async {
    await _db.transaction(() async {
      final observationId = await _ensureObservation(studyId);
      final instanceId = await _ensureInstance(observationId, studyOperationId);
      await (_db.update(_db.operationInstances)
            ..where((t) => t.id.equals(instanceId)))
          .write(OperationInstancesCompanion(
              manualActualMs: Value(milliseconds)));
    });
    // The one number in a report that was typed rather than measured, so the log
    // records that it was typed — not what it said.
    Diag.event('timer.override', 'op=${Diag.shortId(studyOperationId)}');
  }

  /// Ensures a timing instance exists for an operation and returns its id, so
  /// callers (e.g. attaching photos) have a stable owner id even before the
  /// operation has been timed.
  Future<String> ensureInstanceId({
    required String studyId,
    required String studyOperationId,
  }) async {
    return _db.transaction(() async {
      final observationId = await _ensureObservation(studyId);
      return _ensureInstance(observationId, studyOperationId);
    });
  }

  /// Set (or clear, with a null/blank value) a free-form note about the
  /// operation. Lazily creates the instance so a note can be added to an
  /// operation that has never been timed.
  Future<void> setNote({
    required String studyId,
    required String studyOperationId,
    required String? note,
  }) async {
    final value = (note == null || note.trim().isEmpty) ? null : note.trim();
    await _db.transaction(() async {
      final observationId = await _ensureObservation(studyId);
      final instanceId = await _ensureInstance(observationId, studyOperationId);
      await (_db.update(_db.operationInstances)
            ..where((t) => t.id.equals(instanceId)))
          .write(OperationInstancesCompanion(notes: Value(value)));
    });
  }

  /// Remove the override, falling back to the measured segment sum.
  Future<void> clearManualActual({
    required String studyId,
    required String studyOperationId,
  }) async {
    await _withInstance(studyId, studyOperationId, (instanceId) async {
      await (_db.update(_db.operationInstances)
            ..where((t) => t.id.equals(instanceId)))
          .write(const OperationInstancesCompanion(
              manualActualMs: Value(null)));
    });
  }

  /// Throw the whole run away: delete the observation (instances + segments
  /// cascade) and the unplanned operations that only existed for it.
  Future<void> discardRun(String studyId) async {
    await _db.transaction(() async {
      final observationId = await _observationId(studyId);
      if (observationId != null) {
        await (_db.delete(_db.observations)
              ..where((t) => t.id.equals(observationId)))
            .go();
      }
      await (_db.delete(_db.studyOperations)
            ..where(
                (t) => t.studyId.equals(studyId) & t.isUnplanned.equals(true)))
          .go();
    });
  }

  // --- orphaned segments ----------------------------------------------------

  /// Segments left open because the app closed while they were still running.
  ///
  /// This exists because §3.5's absolute timestamps mean an open segment keeps
  /// counting from its original start — which is right for backgrounding on iOS,
  /// and a trap on Windows, where **closing the window is how you leave**. An
  /// operation started at 16:40 and abandoned reads sixteen hours the next
  /// morning, and that fiction is indistinguishable from measurement: it flows
  /// into the report, the wall-clock span, the simultaneous sweep, the Gantt and
  /// the XLSX Segments sheet **unhatched**, because it is a real segment.
  ///
  /// Checked at startup so the analyst is told rather than silently handed wrong
  /// numbers (DESIGN.md §10).
  Future<OrphanedTiming?> orphanedTiming() async {
    final rows = await (_db.select(_db.operationTimeSegments)
          ..where((t) => t.endAtMs.isNull()))
        .get();
    if (rows.isEmpty) return null;
    final earliest =
        rows.map((s) => s.startAtMs).reduce((a, b) => a < b ? a : b);
    return OrphanedTiming(
      operations: rows.map((s) => s.operationInstanceId).toSet().length,
      since: DateTime.fromMillisecondsSinceEpoch(earliest),
    );
  }

  /// Deletes every open segment.
  ///
  /// Deliberately a delete and not a close-at-now. DESIGN.md §5 already settled
  /// the principle for the Segments sheet — "fabricated time is deliberately
  /// absent; it is not a segment" — and a segment whose end was never observed
  /// is fabricated by that same standard. Closing it at `now` would persist the
  /// fiction as evidence, flagged at best.
  ///
  /// Other segments of the same operation survive, so an operation paused twice
  /// and then abandoned keeps the two intervals that really were measured. An
  /// operation left with none returns to pending, and the analyst re-times it or
  /// enters a manual override.
  Future<void> discardOrphanedTiming() async {
    final deleted = await (_db.delete(_db.operationTimeSegments)
          ..where((t) => t.endAtMs.isNull()))
        .go();
    Diag.event('orphan.discarded', 'segments=$deleted');
  }

  // --- internals ------------------------------------------------------------

  Future<void> _withInstance(
    String studyId,
    String studyOperationId,
    Future<void> Function(String instanceId) action,
  ) async {
    await _db.transaction(() async {
      final observationId = await _observationId(studyId);
      if (observationId == null) return;
      final instance = await _instance(observationId, studyOperationId);
      if (instance == null) return;
      await action(instance.id);
    });
  }

  /// The next operation after [afterStudyOperationId] (by order) that is still
  /// PENDING — no segments, not completed, no manual override. Null if none.
  Future<StudyOperation?> _nextPendingOperation(
    String studyId,
    String observationId,
    String afterStudyOperationId,
  ) async {
    final ops = await (_db.select(_db.studyOperations)
          ..where((t) => t.studyId.equals(studyId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    final currentIndex = ops.indexWhere((o) => o.id == afterStudyOperationId);
    if (currentIndex < 0) return null;
    final currentOrder = ops[currentIndex].orderIndex;

    final instances = await (_db.select(_db.operationInstances)
          ..where((t) => t.observationId.equals(observationId)))
        .get();
    final instanceByOp = {for (final i in instances) i.studyOperationId: i};
    final segments = await _segmentsForObservation(observationId);
    final instancesWithSegments =
        segments.map((s) => s.operationInstanceId).toSet();

    for (final op in ops) {
      if (op.orderIndex <= currentOrder) continue;
      final instance = instanceByOp[op.id];
      if (instance == null) return op; // never touched
      final pending = !instancesWithSegments.contains(instance.id) &&
          instance.completedAt == null &&
          instance.manualActualMs == null;
      if (pending) return op;
    }
    return null;
  }

  Future<List<OperationTimeSegment>> _segmentsForObservation(
      String observationId) async {
    final seg = _db.operationTimeSegments;
    final inst = _db.operationInstances;
    final rows = await (_db.select(seg).join([
      innerJoin(inst, inst.id.equalsExp(seg.operationInstanceId)),
    ])
          ..where(inst.observationId.equals(observationId)))
        .get();
    return rows.map((r) => r.readTable(seg)).toList();
  }

  Future<String?> _observationId(String studyId) async {
    final obs = await (_db.select(_db.observations)
          ..where((t) => t.studyId.equals(studyId))
          ..orderBy([(t) => OrderingTerm.asc(t.sequenceIndex)])
          ..limit(1))
        .getSingleOrNull();
    return obs?.id;
  }

  Future<String> _ensureObservation(String studyId) async {
    final existing = await _observationId(studyId);
    if (existing != null) return existing;
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.into(_db.observations).insert(
          ObservationsCompanion.insert(
            id: id,
            studyId: studyId,
            sequenceIndex: 0,
            performedAt: now,
            createdAt: now,
          ),
        );
    return id;
  }

  Future<OperationInstance?> _instance(
    String observationId,
    String studyOperationId,
  ) {
    return (_db.select(_db.operationInstances)
          ..where((t) =>
              t.observationId.equals(observationId) &
              t.studyOperationId.equals(studyOperationId)))
        .getSingleOrNull();
  }

  Future<String> _ensureInstance(
    String observationId,
    String studyOperationId,
  ) async {
    final existing = await _instance(observationId, studyOperationId);
    if (existing != null) return existing.id;
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db.into(_db.operationInstances).insert(
          OperationInstancesCompanion.insert(
            id: id,
            observationId: observationId,
            studyOperationId: studyOperationId,
            createdAt: now,
          ),
        );
    return id;
  }

  Future<OperationTimeSegment?> _openSegment(String instanceId) {
    return (_db.select(_db.operationTimeSegments)
          ..where((t) =>
              t.operationInstanceId.equals(instanceId) & t.endAtMs.isNull()))
        .getSingleOrNull();
  }

  Future<void> _closeOpenSegment(String instanceId) async {
    await (_db.update(_db.operationTimeSegments)
          ..where((t) =>
              t.operationInstanceId.equals(instanceId) & t.endAtMs.isNull()))
        .write(OperationTimeSegmentsCompanion(
            endAtMs: Value(DateTime.now().millisecondsSinceEpoch)));
  }
}

/// What was left running when the app last closed.
///
/// Counted by **operation**, not by segment, because that is what the analyst
/// recognises — one operation paused and resumed twice is still one thing they
/// forgot to stop.
class OrphanedTiming {
  const OrphanedTiming({required this.operations, required this.since});

  final int operations;

  /// When the earliest of them started — i.e. how long the app has been
  /// counting. Shown to the analyst, because the age is what makes it obvious
  /// the time is not real.
  final DateTime since;
}
