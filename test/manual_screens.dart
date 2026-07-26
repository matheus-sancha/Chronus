// Dev tool: renders the app's real screens to PNGs for the user manual
// (docs/MANUAL-pt.md and docs/MANUAL-en.md).
//
//   flutter test test/manual_screens.dart
//
// Writes to docs/manual/images/, which IS committed — the manuals reference
// these files. Deliberately not named *_test.dart, so `flutter test` skips it:
// it asserts nothing, it draws.
//
// Why render rather than screenshot the running app: the manual has to be
// regenerated every time the UI moves, and a hand-captured screenshot rots
// silently. These come out of the same widgets that ship, over one fixture, so
// a screen that changes shape shows up here on the next run.
//
// The fixture is the same machining cycle used by test/sample_export.dart, and
// it is deliberately awkward: the coolant wait overlaps the finish mill
// (concurrency), the finish mill is paused mid-cut, there is an unattributed
// gap before deburring, the inspection carries a manual override, and the last
// operation was never timed live. Those are exactly the cases the manual has to
// explain, so the screenshots have to contain them.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:chronus/src/app/theme.dart';
import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/time_study_report.dart';
import 'package:chronus/src/features/analysis/presentation/time_study_report_screen.dart';
import 'package:chronus/src/features/analysis/presentation/timeline_gantt.dart';
import 'package:chronus/src/features/catalog/application/catalog_providers.dart';
import 'package:chronus/src/features/catalog/presentation/catalog_screen.dart';
import 'package:chronus/src/features/media/application/media_providers.dart';
import 'package:chronus/src/features/projects/application/projects_providers.dart';
import 'package:chronus/src/features/projects/presentation/projects_screen.dart';
import 'package:chronus/src/features/settings/application/settings_providers.dart';
import 'package:chronus/src/features/settings/presentation/settings_screen.dart';
import 'package:chronus/src/features/studies/application/alert_sound.dart';
import 'package:chronus/src/features/studies/application/studies_providers.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:chronus/src/features/studies/application/timing_providers.dart';
import 'package:chronus/src/features/studies/presentation/study_detail_screen.dart';
import 'package:chronus/src/features/templates/application/templates_providers.dart';
import 'package:chronus/src/data/database/database_providers.dart';
import 'package:chronus/src/l10n/generated/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _outDir = Directory('docs/manual/images');

const _projectId = 'proj-cell4';
const _studyId = 'study-bracket-a';
const _obsId = 'obs-1';

/// Wall-clock origin for the fixture: 21 Jul 2026, 09:30.
final _base = DateTime(2026, 7, 21, 9, 30).millisecondsSinceEpoch;

// --- fixture ---------------------------------------------------------------

/// name, category, subtype, reference standard ms
typedef _OpSpec = (String, OperationCategory, String?, int?);

List<_OpSpec> _opSpecs(bool pt) => [
      (
        pt ? 'Carregar bloco no dispositivo' : 'Load billet into fixture',
        OperationCategory.setup,
        null,
        40000
      ),
      (
        pt ? 'Desbaste — faceamento' : 'Rough mill — face',
        OperationCategory.productive,
        null,
        190000
      ),
      (
        pt ? 'Acabamento — cavidade' : 'Finish mill — pocket',
        OperationCategory.productive,
        null,
        220000
      ),
      (
        pt ? 'Espera — recuperação do fluido' : 'Wait for coolant recovery',
        OperationCategory.unproductive,
        'waiting',
        null
      ),
      (
        pt ? 'Rebarbar arestas' : 'Deburr edges',
        OperationCategory.productive,
        null,
        80000
      ),
      (
        pt ? 'Inspeção — CMM' : 'Inspect — CMM check',
        OperationCategory.productive,
        null,
        105000
      ),
      (
        pt ? 'Preparar próxima célula' : 'Stage for next cell',
        OperationCategory.productive,
        null,
        null
      ),
    ];

/// Everything the screens read, assembled once per language.
class _Fx {
  _Fx(this.pt);

  final bool pt;

