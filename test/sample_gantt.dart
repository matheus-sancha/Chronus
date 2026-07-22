// Dev tool: renders the timeline Gantt to PNGs so the layout can be eyeballed
// without clicking through the app.
//
//   flutter test test/sample_gantt.dart
//
// Writes to build/samples/ (gitignored). Not named *_test.dart, so the normal
// `flutter test` run skips it — it asserts nothing, it draws.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/time_study_report.dart';
import 'package:chronus/src/features/analysis/presentation/timeline_gantt.dart';
import 'package:chronus/src/app/theme.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:chronus/src/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _outDir = Directory('build/samples');

StudyOperation _op(String id, String name, OperationCategory cat, double order) =>
    StudyOperation(
      id: id,
      studyId: 's',
      catalogOperationId: null,
      orderIndex: order,
      name: name,
      category: cat,
      subtypeId: null,
      referenceStandardMs: null,
      isUnplanned: false,
      createdAt: DateTime(2026),
    );

OperationTimeSegment _seg(String id, String instId, int start, int end) =>
    OperationTimeSegment(
      id: id,
      operationInstanceId: instId,
      startAtMs: start,
      endAtMs: end,
      createdAt: DateTime(2026),
    );

OperationInstance _inst(String opId, {int? manualMs}) => OperationInstance(
      id: 'i$opId',
      observationId: 'o',
      studyOperationId: opId,
      manualActualMs: manualMs,
      completedAt: DateTime(2026),
      notes: null,
      createdAt: DateTime(2026),
    );

/// A machining cycle exercising every case at once: concurrency (coolant wait
/// overlapping the finish mill), a pause/resume, an unattributed gap, a
/// forgot-to-start override, and an operation never timed live.
TimeStudyReport _mixed() {
  final base = DateTime(2026, 7, 21, 9, 30).millisecondsSinceEpoch;
  final segments = <OperationTimeSegment>[
    _seg('s1', 'iLOAD', base, base + 42000),
    _seg('s2', 'iROUGH', base + 44000, base + 150000),
    // Paused mid-cut, resumed 20 s later.
    _seg('s3', 'iFINISH', base + 152000, base + 210000),
    _seg('s4', 'iFINISH', base + 230000, base + 300000),
    // Runs concurrently with the finish mill.
    _seg('s5', 'iCOOL', base + 190000, base + 240000),
    // 30 s unattributed gap here.
    _seg('s6', 'iDEBURR', base + 330000, base + 380000),
    // Forgot to start: measured 8 s, reported 90 s.
    _seg('s7', 'iINSPECT', base + 382000, base + 390000),
  ];

  return buildTimeStudyReport(
    operations: [
      _op('LOAD', 'Load billet', OperationCategory.setup, 1),
      _op('ROUGH', 'Rough mill', OperationCategory.productive, 2),
      _op('FINISH', 'Finish mill (paused)', OperationCategory.productive, 3),
      _op('COOL', 'Coolant wait', OperationCategory.unproductive, 4),
      _op('DEBURR', 'Deburr edges', OperationCategory.productive, 5),
      _op('INSPECT', 'Inspect (override)', OperationCategory.productive, 6),
      _op('STAGE', 'Stage (not timed)', OperationCategory.productive, 7),
    ],
    timing: {
      'LOAD': OperationTiming(instance: _inst('LOAD'), segments: [segments[0]]),
      'ROUGH':
          OperationTiming(instance: _inst('ROUGH'), segments: [segments[1]]),
      'FINISH': OperationTiming(
          instance: _inst('FINISH'), segments: [segments[2], segments[3]]),
      'COOL': OperationTiming(instance: _inst('COOL'), segments: [segments[4]]),
      'DEBURR':
          OperationTiming(instance: _inst('DEBURR'), segments: [segments[5]]),
      'INSPECT': OperationTiming(
          instance: _inst('INSPECT', manualMs: 90000), segments: [segments[6]]),
      'STAGE': OperationTiming(
          instance: _inst('STAGE', manualMs: 45000), segments: const []),
    },
    subtypeById: const {},
    segments: segments,
    nowMs: base + 400000,
  );
}

