import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/features/studies/application/timing_providers.dart';
import 'package:chronus/src/features/studies/data/observation_repository.dart';
import 'package:chronus/src/features/studies/presentation/pass_list.dart';
import 'package:chronus/src/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pass list's own behaviour. The rules it enforces are unit-tested in
/// `observation_repository_test.dart`; what is here is what the analyst sees —
/// in particular that a pass carrying measurements is never OFFERED a delete,
/// because the repository refusing it after the fact is a worse experience than
/// not being asked (DESIGN.md §11.3).
void main() {
  Observation pass(
    int index, {
    DateTime? excludedAt,
    String? reason,
  }) =>
      Observation(
        id: 'obs-$index',
        studyId: 'study-1',
        sequenceIndex: index,
        performedAt: DateTime(2026, 7, 27, 8, 12),
        excludedAt: excludedAt,
        exclusionReason: reason,
        createdAt: DateTime(2026, 7, 27),
      );

  PassSummary summary(
    Observation observation, {
    int timed = 0,
    int total = 3,
  }) =>
      PassSummary(
        observation: observation,
        timedOperations: timed,
        totalOperations: total,
      );

  Future<void> pump(WidgetTester tester, List<PassSummary> passes) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          passesProvider('study-1').overrideWith((ref) => Stream.value(passes)),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PassList(projectId: 'p1', studyId: 'study-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('numbers passes from 1 and keeps the gaps a deletion left',
      (tester) async {
    // sequenceIndex 0, 1, 3 — pass 3 was deleted. The gap is deliberate: "Pass
    // 4" has to keep meaning the same pass (§11.3), so the list must not
    // renumber 4 down to 3.
    await pump(tester, [
      summary(pass(0), timed: 3),
      summary(pass(1), timed: 3),
      summary(pass(3), timed: 1),
    ]);

    expect(find.text('Pass 1'), findsOneWidget);
    expect(find.text('Pass 2'), findsOneWidget);
    expect(find.text('Pass 4'), findsOneWidget);
    expect(find.text('Pass 3'), findsNothing);
  });

  testWidgets('an excluded pass is badged and shows why, not hidden',
      (tester) async {
    await pump(tester, [
      summary(
        pass(0, excludedAt: DateTime(2026, 7, 27), reason: 'line starved'),
        timed: 3,
      ),
      summary(pass(1), timed: 3),
    ]);

    expect(find.text('Excluded'), findsOneWidget);
    // The reason travels with the row: the analyst reading this in a month is
    // usually the one who needs telling.
    expect(find.textContaining('line starved'), findsOneWidget);
    // Still listed and still openable — excluded is a state, not a deletion.
    expect(find.text('Pass 1'), findsOneWidget);
  });

  testWidgets('delete is offered only for an empty pass that is not the last',
      (tester) async {
    await pump(tester, [
      summary(pass(0), timed: 2), // has measurements
      summary(pass(1), timed: 0), // empty
    ]);

    // Pass 1 holds measurements: exclusion is the tool, so delete is disabled.
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    var item = tester.widget<PopupMenuItem<String>>(
      find.widgetWithText(PopupMenuItem<String>, 'Delete pass'),
    );
    expect(item.enabled, isFalse);
    expect(
      tester.widget<PopupMenuItem<String>>(
        find.widgetWithText(PopupMenuItem<String>, 'Exclude from statistics'),
      ).enabled,
      isTrue,
    );
    await tester.tapAt(const Offset(400, 20)); // dismiss
    await tester.pumpAndSettle();

    // Pass 2 measured nothing, and pass 1 remains: it can go.
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    item = tester.widget<PopupMenuItem<String>>(
      find.widgetWithText(PopupMenuItem<String>, 'Delete pass'),
    );
    expect(item.enabled, isTrue);
  });

  testWidgets('the only pass of a study can never be deleted', (tester) async {
    // Even empty. A study always keeps at least one pass (§11.1).
    await pump(tester, [summary(pass(0), timed: 0)]);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    final item = tester.widget<PopupMenuItem<String>>(
      find.widgetWithText(PopupMenuItem<String>, 'Delete pass'),
    );
    expect(item.enabled, isFalse);
  });

  testWidgets('an excluded pass offers to be put back', (tester) async {
    await pump(tester, [
      summary(pass(0, excludedAt: DateTime(2026, 7, 27)), timed: 3),
    ]);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Put back in the statistics'), findsOneWidget);
    expect(find.text('Exclude from statistics'), findsNothing);
  });
}