  static const ids = [
    'op-load',
    'op-rough',
    'op-finish',
    'op-cool',
    'op-deburr',
    'op-inspect',
    'op-stage',
  ];

  AppSetting get settings => AppSetting(
        id: 0,
        timeUnit: TimeUnit.seconds,
        defaultAnalyst: 'M. Sancha',
        alertSoundsEnabled: true,
        updatedAt: DateTime(2026),
      );

  List<Project> get projects => [
        Project(
          id: _projectId,
          name: pt ? 'Célula 4 — linha de suportes' : 'Cell 4 — bracket line',
          notes: null,
          createdAt: DateTime(2026, 7, 20),
          updatedAt: DateTime(2026, 7, 21),
        ),
        Project(
          id: 'proj-weld',
          name: pt ? 'Solda — gabaritos de chassi' : 'Weld shop — frame jigs',
          notes: null,
          createdAt: DateTime(2026, 7, 14),
          updatedAt: DateTime(2026, 7, 18),
        ),
      ];

  List<OperationSubtype> get subtypes => [
        OperationSubtype(
          id: 'waiting',
          category: OperationCategory.unproductive,
          name: pt ? 'Espera' : 'Waiting',
          isBuiltIn: true,
          createdAt: DateTime(2026),
        ),
        OperationSubtype(
          id: 'motion',
          category: OperationCategory.unproductive,
          name: pt ? 'Movimentação' : 'Motion',
          isBuiltIn: true,
          createdAt: DateTime(2026),
        ),
        OperationSubtype(
          id: 'transport',
          category: OperationCategory.unproductive,
          name: pt ? 'Transporte' : 'Transportation',
          isBuiltIn: true,
          createdAt: DateTime(2026),
        ),
      ];

  List<CatalogOperation> get catalog => [
        for (var i = 0; i < _opSpecs(pt).length; i++)
          () {
            final (name, category, subtypeId, reference) = _opSpecs(pt)[i];
            return CatalogOperation(
              id: 'cat-$i',
              name: name,
              category: category,
              subtypeId: subtypeId,
              referenceStandardMs: reference,
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            );
          }(),
      ];

  List<ProcessTypeOption> get processTypes => [
        for (final (i, name) in (pt
                ? ['Usinagem', 'Solda', 'Montagem e teste', 'Inspeção']
                : ['Machining', 'Welding', 'Assembly & Testing', 'Inspection'])
            .indexed)
          ProcessTypeOption(
            id: 'pt-$i',
            name: name,
            isBuiltIn: true,
            sortOrder: i,
            createdAt: DateTime(2026),
          ),
      ];

