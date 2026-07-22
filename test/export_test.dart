import 'dart:io';
import 'dart:typed_data';

import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/time_study_report.dart';
import 'package:chronus/src/features/export/application/export_payload.dart';
import 'package:chronus/src/features/export/data/pdf_export.dart';
import 'package:chronus/src/features/export/data/xlsx_export.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:chronus/src/l10n/generated/app_localizations_en.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
// Prefixed: `image` and Flutter's widget library both export an `Image`.
import 'package:image/image.dart' as img;
import 'package:intl/date_symbol_data_local.dart';

final _l10n = AppLocalizationsEn();

StudyOperation _op(String id, OperationCategory cat, double order,
        {String? subtypeId, int? reference}) =>
    StudyOperation(
      id: id,
      studyId: 's',
      catalogOperationId: null,
      orderIndex: order,
      name: 'Op $id',
      category: cat,
      subtypeId: subtypeId,
      referenceStandardMs: reference,
      isUnplanned: false,
      createdAt: DateTime(2026),
    );

OperationInstance _inst(String opId) => OperationInstance(
      id: 'i$opId',
      observationId: 'o',
      studyOperationId: opId,
      manualActualMs: null,
      completedAt: DateTime(2026),
      notes: opId == 'P' ? 'watch the fixture' : null,
      createdAt: DateTime(2026),
    );

OperationTimeSegment _seg(String opId, int start, int end) =>
    OperationTimeSegment(
      id: 'g$opId',
      operationInstanceId: 'i$opId',
      startAtMs: start,
      endAtMs: end,
      createdAt: DateTime(2026),
    );

