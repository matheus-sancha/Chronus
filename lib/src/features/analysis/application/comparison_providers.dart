import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/comparison_repository.dart';
import 'cross_study_comparison.dart';

part 'comparison_providers.g.dart';

@riverpod
ComparisonRepository comparisonRepository(Ref ref) {
  return ComparisonRepository(ref.watch(appDatabaseProvider));
}

/// Studies in a project that can be compared, oldest first.
final comparisonCandidatesProvider =
    StreamProvider.family<List<Study>, String>((ref, projectId) {
  return ref.watch(comparisonRepositoryProvider).watchCandidates(projectId);
});

/// The comparison over a chosen set of studies.
///
/// Keyed by the study ids joined — a plain value, so Riverpod's family cache
/// recognises the same selection rather than rebuilding on every frame the way
/// a list identity would.
final crossStudyComparisonProvider =
    FutureProvider.family<CrossStudyComparison, String>((ref, key) async {
  final ids = key.isEmpty ? <String>[] : key.split(',');
  final inputs = await ref.watch(comparisonRepositoryProvider).load(ids);
  return buildCrossStudyComparison(inputs);
});

/// The cache key for [crossStudyComparisonProvider]: sorted, so the same set of
/// studies picked in a different order is the same comparison.
String comparisonKey(Iterable<String> studyIds) {
  final sorted = [...studyIds]..sort();
  return sorted.join(',');
}
