import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/timing_repository.dart';

part 'timing_providers.g.dart';

@riverpod
TimingRepository timingRepository(Ref ref) {
  return TimingRepository(ref.watch(appDatabaseProvider));
}

// Hand-written (Drift-typed) providers — see projects_providers.dart.

/// The single Time Study observation for a study, or null before any timing.
final observationProvider =
    StreamProvider.family<Observation?, String>((ref, studyId) {
  return ref.watch(timingRepositoryProvider).watchObservation(studyId);
});

/// Per-operation timing records within an observation.
final operationInstancesProvider =
    StreamProvider.family<List<OperationInstance>, String>((ref, observationId) {
  return ref.watch(timingRepositoryProvider).watchInstances(observationId);
});

/// Every timed segment in an observation (across all its operations).
final operationSegmentsProvider =
    StreamProvider.family<List<OperationTimeSegment>, String>(
        (ref, observationId) {
  return ref.watch(timingRepositoryProvider).watchSegments(observationId);
});
