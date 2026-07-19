import 'package:chronus/src/app/app.dart';
import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/features/projects/application/projects_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to the Projects screen with an empty state',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Avoid touching the on-device database in a widget test.
          projectsListProvider.overrideWith((ref) => Stream.value(<Project>[])),
        ],
        child: const ChronusApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Projects'), findsWidgets);
    expect(
      find.text('No projects yet. Create your first one.'),
      findsOneWidget,
    );
  });
}
