import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/database/database.dart';
import '../../../data/database/database_providers.dart';
import '../data/catalog_repository.dart';

part 'catalog_providers.g.dart';

@riverpod
CatalogRepository catalogRepository(Ref ref) {
  return CatalogRepository(ref.watch(appDatabaseProvider));
}

// Hand-written (Drift-typed) providers — see projects_providers.dart.

final catalogListProvider = StreamProvider<List<CatalogOperation>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchAll();
});

final catalogByIdProvider =
    StreamProvider.family<CatalogOperation, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).watchById(id);
});

/// All classification subtypes (built-ins first, then custom), for pickers.
final subtypesProvider = StreamProvider<List<OperationSubtype>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchSubtypes();
});
