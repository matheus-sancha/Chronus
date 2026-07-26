import 'package:chronus/src/app/app.dart';
import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/projects/application/projects_providers.dart';
import 'package:chronus/src/features/settings/application/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to the Projects screen with an empty state',
      (tester) async {
    // Override with synchronous streams so no real database I/O is needed
    // (widget tests run under fake-async; a real Drift stream never emits here).
    final settings = AppSetting(
      id: 0,
      timeUnit: TimeUnit.seconds,
      alertSoundsEnabled: true,
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectsListProvider.overrideWith((ref) => Stream.value(<Project>[])),
          appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
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