Study _study() => Study(
      id: 's',
      projectId: 'p',
      type: StudyType.timeStudy,
      name: 'Line 3 cycle',
      performedAt: DateTime(2026, 7, 21, 9, 30),
      analyst: 'M. Sancha',
      partProduct: 'Bracket A',
      processOperation: null,
      machineWorkstation: 'CNC-2',
      lineCell: null,
      operatorName: null,
      shift: null,
      workOrderNumber: null,
      processType: 'Machining',
      notes: 'Baseline run.',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

/// P (productive) 0..10 s with an 8 s reference → 80 % efficiency;
/// W (waiting waste) 5..9 s, overlapping P.
StudyExportPayload _payload({
  Map<String, List<ExportPhoto>> photos = const {},
}) {
  final subtype = OperationSubtype(
    id: 'w',
    category: OperationCategory.unproductive,
    name: 'Waiting',
    isBuiltIn: true,
    createdAt: DateTime(2026),
  );
  final segP = _seg('P', 0, 10000);
  final segW = _seg('W', 5000, 9000);

  final report = buildTimeStudyReport(
    operations: [
      _op('P', OperationCategory.productive, 1, reference: 8000),
      _op('W', OperationCategory.unproductive, 2, subtypeId: 'w'),
    ],
    timing: {
      'P': OperationTiming(instance: _inst('P'), segments: [segP]),
      'W': OperationTiming(instance: _inst('W'), segments: [segW]),
    },
    subtypeById: {'w': subtype},
    segments: [segP, segW],
  );

  return StudyExportPayload(
    study: _study(),
    report: report,
    photosByStudyOperationId: photos,
  );
}

/// A real, decodable PNG so the PDF embedder has something to work with.
Uint8List _png() => img.encodePng(img.Image(width: 8, height: 8));

/// Reads a cell as a number regardless of whether the writer stored it as an
/// int or a double — `excel` narrows whole doubles on decode.
num? _number(Data cell) => switch (cell.value) {
      DoubleCellValue(:final value) => value,
      IntCellValue(:final value) => value,
      _ => null,
    };

void main() {
  // Matches what `main()` does at startup, so date formatting behaves here as
  // it does in the app.
  setUpAll(() => initializeDateFormatting());

  group('file naming', () {
    test('slugifies the study name and stamps the performed date', () {
      expect(exportFileName(_study(), 'pdf'), 'Line-3-cycle-2026-07-21.pdf');
    });

    test('falls back to a generic base when the name has no word characters',
        () {
      final study = _study().copyWith(name: '///');
      expect(exportFileName(study, 'xlsx'), 'study-2026-07-21.xlsx');
    });
  });

  group('header fields', () {
    test('keeps populated fields in order and drops blank optional ones', () {
      final fields = studyHeaderFields(_study(), _l10n, localeName: 'en');
      final labels = fields.map((f) => f.label).toList();

      expect(labels, [
        _l10n.studyFieldType,
        _l10n.studyFieldDate,
        _l10n.studyFieldAnalyst,
        _l10n.studyFieldProcessType,
        _l10n.studyFieldPartProduct,
        _l10n.studyFieldMachine,
      ]);
      expect(labels, isNot(contains(_l10n.studyFieldShift)));
    });
  });

  group('PDF text safety', () {
    test('keeps pt-BR and Spanish letters intact', () {
      // Latin-1 accents are what the built-in PDF fonts DO cover; rewriting
      // them would mangle the two non-English launch languages.
      const text = 'Operação de usinagem · Inspección · Ação nº 3';
      expect(pdfSafeText(text), text);
    });

    test('folds typographic punctuation the built-in fonts cannot draw', () {
      expect(pdfSafeText('Setup — 50%'), 'Setup - 50%');
      expect(pdfSafeText('a–b'), 'a-b');
      expect(pdfSafeText('loading…'), 'loading...');
      expect(pdfSafeText('“quoted” and ‘single’'), '"quoted" and \'single\'');
      expect(pdfSafeText('no break'), 'no break');
    });
  });

  group('PDF export', () {
    test('produces a valid PDF document', () async {
      final bytes = await buildStudyPdf(_payload(), _l10n, localeName: 'en');

      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });

    test('embeds attached photos', () async {
      final dir = await Directory.systemTemp.createTemp('chronus_export');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/photo.png')..writeAsBytesSync(_png());

      final withPhoto = await buildStudyPdf(
        _payload(photos: {
          'P': [ExportPhoto(absolutePath: file.path, caption: 'Fixture')],
        }),
        _l10n,
        localeName: 'en',
      );
      final without = await buildStudyPdf(_payload(), _l10n, localeName: 'en');

      expect(withPhoto.length, greaterThan(without.length));
    });

    test('skips photos whose file has gone missing rather than failing',
        () async {
      final bytes = await buildStudyPdf(
        _payload(photos: {
          'P': [const ExportPhoto(absolutePath: '/nope/gone.png')],
        }),
        _l10n,
        localeName: 'en',
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });

  group('XLSX export', () {
    Excel decode() => Excel.decodeBytes(
        buildStudyXlsx(_payload(), _l10n, localeName: 'en'));

    test('ships exactly the Summary and Operations sheets', () {
      expect(decode().tables.keys.toSet(), {'Summary', 'Operations'});
    });

    test('writes durations as numeric seconds, not formatted text', () {
      final sheet = decode()['Operations'];
      // Row 0 is the header; row 1 is operation P (10 s observed, 8 s reference).
      num? at(int column) => _number(
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 1)));

      expect(at(4), 10); // observed
      expect(at(5), 8); // reference standard
      expect(at(6), closeTo(0.8, 1e-9)); // efficiency
    });

    test('leaves cells empty where a value is absent', () {
      final sheet = decode()['Operations'];
      // Operation W has no reference standard, so no efficiency either.
      final reference = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 2));
      expect((reference.value as TextCellValue?)?.value.toString() ?? '', '');
    });

    test('summary carries the study header and the totals', () {
      final rows = decode()['Summary'].rows;
      final flat = [
        for (final row in rows)
          for (final cell in row)
            if (cell?.value != null) cell!.value.toString(),
      ];

      expect(flat, contains('Line 3 cycle'));
      expect(flat, contains('M. Sancha'));
      expect(flat, contains('Machining'));
      // Elapsed is the wall-clock span (10 s), not the 14 s work content.
      expect(flat, contains('10'));
      expect(flat, contains('14'));
    });
  });
}
