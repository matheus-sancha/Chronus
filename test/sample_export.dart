// Dev tool: renders the exporters over a realistic 10-operation machining study
// so the PDF/XLSX layout can be eyeballed without hand-entering a study.
//
//   flutter test test/sample_export.dart
//
// Writes to build/samples/ (gitignored). Deliberately NOT named *_test.dart, so
// the normal `flutter test` run skips it — it asserts nothing, it draws.
//
// The fixture overlaps the coolant wait with the finish mill, so elapsed comes
// out BELOW work content; that concurrency is the case most worth eyeballing.
import 'dart:io';

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/time_study_report.dart';
import 'package:chronus/src/features/export/application/export_payload.dart';
import 'package:chronus/src/features/export/data/pdf_export.dart';
import 'package:chronus/src/features/export/data/xlsx_export.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:chronus/src/l10n/generated/app_localizations_en.dart';
import 'package:chronus/src/l10n/generated/app_localizations_pt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Repo-relative and gitignored, so the tool works on any machine.
final _outDir = Directory('build/samples');

final _subtypes = {
  'waiting': OperationSubtype(
      id: 'waiting',
      category: OperationCategory.unproductive,
      name: 'Waiting',
      isBuiltIn: true,
      createdAt: DateTime(2026)),
  'motion': OperationSubtype(
      id: 'motion',
      category: OperationCategory.unproductive,
      name: 'Motion',
      isBuiltIn: true,
      createdAt: DateTime(2026)),
  'transport': OperationSubtype(
      id: 'transport',
      category: OperationCategory.unproductive,
      name: 'Transportation',
      isBuiltIn: true,
      createdAt: DateTime(2026)),
};

/// name, category, subtype, observed ms, reference ms, note
final _rows = <(String, OperationCategory, String?, int, int?, String?)>[
  ('Load billet into fixture', OperationCategory.setup, null, 42300, 40000, null),
  ('Set tool offsets', OperationCategory.setup, null, 68100, 60000,
      'New operator — slower on the offset table'),
  ('Rough mill — face', OperationCategory.productive, null, 184500, 190000, null),
  ('Wait for coolant recovery', OperationCategory.unproductive, 'waiting', 51200,
      null, 'Pump cycles ~50 s every third part'),
  ('Finish mill — pocket', OperationCategory.productive, null, 231800, 220000,
      null),
  ('Deburr edges', OperationCategory.productive, null, 76400, 80000, null),
  ('Walk to gauge station', OperationCategory.unproductive, 'motion', 28900,
      null, null),
  ('Inspect — CMM check', OperationCategory.productive, null, 112600, 105000,
      null),
  ('Move tote to next cell', OperationCategory.unproductive, 'transport', 39700,
      null, null),
  ('Unload and stage', OperationCategory.productive, null, 55300, 55000, null),
];

/// Operations that exercise the hatched (reported-but-not-measured) rendering:
/// a forgot-to-start override, and one never timed live at all. Real studies
/// contain both, and they are the cases the PDF most needs to distinguish.
/// name, category, reference, measured ms (0 = never timed), reported ms
const _unmeasuredRows = <(String, OperationCategory, int?, int, int)>[
  ('Re-check dimension', OperationCategory.productive, 60000, 6200, 71000),
  ('Stage for next cell', OperationCategory.productive, null, 0, 48000),
];

