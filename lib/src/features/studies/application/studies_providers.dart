import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/study_operation_repository.dart';
import '../data/study_repository.dart';

part 'studies_providers.g.dart';

@riverpod
StudyRepository studyRepository(Ref ref) {
  return StudyRepository(ref.watch(appDatabaseProvider));
}

@riverpod
StudyOperationRepository studyOperationRepository(Ref ref) {
  return StudyOperationRepository(ref.watch(appDatabaseProvider));
}

// Hand-written (not codegen) because these return Drift-generated types — see
// projects_providers.dart for the why.

/// Studies within a project.
final studiesByProjectProvider =
    StreamProvider.family<List<Study>, String>((ref, projectId) {
  return ref.watch(studyRepositoryProvider).watchByProject(projectId);
});

/// A single study by id.
final studyByIdProvider =
    StreamProvider.family<Study, String>((ref, studyId) {
  return ref.watch(studyRepositoryProvider).watchById(studyId);
});

/// A study's ordered operation sequence.
final studyOperationsProvider =
    StreamProvider.family<List<StudyOperation>, String>((ref, studyId) {
  return ref.watch(studyOperationRepositoryProvider).watchByStudy(studyId);
});

/// The editable Process Type picklist, in display order. Reference data read
/// directly (a dedicated ReferenceRepository can absorb this when the catalog
/// slice adds option management).
final processTypeOptionsProvider =
    StreamProvider<List<ProcessTypeOption>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.processTypeOptions)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();
});
