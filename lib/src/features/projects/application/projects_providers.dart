import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/project_repository.dart';

part 'projects_providers.g.dart';

@riverpod
ProjectRepository projectRepository(Ref ref) {
  return ProjectRepository(ref.watch(appDatabaseProvider));
}

/// The reactive list of projects, driven by the Drift stream.
///
/// Hand-written (not codegen) on purpose: riverpod_generator cannot emit a
/// provider whose return type references a Drift-generated class ([Project]),
/// because that class is produced by a different builder within the same
/// build_runner pass. A plain [StreamProvider] sidesteps that ordering — the
/// generator only inspects `@riverpod`-annotated elements.
final projectsListProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAll();
});