  Study get study => Study(
        id: _studyId,
        projectId: _projectId,
        type: StudyType.timeStudy,
        name: pt
            ? 'Célula 4 — suporte A, referência'
            : 'Cell 4 — bracket A baseline',
        performedAt: DateTime(2026, 7, 21, 9, 30),
        analyst: 'M. Sancha',
        partProduct: pt ? 'Suporte A / 55-2201' : 'Bracket A / 55-2201',
        processOperation: pt ? 'Usinar e inspecionar' : 'Mill & inspect',
        machineWorkstation: 'Haas VF-2 (CNC-2)',
        lineCell: pt ? 'Célula 4' : 'Cell 4',
        operatorName: 'J. Ribeiro',
        shift: pt ? '1º turno' : '1st shift',
        workOrderNumber: 'WO-88134',
        processType: pt ? 'Usinagem' : 'Machining',
        notes: pt
            ? 'Referência antes da troca do dispositivo.'
            : 'Baseline before the fixture change.',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  Observation get observation => Observation(
        id: _obsId,
        studyId: _studyId,
        sequenceIndex: 1,
        performedAt: DateTime(2026, 7, 21, 9, 30),
        notes: null,
        createdAt: DateTime(2026),
      );

  List<StudyOperation> get operations => [
        for (var i = 0; i < _opSpecs(pt).length; i++)
          () {
            final (name, category, subtypeId, reference) = _opSpecs(pt)[i];
            return StudyOperation(
              id: ids[i],
              studyId: _studyId,
              catalogOperationId: 'cat-$i',
              orderIndex: i + 1,
              name: name,
              category: category,
              subtypeId: subtypeId,
              referenceStandardMs: reference,
              isUnplanned: false,
              createdAt: DateTime(2026),
            );
          }(),
      ];

  /// Segment layout. The finish mill is two segments (paused 20 s mid-cut), the
  /// coolant wait overlaps it, and a 30 s unattributed gap precedes deburring.
  List<OperationTimeSegment> get segments => [
        _seg('sg1', 'inst-op-load', 0, 42000),
        _seg('sg2', 'inst-op-rough', 44000, 150000),
        _seg('sg3', 'inst-op-finish', 152000, 210000),
        _seg('sg4', 'inst-op-finish', 230000, 300000),
        _seg('sg5', 'inst-op-cool', 190000, 240000),
        _seg('sg6', 'inst-op-deburr', 330000, 380000),
        // Measured 8 s, but reported as 90 s via the override below.
        _seg('sg7', 'inst-op-inspect', 382000, 390000),
      ];

  OperationTimeSegment _seg(String id, String instId, int from, int to) =>
      OperationTimeSegment(
        id: id,
        operationInstanceId: instId,
        startAtMs: _base + from,
        endAtMs: _base + to,
        createdAt: DateTime(2026),
      );

  List<OperationInstance> get instances => [
        for (final id in ids)
          OperationInstance(
            id: 'inst-$id',
            observationId: _obsId,
            studyOperationId: id,
            // Inspection: forgot to start the timer, time entered by hand.
            // Staging: never timed live at all.
            manualActualMs: switch (id) {
              'op-inspect' => 90000,
              'op-stage' => 45000,
              _ => null,
            },
            completedAt: DateTime(2026, 7, 21, 9, 37),
            notes: switch (id) {
              'op-cool' => pt
                  ? 'A bomba cicla ~50 s a cada três peças'
                  : 'Pump cycles ~50 s every third part'
              ,
              'op-inspect' => pt
                  ? 'Cronômetro esquecido; tempo do relógio de parede'
                  : 'Timer not started; time taken from the wall clock',
              _ => null,
            },
            createdAt: DateTime(2026),
          ),
      ];

  /// Two photos on the coolant wait, so the row indicator is visible.
  Map<String, int> get mediaCounts => const {'inst-op-cool': 2};

  TimeStudyReport get report => buildTimeStudyReport(
        operations: operations,
        timing: timingByOperation(instances: instances, segments: segments),
        subtypeById: {for (final s in subtypes) s.id: s},
        segments: segments,
        nowMs: _base + 400000,
      );
}

// Return type left to inference: riverpod's `Override` is not exported from its
// public API, so it cannot be named here.
// ignore: strict_top_level_inference
_overrides(_Fx f) => [
      // Nothing should query it — every stream below is overridden — but a
      // repository getter touched during a build would otherwise open the real
      // on-disk database.
      appDatabaseProvider.overrideWith((ref) {
        final db = AppDatabase(NativeDatabase.memory());
        ref.onDispose(db.close);
        return db;
      }),
      appSettingsProvider.overrideWith((ref) => Stream.value(f.settings)),
      // Screenshot renders must never reach an audio device.
      alertSoundsProvider.overrideWithValue(const SilentAlertSounds()),
      projectsListProvider.overrideWith((ref) => Stream.value(f.projects)),
      projectByIdProvider
          .overrideWith((ref, id) => Stream.value(f.projects.first)),
      catalogListProvider.overrideWith((ref) => Stream.value(f.catalog)),
      subtypesProvider.overrideWith((ref) => Stream.value(f.subtypes)),
      templatesListProvider
          .overrideWith((ref) => Stream.value(const <Template>[])),
      processTypeOptionsProvider
          .overrideWith((ref) => Stream.value(f.processTypes)),
      studiesByProjectProvider
          .overrideWith((ref, id) => Stream.value([f.study])),
      studyByIdProvider.overrideWith((ref, id) => Stream.value(f.study)),
      studyOperationsProvider
          .overrideWith((ref, id) => Stream.value(f.operations)),
      observationProvider.overrideWith((ref, id) => Stream.value(f.observation)),
      operationInstancesProvider
          .overrideWith((ref, id) => Stream.value(f.instances)),
      operationSegmentsProvider
          .overrideWith((ref, id) => Stream.value(f.segments)),
      operationMediaCountsProvider
          .overrideWith((ref) => Stream.value(f.mediaCounts)),
      appMediaBasePathProvider.overrideWith((ref) => Future.value('/demo')),
    ];

// --- annotation ------------------------------------------------------------

/// A numbered callout baked into the PNG. Position is a fraction of the surface
/// (0..1) so it survives a change of capture size.
typedef _Callout = ({double x, double y, int n});

Widget _badge(int n) => Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 1))
        ],
      ),
      child: Text(
        '$n',
        // Explicit style: the badges sit outside MaterialApp, so there is no
        // inherited text theme to fall back on.
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );

