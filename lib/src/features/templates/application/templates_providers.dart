import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/template_repository.dart';

part 'templates_providers.g.dart';

@riverpod
TemplateRepository templateRepository(Ref ref) {
  return TemplateRepository(ref.watch(appDatabaseProvider));
}

// Hand-written (Drift-typed) providers — see projects_providers.dart.

final templatesListProvider = StreamProvider<List<Template>>((ref) {
  return ref.watch(templateRepositoryProvider).watchAll();
});

final templateByIdProvider =
    StreamProvider.family<Template, String>((ref, id) {
  return ref.watch(templateRepositoryProvider).watchById(id);
});

final templateOperationsProvider =
    StreamProvider.family<List<TemplateOperation>, String>((ref, templateId) {
  return ref.watch(templateRepositoryProvider).watchOperations(templateId);
});
