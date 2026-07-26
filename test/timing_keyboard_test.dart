import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/catalog/application/catalog_providers.dart';
import 'package:chronus/src/features/media/application/media_providers.dart';
import 'package:chronus/src/features/settings/application/settings_providers.dart';
import 'package:chronus/src/features/studies/application/studies_providers.dart';
import 'package:chronus/src/features/studies/application/timing_providers.dart';
import 'package:chronus/src/features/studies/data/timing_repository.dart';
import 'package:chronus/src/features/studies/presentation/study_detail_screen.dart';
import 'package:chronus/src/l10n/generated/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Does the keyboard actually reach the timing engine?
///
/// The rule itself is unit-tested in `timing_repository_test.dart`; what cannot
/// be checked by reading is the *wiring*, and every risky assumption in it is
/// here:
///
/// * a `Shortcuts` widget inside the workspace beats `WidgetsApp`'s global
///   Space/Enter → activate-the-focused-button defaults,
/// * `autofocus` puts focus somewhere the shortcuts can see, so keys work on
///   arrival without a click,
/// * `ExcludeFocus` keeps row buttons out of traversal, so Space can never mean
///   "press ▶ again".
void main() {
  late _RecordingTiming timing;

  /// One throwaway database for every fake in the file. Drift warns when a second
  /// AppDatabase is constructed — harmless here, since this one is never queried,
  /// but sharing it keeps the warning (and the noise) out of the test output.
  final unusedDb = AppDatabase(NativeDatabase.memory());
  tearDownAll(() => unusedDb.close());

  Study study() => Study(
        id: 'study-1',
        projectId: 'p1',
        type: StudyType.timeStudy,
        name: 'Cell 4',
        performedAt: DateTime(2026, 7, 27),
        createdAt: DateTime(2026, 7, 27),
        updatedAt: DateTime(2026, 7, 27),
      );

  StudyOperation op(String id, double order) => StudyOperation(
        id: id,
        studyId: 'study-1',
        orderIndex: order,
        name: 'Op $id',
        category: OperationCategory.productive,
        isUnplanned: false,
        createdAt: DateTime(2026, 7, 27),
      );

  OperationInstance instance(String opId) => OperationInstance(
        id: 'inst-$opId',
        observationId: 'obs-1',
        studyOperationId: opId,
        createdAt: DateTime(2026, 7, 27),
      );

  OperationTimeSegment segment(String opId, {int? endAtMs}) =>
      OperationTimeSegment(
        id: 'seg-$opId',
        operationInstanceId: 'inst-$opId',
        startAtMs: 1000,
        endAtMs: endAtMs,
        createdAt: DateTime(2026, 7, 27),
      );

  /// Pumps the real screen with the real widget tree, faking only the data
  /// sources — so what is under test is the actual keyboard plumbing.
  Future<void> pump(
    WidgetTester tester, {
    required List<StudyOperation> ops,
    List<OperationInstance> instances = const [],
    List<OperationTimeSegment> segments = const [],
  }) async {
    timing = _RecordingTiming(
      db: unusedDb,
      instances: instances,
      segments: segments,
      hasObservation: instances.isNotEmpty,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timingRepositoryProvider.overrideWithValue(timing),
          studyByIdProvider('study-1').overrideWith((ref) => Stream.value(study())),
          studyOperationsProvider('study-1').overrideWith((ref) => Stream.value(ops)),
          subtypesProvider.overrideWith((ref) => Stream.value(const [])),
          operationMediaCountsProvider
              .overrideWith((ref) => Stream.value(const {})),
          appSettingsProvider.overrideWith((ref) => Stream.value(AppSetting(
                id: 0,
                timeUnit: TimeUnit.seconds,
                // Off, so a pace crossing cannot try to play audio in a test.
                alertSoundsEnabled: false,
                updatedAt: DateTime(2026, 7, 27),
              ))),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StudyDetailScreen(projectId: 'p1', studyId: 'study-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Space starts the first untimed operation, with no click first',
      (tester) async {
    await pump(tester, ops: [op('a', 1), op('b', 2)]);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    // Nothing was clicked: autofocus has to have put focus where the shortcuts
    // can see it, or an analyst arriving at the screen would press Space to no
    // effect.
    expect(timing.calls, ['start:a']);
  });

  testWidgets('Space laps the running operation', (tester) async {
    await pump(
      tester,
      ops: [op('a', 1), op('b', 2)],
      instances: [instance('a')],
      segments: [segment('a')], // open segment = running
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(timing.calls, ['lap:a']);
  });

  testWidgets('Space does nothing while two operations run, and says why',
      (tester) async {
    await pump(
      tester,
      ops: [op('a', 1), op('b', 2)],
      instances: [instance('a'), instance('b')],
      segments: [segment('a'), segment('b')],
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    // The whole point of the rule: no timer is touched.
    expect(timing.calls, isEmpty);
    expect(find.textContaining('Several operations running'), findsOneWidget);
  });

  testWidgets('Space still laps after clicking a row control', (tester) async {
    // The regression this guards: WidgetsApp maps Space to activating a focused
    // button, so a ▶ that kept focus after a click would make the lap key
    // silently re-start that operation instead of advancing the run.
    await pump(tester, ops: [op('a', 1), op('b', 2)]);

    await tester.tap(find.byIcon(Icons.play_arrow).first);
    await tester.pumpAndSettle();
    expect(timing.calls, ['start:a']);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    // 'start:a' again would mean the button had focus and Space pressed it.
    expect(timing.calls, ['start:a', 'start:a']);
  });

  testWidgets('arrow keys pick a row and Enter starts it', (tester) async {
    await pump(tester, ops: [op('a', 1), op('b', 2), op('c', 3)]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // a
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // b
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(timing.calls, ['start:b']);
  });

  testWidgets('S stops the picked row, and does nothing to an untimed one',
      (tester) async {
    await pump(
      tester,
      ops: [op('a', 1), op('b', 2)],
      instances: [instance('a')],
      segments: [segment('a')],
    );

    // Row b was never timed: stopping it would mark it complete with no
    // measurement behind it.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // wraps to last, b
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pump();
    expect(timing.calls, isEmpty);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // a
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pump();
    expect(timing.calls, ['stop:a']);
  });

  testWidgets('F1 opens the shortcuts sheet, and so does the app-bar icon',
      (tester) async {
    await pump(tester, ops: [op('a', 1)]);

    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    // The sheet explains the refusal, which otherwise reads as a bug.
    expect(find.textContaining('genuinely ambiguous'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsNothing);

    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
  });
}

/// A [TimingRepository] that records actions instead of performing them, and
/// serves fixed rows to the watch streams.
///
/// Subclassed rather than mocked: the streams are what the workspace builds from,
/// and the four actions are the whole surface the keyboard touches. The database
/// handed to `super` is never queried.
class _RecordingTiming extends TimingRepository {
  _RecordingTiming({
    required AppDatabase db,
    required this.instances,
    required this.segments,
    required this.hasObservation,
  }) : super(db);

  final List<OperationInstance> instances;
  final List<OperationTimeSegment> segments;
  final bool hasObservation;
  final calls = <String>[];

  @override
  Stream<Observation?> watchObservation(String studyId) => Stream.value(
        hasObservation
            ? Observation(
                id: 'obs-1',
                studyId: studyId,
                sequenceIndex: 1,
                performedAt: DateTime(2026, 7, 27),
                createdAt: DateTime(2026, 7, 27),
              )
            : null,
      );

  @override
  Stream<List<OperationInstance>> watchInstances(String observationId) =>
      Stream.value(instances);

  @override
  Stream<List<OperationTimeSegment>> watchSegments(String observationId) =>
      Stream.value(segments);

  @override
  Future<void> start({
    required String studyId,
    required String studyOperationId,
  }) async =>
      calls.add('start:$studyOperationId');

  @override
  Future<void> stop({
    required String studyId,
    required String studyOperationId,
  }) async =>
      calls.add('stop:$studyOperationId');

  @override
  Future<void> stopAndStartNext({
    required String studyId,
    required String studyOperationId,
  }) async =>
      calls.add('lap:$studyOperationId');
}