StudyExportPayload _payload() {
  final operations = <StudyOperation>[];
  final timing = <String, OperationTiming>{};
  final allSegments = <OperationTimeSegment>[];

  // Lay the operations out end-to-end on the wall clock, except the coolant
  // wait, which overlaps the finish mill (machine running, operator idle) —
  // so elapsed < work content and the concurrency shows up in the totals.
  var cursor = DateTime(2026, 7, 21, 9, 30).millisecondsSinceEpoch;

  for (var i = 0; i < _rows.length; i++) {
    final (name, category, subtypeId, observed, reference, note) = _rows[i];
    final id = 'op$i';

    operations.add(StudyOperation(
      id: id,
      studyId: 'study',
      catalogOperationId: 'cat$i',
      orderIndex: i + 1,
      name: name,
      category: category,
      subtypeId: subtypeId,
      referenceStandardMs: reference,
      isUnplanned: false,
      createdAt: DateTime(2026),
    ));

    final overlaps = name.startsWith('Wait for coolant');
    final start = overlaps ? cursor - 40000 : cursor;
    final segment = OperationTimeSegment(
      id: 'seg$i',
      operationInstanceId: 'inst$i',
      startAtMs: start,
      endAtMs: start + observed,
      createdAt: DateTime(2026),
    );
    if (!overlaps) cursor += observed + 1500; // small gap between operations

    allSegments.add(segment);
    timing[id] = OperationTiming(
      instance: OperationInstance(
        id: 'inst$i',
        observationId: 'obs',
        studyOperationId: id,
        manualActualMs: null,
        completedAt: DateTime(2026),
        notes: note,
        createdAt: DateTime(2026),
      ),
      segments: [segment],
    );
  }

  for (var j = 0; j < _unmeasuredRows.length; j++) {
    final (name, category, reference, measuredMs, reportedMs) =
        _unmeasuredRows[j];
    final id = 'extra$j';

    operations.add(StudyOperation(
      id: id,
      studyId: 'study',
      catalogOperationId: null,
      orderIndex: _rows.length + j + 1,
      name: name,
      category: category,
      subtypeId: null,
      referenceStandardMs: reference,
      isUnplanned: false,
      createdAt: DateTime(2026),
    ));

    final segments = <OperationTimeSegment>[];
    if (measuredMs > 0) {
      segments.add(OperationTimeSegment(
        id: 'segExtra$j',
        operationInstanceId: 'instExtra$j',
        startAtMs: cursor,
        endAtMs: cursor + measuredMs,
        createdAt: DateTime(2026),
      ));
      cursor += measuredMs + 1500;
      allSegments.addAll(segments);
    }

    timing[id] = OperationTiming(
      instance: OperationInstance(
        id: 'instExtra$j',
        observationId: 'obs',
        studyOperationId: id,
        // The reported time shadows the measurement; the difference is the
        // part the PDF must draw hatched.
        manualActualMs: reportedMs,
        completedAt: DateTime(2026),
        notes: null,
        createdAt: DateTime(2026),
      ),
      segments: segments,
    );
  }

  final study = Study(
    id: 'study',
    projectId: 'project',
    type: StudyType.timeStudy,
    name: 'Cell 4 — bracket A baseline',
    performedAt: DateTime(2026, 7, 21, 9, 30),
    confidenceLevel: 0.95,
    relativePrecision: 0.05,
    nextPassIndex: 1,
    analyst: 'M. Sancha',
    partProduct: 'Bracket A / 55-2201',
    processOperation: 'Mill & inspect',
    machineWorkstation: 'Haas VF-2 (CNC-2)',
    lineCell: 'Cell 4',
    operatorName: 'J. Ribeiro',
    shift: '1st',
    workOrderNumber: 'WO-88134',
    processType: 'Machining',
    notes:
        'Baseline before the fixture change. Coolant recovery wait overlaps the '
        'finish mill, so elapsed is shorter than total work content.',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  return StudyExportPayload(
    study: study,
    report: buildTimeStudyReport(
      operations: operations,
      timing: timing,
      subtypeById: _subtypes,
      segments: allSegments,
    ),
    photosByStudyOperationId: const {},
  );
}

void main() {
  setUpAll(() => initializeDateFormatting());

  test('write sample artifacts', () async {
    final payload = _payload();
    final r = payload.report;

    await _outDir.create(recursive: true);

    Future<void> write(String name, List<int> bytes) async {
      final file = File('${_outDir.path}/$name');
      await file.writeAsBytes(bytes);
      // ignore: avoid_print
      print('${file.path}  (${(bytes.length / 1024).toStringAsFixed(1)} KB)');
    }

    await write('chronus-sample.pdf',
        await buildStudyPdf(payload, AppLocalizationsEn(), localeName: 'en'));
    await write('chronus-sample.xlsx',
        buildStudyXlsx(payload, AppLocalizationsEn(), localeName: 'en'));
    await write(
        'chronus-sample-pt.pdf',
        await buildStudyPdf(payload, AppLocalizationsPt(),
            localeName: 'pt_BR'));

    // ignore: avoid_print
    print('elapsed=${r.totalElapsedMs}ms  work=${r.totalWorkContentMs}ms  '
        'va=${(r.valueAddedRatio * 100).toStringAsFixed(1)}%  '
        'eff=${((r.efficiency ?? 0) * 100).toStringAsFixed(0)}%');
  });
}
