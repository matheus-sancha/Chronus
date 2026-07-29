import 'package:drift/drift.dart';

import '../../../data/database/database.dart';
import '../../studies/application/timing_model.dart';
import '../application/cross_study_comparison.dart';
import '../application/sampling_report.dart';

/// Loads everything a cross-study comparison needs, for several studies at once.
///
/// **A future, not a stream** — deliberately, and the only read path in the app
/// that is. A comparison is a snapshot of finished work being read side by side;
/// nothing on the screen is being timed, so there is nothing to keep live. The
/// alternative is four streams per study recombining on every keystroke of an
/// unrelated run, which costs real work to deliver an update nobody is waiting
/// for.
class ComparisonRepository {
  ComparisonRepository(this._db);

  final AppDatabase _db;

  /// Every study in a project that could take part in a comparison.
  Stream<List<Study>> watchCandidates(String projectId) {
    return (_db.select(_db.studies)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([(t) => OrderingTerm.asc(t.performedAt)]))
        .watch();
  }

  /// Assembles one [ComparisonInput] per study id, in five queries total rather
  /// than four per study.
  Future<List<ComparisonInput>> load(List<String> studyIds) async {
    if (studyIds.isEmpty) return const [];

    final studies = await (_db.select(_db.studies)
          ..where((t) => t.id.isIn(studyIds)))
        .get();
    final operations = await (_db.select(_db.studyOperations)
          ..where((t) => t.studyId.isIn(studyIds)))
        .get();
    final passes = await (_db.select(_db.observations)
          ..where((t) => t.studyId.isIn(studyIds))
          ..orderBy([(t) => OrderingTerm.asc(t.sequenceIndex)]))
        .get();
    final subtypes = await _db.select(_db.operationSubtypes).get();

    final passIds = passes.map((p) => p.id).toList();
    final instances = passIds.isEmpty
        ? <OperationInstance>[]
        : await (_db.select(_db.operationInstances)
              ..where((t) => t.observationId.isIn(passIds)))
            .get();

    final instanceIds = instances.map((i) => i.id).toList();
    final segments = instanceIds.isEmpty
        ? <OperationTimeSegment>[]
        : await (_db.select(_db.operationTimeSegments)
              ..where((t) => t.operationInstanceId.isIn(instanceIds)))
            .get();

    final segmentsByInstance = <String, List<OperationTimeSegment>>{};
    for (final segment in segments) {
      (segmentsByInstance[segment.operationInstanceId] ??= []).add(segment);
    }
    final instancesByPass = <String, List<OperationInstance>>{};
    for (final instance in instances) {
      (instancesByPass[instance.observationId] ??= []).add(instance);
    }
    final operationsByStudy = <String, List<StudyOperation>>{};
    for (final operation in operations) {
      (operationsByStudy[operation.studyId] ??= []).add(operation);
    }
    final passesByStudy = <String, List<Observation>>{};
    for (final pass in passes) {
      (passesByStudy[pass.studyId] ??= []).add(pass);
    }
    final subtypeById = {for (final s in subtypes) s.id: s};

    return [
      for (final study in studies)
        ComparisonInput(
          study: study,
          operations: operationsByStudy[study.id] ?? const [],
          // Built through the sampling report whatever the study's type: a Time
          // Study is a study with one pass, so its representative time and its
          // n=1 fall out of the same code (§11.9).
          report: buildSamplingReport(
            operations: operationsByStudy[study.id] ?? const [],
            passes: [
              for (final pass in passesByStudy[study.id] ?? const [])
                PassTiming(
                  observation: pass,
                  timingByOperation: timingByOperation(
                    instances: instancesByPass[pass.id] ?? const [],
                    segments: [
                      for (final instance
                          in instancesByPass[pass.id] ?? const [])
                        ...?segmentsByInstance[instance.id],
                    ],
                  ),
                ),
            ],
            subtypeById: subtypeById,
            confidenceLevel: study.confidenceLevel,
            relativePrecision: study.relativePrecision,
          ),
        ),
    ];
  }
}
