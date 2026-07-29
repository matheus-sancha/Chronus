import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/cross_study_comparison.dart';
import 'package:chronus/src/features/analysis/application/sampling_report.dart';
import 'package:chronus/src/features/export/application/export_payload.dart';
import 'package:chronus/src/features/export/data/pdf_export.dart';
import 'package:chronus/src/features/export/data/xlsx_export.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:chronus/src/l10n/generated/app_localizations_en.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _l10n = AppLocalizationsEn();

num? _number(Data? cell) => switch (cell?.value) {
      DoubleCellValue(:final value) => value,
      IntCellValue(:final value) => value,
      _ => null,
    };

/// The comparison artifacts (DESIGN.md §4, §5, §11.9).
void main() {
  setUpAll(() => initializeDateFormatting('en'));

  StudyOperation op(String id, {String? catalogId, String? name, int? ref}) =>
      StudyOperation(
        id: id,
        studyId: 'ignored',
        catalogOperationId: catalogId,
        orderIndex: 1,
        name: name ?? 'Op $id',
        category: OperationCategory.productive,
        referenceStandardMs: ref,
        isUnplanned: false,
        createdAt: DateTime(2026),
      );

  OperationTiming timed(int ms) => OperationTiming(
        instance: OperationInstance(
          id: 'i$ms',
          observationId: 'o',
          studyOperationId: 's',
          completedAt: DateTime(2026),
          createdAt: DateTime(2026),
        ),
        segments: [
          OperationTimeSegment(
            id: 'g$ms',
            operationInstanceId: 'i$ms',
            startAtMs: 0,
            endAtMs: ms,
            createdAt: DateTime(2026),
          ),
        ],
      );

  ComparisonInput input(
    String id,
    DateTime when,
    List<StudyOperation> operations,
    List<Map<String, int>> passes,
  ) {
    return ComparisonInput(
      study: Study(
        id: id,
        projectId: 'p',
        type: passes.length > 1
            ? StudyType.samplingStudy
            : StudyType.timeStudy,
        name: 'Study $id',
        performedAt: when,
        analyst: 'M. Sancha',
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
        nextPassIndex: 1,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      operations: operations,
      report: buildSamplingReport(
        operations: operations,
        passes: [
          for (var i = 0; i < passes.length; i++)
            PassTiming(
              observation: Observation(
                id: '$id-o$i',
                studyId: id,
                sequenceIndex: i,
                performedAt: when,
                createdAt: when,
              ),
              timingByOperation: {
                for (final e in passes[i].entries) e.key: timed(e.value),
              },
            ),
        ],
        subtypeById: const {},
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
        nowMs: 0,
      ),
    );
  }

  /// March: one Time Study reading of 12 s. July: three passes averaging 10 s.
  /// Plus a custom operation in March that cannot be matched.
  ComparisonExportPayload payload() {
    final comparison = buildCrossStudyComparison([
      input('mar', DateTime(2026, 3, 10), [
        op('a', catalogId: 'c1', name: 'Weld seam', ref: 11000),
        op('x', name: 'Rework'),
      ], [
        {'a': 12000, 'x': 4000},
      ]),
      input('jul', DateTime(2026, 7, 10),
          [op('b', catalogId: 'c1', name: 'Weld seam', ref: 11000)], [
        {'b': 9000},
        {'b': 10000},
        {'b': 11000},
      ]),
    ]);
    return ComparisonExportPayload(
      projectName: 'Cell 4',
      comparison: comparison,
    );
  }

  Excel decode() => Excel.decodeBytes(
      buildComparisonXlsx(payload(), _l10n, localeName: 'en'));

  group('XLSX', () {
    test('ships the Studies, Comparison and Unmatched sheets', () {
      expect(decode().tables.keys.toSet(),
          {'Studies', 'Comparison', 'Unmatched'});
    });

    test('Comparison is flat — one row per operation and study', () {
      // §5 splits the formats by job: the PDF shows the matrix, the spreadsheet
      // goes flat so it pivots into whatever the analyst actually wants.
      final rows = decode()['Comparison'].rows;
      expect(rows.length, 3); // header + March + July

      // operation | study | date | mean s | n | reference s | efficiency
      expect(rows[1][0]?.value.toString(), 'Weld seam');
      expect(rows[1][1]?.value.toString(), 'Study mar');
      expect(_number(rows[1][3]), 12);
      expect(_number(rows[1][4]), 1); // a single reading

      expect(rows[2][1]?.value.toString(), 'Study jul');
      expect(_number(rows[2][3]), 10); // the mean of 9, 10, 11
      expect(_number(rows[2][4]), 3);
    });

    test('n travels with every figure', () {
      // §11.9: without it, "improved 17% since March" reads as a finding when
      // March was one press of a stopwatch.
      final rows = decode()['Comparison'].rows.skip(1);
      for (final row in rows) {
        expect(_number(row[4]), isNotNull);
        expect(_number(row[4]), greaterThan(0));
      }
    });

    test('efficiency is computed against the standard in force', () {
      final rows = decode()['Comparison'].rows;
      expect(_number(rows[1][5]), 11); // reference, seconds
      expect(_number(rows[1][6]), closeTo(11 / 12, 1e-9)); // March
      expect(_number(rows[2][6]), closeTo(1.1, 1e-9)); // July beat it
    });

    test('the operations left out get a sheet, not a footnote', () {
      // A note at the bottom of a sheet is the first thing lost to a filter.
      final rows = decode()['Unmatched'].rows;
      expect(rows.length, 2); // header + Rework
      expect(rows[1][0]?.value.toString(), 'Rework');
      expect(rows[1][1]?.value.toString(), 'Study mar');
    });

    test('Studies names what was compared, in date order', () {
      final flat = [
        for (final row in decode()['Studies'].rows)
          for (final cell in row)
            if (cell?.value != null) cell!.value.toString(),
      ];
      expect(flat, contains('Cell 4'));
      expect(flat, contains('Study mar'));
      expect(flat, contains('Study jul'));
      expect(flat.indexOf('Study mar'), lessThan(flat.indexOf('Study jul')));
    });
  });

  group('PDF', () {
    test('produces a comparison PDF', () async {
      final bytes = await buildComparisonPdf(payload(), _l10n, localeName: 'en');
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('builds when nothing could be matched at all', () async {
      final empty = ComparisonExportPayload(
        projectName: 'Cell 4',
        comparison: buildCrossStudyComparison([
          input('mar', DateTime(2026, 3, 10), [op('x', name: 'Rework')],
              [{'x': 4000}]),
        ]),
      );
      final bytes = await buildComparisonPdf(empty, _l10n, localeName: 'en');
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });

  test('the comparison file is named for the project, not for a study', () {
    // Dating it by one of the studies would misattribute a reading taken of
    // several of them.
    expect(comparisonFileName('Cell 4', 'pdf'), startsWith('Cell-4-'));
    expect(comparisonFileName('Cell 4', 'pdf'), endsWith('.pdf'));
    expect(comparisonFileName('', 'xlsx'), startsWith('comparison-'));
  });
}
