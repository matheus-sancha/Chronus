import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/catalog/data/catalog_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalog;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    catalog = CatalogRepository(db);
  });
  tearDown(() => db.close());

  test('create, watch, update and delete an operation', () async {
    final op = await catalog.create(
      name: 'Load part',
      category: OperationCategory.productive,
      referenceStandardMs: 4500,
    );

    var list = await catalog.watchAll().first;
    expect(list, hasLength(1));
    expect(list.single.name, 'Load part');
    expect(list.single.category, OperationCategory.productive);
    expect(list.single.referenceStandardMs, 4500);

    await catalog.update(
      id: op.id,
      name: 'Load part (rev B)',
      category: OperationCategory.setup,
      referenceStandardMs: null,
    );
    final updated = await catalog.watchById(op.id).first;
    expect(updated.name, 'Load part (rev B)');
    expect(updated.category, OperationCategory.setup);
    expect(updated.referenceStandardMs, isNull);

    await catalog.delete(op.id);
    expect(await catalog.watchAll().first, isEmpty);
  });

  test('the 7 built-in waste subtypes are present', () async {
    final subtypes = await catalog.watchSubtypes().first;
    final builtIn = subtypes.where((s) => s.isBuiltIn).toList();
    expect(builtIn, hasLength(7));
    expect(
      builtIn.every((s) => s.category == OperationCategory.unproductive),
      isTrue,
    );
  });

  test('custom subtype can be added within a category', () async {
    final created = await catalog.createSubtype(
      category: OperationCategory.setup,
      name: 'Tool change',
    );
    expect(created.isBuiltIn, isFalse);

    final subtypes = await catalog.watchSubtypes().first;
    expect(
      subtypes.any(
        (s) => s.name == 'Tool change' && s.category == OperationCategory.setup,
      ),
      isTrue,
    );
  });

  test('deleting a catalog operation keeps its subtype', () async {
    final subtype = await catalog.createSubtype(
      category: OperationCategory.productive,
      name: 'Fixture',
    );
    final op = await catalog.create(
      name: 'Clamp',
      category: OperationCategory.productive,
      subtypeId: subtype.id,
    );

    await catalog.delete(op.id);

    final subtypes = await catalog.watchSubtypes().first;
    expect(subtypes.any((s) => s.id == subtype.id), isTrue);
  });
}