// --- harness ---------------------------------------------------------------

void main() {
  testWidgets('render manual screenshots', (tester) async {
    await tester.runAsync(() async {
      await _outDir.create(recursive: true);

      Future<void> load(String family, Iterable<String> candidates) async {
        for (final path in candidates) {
          final font = File(path);
          if (!font.existsSync()) continue;
          final loader = FontLoader(family)
            ..addFont(Future.value(font.readAsBytesSync().buffer.asByteData()));
          await loader.load();
          return;
        }
        // ignore: avoid_print
        print('WARNING: no font found for $family — glyphs will be boxes');
      }

      // The test environment ships no real font; without this every label
      // renders as a placeholder box and the manual is worthless.
      await load('Roboto', const [
        r'C:\Windows\Fonts\segoeui.ttf',
        '/System/Library/Fonts/Helvetica.ttc',
      ]);
      // Icons are their own font, and a manual whose every button is an empty
      // square teaches nothing. It ships inside the SDK, so derive the path
      // from the running Dart binary rather than hardcoding an install dir:
      // dart lives at <flutterRoot>/bin/cache/dart-sdk/bin/dart[.exe].
      var dir = File(Platform.resolvedExecutable).parent;
      for (var i = 0; i < 4; i++) {
        dir = dir.parent;
      }
      await load('MaterialIcons', [
        '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
        if (Platform.environment['FLUTTER_ROOT'] case final root?)
          '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      ]);
    });

    Future<void> shot(
      String name, {
      required Widget screen,
      required _Fx fx,
      required String locale,
      Size size = const Size(1180, 800),
      List<_Callout> callouts = const [],
    }) async {
      await tester.binding.setSurfaceSize(size);
      final key = GlobalKey();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: Stack(
            children: [
              Positioned.fill(
                child: ProviderScope(
                  overrides: _overrides(fx),
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    locale: Locale(locale),
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    theme: ChronusTheme.light(),
                    home: screen,
                  ),
                ),
              ),
              for (final c in callouts)
                Positioned(
                  left: c.x * size.width - 15,
                  top: c.y * size.height - 15,
                  child: _badge(c.n),
                ),
            ],
          ),
        ),
      ));
      // pump, not pumpAndSettle: Tooltips in the workspace keep settle spinning
      // forever. Several frames, because the data arrives down a chain — the
      // study resolves, which mounts the workspace, which subscribes to the
      // observation, which only then subscribes to instances and segments. One
      // frame per link, plus one to clear MaterialApp's AnimatedTheme lerp.
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final file = File('${_outDir.path}/$name.png');
      // Both calls must be inside runAsync — under the fake-async binding their
      // futures never complete.
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      // ignore: avoid_print
      print('${file.path}  ${size.width.toInt()}x${size.height.toInt()}');
    }

    for (final locale in const ['pt', 'en']) {
      final fx = _Fx(locale == 'pt');

      await shot('projects-$locale',
          screen: const ProjectsScreen(),
          fx: fx,
          locale: locale,
          size: const Size(1000, 620));

      await shot('catalog-$locale',
          screen: const CatalogScreen(),
          fx: fx,
          locale: locale,
          size: const Size(1000, 680));

      // Callouts are spread one-per-row down the operation list: each points at
      // a different column, so no badge covers the control it explains.
      await shot('workspace-$locale',
          screen: const StudyDetailScreen(
              projectId: _projectId, studyId: _studyId),
          fx: fx,
          locale: locale,
          callouts: const [
            (x: 0.822, y: 0.033, n: 1), // open the report
            // Header tiles: badges sit in each tile's empty right half.
            (x: 0.110, y: 0.166, n: 2), // total elapsed
            (x: 0.255, y: 0.166, n: 3), // work content
            (x: 0.410, y: 0.166, n: 4), // expected
            (x: 0.085, y: 0.258, n: 5), // timed progress
            (x: 0.017, y: 0.307, n: 6), // drag handle (row 1)
            (x: 0.757, y: 0.307, n: 7), // reference time (row 1)
            (x: 0.040, y: 0.372, n: 8), // state glyph (row 2)
            (x: 0.833, y: 0.372, n: 9), // observed time (row 2)
            (x: 0.902, y: 0.437, n: 10), // start (row 3)
            (x: 0.238, y: 0.502, n: 11), // note + photo indicators (row 4)
            (x: 0.936, y: 0.502, n: 12), // reset (row 4)
            (x: 0.971, y: 0.567, n: 13), // row menu (row 5)
            (x: 0.812, y: 0.647, n: 14), // manual-override tag (row 6)
            (x: 0.430, y: 0.955, n: 15), // add operation
          ]);

      await shot('report-$locale',
          screen: const TimeStudyReportScreen(
              projectId: _projectId, studyId: _studyId),
          fx: fx,
          locale: locale,
          // Tall enough for the whole operations table; section badges sit just
          // after each heading rather than on top of its first letter.
          size: const Size(1180, 1120),
          callouts: const [
            (x: 0.940, y: 0.022, n: 1), // export
            (x: 0.081, y: 0.052, n: 2), // total elapsed
            (x: 0.227, y: 0.052, n: 3), // work content
            (x: 0.372, y: 0.052, n: 4), // simultaneous
            (x: 0.518, y: 0.052, n: 5), // unattributed
            (x: 0.664, y: 0.052, n: 6), // value-added ratio
            (x: 0.809, y: 0.052, n: 7), // efficiency
            (x: 0.158, y: 0.162, n: 8), // category breakdown
            (x: 0.082, y: 0.307, n: 9), // timeline
            (x: 0.111, y: 0.512, n: 10), // waste pareto
            (x: 0.099, y: 0.583, n: 11), // operations table
          ]);

      await shot('settings-$locale',
          screen: const SettingsScreen(),
          fx: fx,
          locale: locale,
          // Cropped to the content: the settings list is short.
          size: const Size(1000, 470));

      // Cropped tight to the chart: the manual leans on this one to explain
      // concurrency, pauses, dead time and hatching, so it gets its own figure.
      await shot('gantt-$locale',
          screen: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: TimelineGantt(report: fx.report),
            ),
          ),
          fx: fx,
          locale: locale,
          size: const Size(1000, 250),
          callouts: const [
            (x: 0.220, y: 0.114, n: 1), // wall-clock axis
            (x: 0.537, y: 0.337, n: 2), // pause gap inside a row
            (x: 0.450, y: 0.468, n: 3), // concurrency
            (x: 0.703, y: 0.554, n: 4), // unattributed dead time
            (x: 0.790, y: 0.644, n: 5), // measured part of an override
            (x: 0.905, y: 0.600, n: 6), // hatched = reported, not measured
          ]);
    }

    final r = _Fx(false).report;
    // ignore: avoid_print
    print('fixture: elapsed=${r.totalElapsedMs} work=${r.totalWorkContentMs} '
        'simultaneous=${r.simultaneousMs} unattributed=${r.unattributedMs}');
  });
}