/// A study transcribed from paper: nothing timed live, so the axis must stay
/// relative and every bar hatched.
TimeStudyReport _paper() => buildTimeStudyReport(
      operations: [
        _op('A', 'Load billet', OperationCategory.setup, 1),
        _op('B', 'Rough mill', OperationCategory.productive, 2),
        _op('C', 'Wait for crane', OperationCategory.unproductive, 3),
        _op('D', 'Inspect', OperationCategory.productive, 4),
      ],
      timing: {
        'A': OperationTiming(
            instance: _inst('A', manualMs: 40000), segments: const []),
        'B': OperationTiming(
            instance: _inst('B', manualMs: 120000), segments: const []),
        'C': OperationTiming(
            instance: _inst('C', manualMs: 55000), segments: const []),
        'D': OperationTiming(
            instance: _inst('D', manualMs: 70000), segments: const []),
      },
      subtypeById: const {},
      segments: const [],
    );

void main() {
  testWidgets('render the Gantt', (tester) async {
    // Every real async call in a widget test must go through runAsync — under
    // the fake-async binding a bare `await File...` future never completes.
    await tester.runAsync(() async {
      await _outDir.create(recursive: true);
      // The test environment ships no real font, so text would render as
      // placeholder boxes and the sample would be useless for eyeballing.
      for (final path in const [
        r'C:\Windows\Fonts\segoeui.ttf',
        '/System/Library/Fonts/Helvetica.ttc',
      ]) {
        final font = File(path);
        if (!font.existsSync()) continue;
        final loader = FontLoader('Roboto')
          ..addFont(Future.value(font.readAsBytesSync().buffer.asByteData()));
        await loader.load();
        break;
      }
    });

    Future<void> shot(
      String name,
      TimeStudyReport report, {
      required Size size,
      bool dark = false,
      bool inListView = false,
    }) async {
      await tester.binding.setSurfaceSize(size);
      final key = GlobalKey();
      // The real app theme, so the render reflects what ships — the hatch fill
      // in particular is drawn in the surface colour.
      final theme = dark ? ChronusTheme.dark() : ChronusTheme.light();
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme,
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              // Opaque, or the PNG comes out transparent and dark mode looks
              // identical to light.
              child: ColoredBox(
                color: theme.colorScheme.surface,
                child: inListView
                    ? ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text('(section above)'),
                          const SizedBox(height: 24),
                          TimelineGantt(report: report),
                          const SizedBox(height: 24),
                          const Text('(section below)'),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: TimelineGantt(report: report),
                      ),
              ),
            ),
          ),
        ),
      ));
      // pump, not pumpAndSettle: the chart is static, and the Tooltips keep
      // pumpAndSettle spinning forever. The second pump advances past
      // MaterialApp's AnimatedTheme lerp — without it a dark shot renders
      // mid-transition, still holding the previous (light) theme.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final file = File('${_outDir.path}/$name.png');
      // Both toImage AND toByteData must run inside runAsync — under the test
      // binding's fake async their futures never complete otherwise.
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      // ignore: avoid_print
      print('${file.path}  ${size.width.toInt()}x${size.height.toInt()}');
    }

    final mixed = _mixed();
    await shot('gantt-mixed', mixed, size: const Size(900, 400));
    // The report screen puts the chart in a ListView, which hands out
    // unbounded height and a scroll context — verify it survives that, not
    // just a standalone Center.
    await shot('gantt-in-listview', mixed,
        size: const Size(900, 400), inListView: true);
    await shot('gantt-mixed-dark', mixed,
        size: const Size(900, 400), dark: true);
    await shot('gantt-paper', _paper(), size: const Size(900, 320));
    // Below the 620 px minimum the chart should scroll, not compress.
    await shot('gantt-narrow', mixed, size: const Size(420, 400));

    // ignore: avoid_print
    print('mixed: elapsed=${mixed.totalElapsedMs} work=${mixed.totalWorkContentMs} '
        'simultaneous=${mixed.simultaneousMs} unattributed=${mixed.unattributedMs}');
  });
}
