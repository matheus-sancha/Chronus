import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/observation_repository.dart';
import '../data/timing_repository.dart';

part 'timing_providers.g.dart';

@riverpod
TimingRepository timingRepository(Ref ref) {
  return TimingRepository(ref.watch(appDatabaseProvider));
}

@riverpod
ObservationRepository observationRepository(Ref ref) {
  return ObservationRepository(ref.watch(appDatabaseProvider));
}

/// Every pass of a study, in order, each with its completeness (§11.1).
final passesProvider =
    StreamProvider.family<List<PassSummary>, String>((ref, studyId) {
  return ref.watch(observationRepositoryProvider).watchPasses(studyId);
});

/// One pass by id — what a pass workspace titles itself from.
final passProvider =
    StreamProvider.family<Observation, String>((ref, observationId) {
  return ref.watch(observationRepositoryProvider).watchById(observationId);
});

/// Every instance in a study, across its passes — the sampling report's input.
final studyInstancesProvider =
    StreamProvider.family<List<OperationInstance>, String>((ref, studyId) {
  return ref.watch(timingRepositoryProvider).watchInstancesForStudy(studyId);
});

/// Every segment in a study, across its passes.
final studySegmentsProvider =
    StreamProvider.family<List<OperationTimeSegment>, String>((ref, studyId) {
  return ref.watch(timingRepositoryProvider).watchSegmentsForStudy(studyId);
});

// Hand-written (Drift-typed) providers — see projects_providers.dart.

/// A study's first pass, or null before any timing.
///
/// Keyed by study, unlike the two below — it is how a Time Study screen finds
/// the one pass it works in. §11.1 replaces it with a pass the route carries.
final observationProvider =
    StreamProvider.family<Observation?, String>((ref, studyId) {
  return ref.watch(timingRepositoryProvider).watchObservation(studyId);
});

/// Per-operation timing records within one pass.
final operationInstancesProvider =
    StreamProvider.family<List<OperationInstance>, String>((ref, observationId) {
  return ref.watch(timingRepositoryProvider).watchInstances(observationId);
});

/// Every timed segment in one pass (across all its operations).
final operationSegmentsProvider =
    StreamProvider.family<List<OperationTimeSegment>, String>(
        (ref, observationId) {
  return ref.watch(timingRepositoryProvider).watchSegments(observationId);
});
