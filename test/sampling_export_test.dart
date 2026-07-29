import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/sampling_report.dart';
import 'package:chronus/src/features/analysis/application/time_study_report.dart';
import 'package:chronus/src/features/export/application/export_payload.dart';
import 'package:chronus/src/features/export/data/pdf_export.dart';
import 'package:chronus/src/features/export/data/xlsx_export.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:chronus/src/l10n/generated/app_localizations_en.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _l10n = AppLocalizationsEn();

/// The `excel` package writes a whole double as an `IntCellValue`, so a cast to
/// one or the other is a coin toss on the value. Same helper as `export_test`.
num? _number(Data? cell) => switch (cell?.value) {
      DoubleCellValue(:final value) => value,
      IntCellValue(:final value) => value,
      _ => null,
    };

/// The Sampling Study artifacts (DESIGN.md §11.7).
///
/// The load-bearing test is the last one: filter `Observations` to the included
/// rows, average them, and you must land on the mean the app reports. That is
/// §5's "recompute it downstream" guarantee, extended from the reported overlap
/// to the reported mean.
void main() {
  setUpAll(() => initializeDateFormatting('en'));

  StudyOperation op(String id, double order, {int? reference}) =>
      StudyOperation(
        id: id,
        studyId: 's',
        orderIndex: order,
        name: 'Op $id',
        category: OperationCategory.productive,
        referenceStandardMs: reference,
        isUnplanned: false,
        createdAt: DateTime(2026),
      );

  Observation obs(int index, {DateTime? excludedAt, String? reason}) =>
      Observation(
        id: 'obs-$index',
        studyId: 's',
        sequenceIndex: index,
        performedAt: DateTime(2026, 7, 27, 8, index),
        excludedAt: excludedAt,
        exclusionReason: reason,
        createdAt: DateTime(2026),
      );

  /// One measured reading, as a finished operation with a real segment.
  OperationTiming reading(
    String opId,
    int startMs,
    int ms, {
    bool manual = false,
    DateTime? excludedAt,
    String? reason,
  }) =>
      OperationTiming(
        instance: OperationInstance(
          id: 'i-$opId-$startMs',
          observationId: 'o',
          studyOperationId: opId,
          manualActualMs: manual ? ms : null,
          completedAt: DateTime(2026),
          excludedAt: excludedAt,
          exclusionReason: reason,
          createdAt: DateTime(2026),
        ),
        segments: manual
            ? const []
            : [
                OperationTimeSegment(
                  id: 'g-$opId-$startMs',
                  operationInstanceId: 'i-$opId-$startMs',
                  startAtMs: startMs,
                  endAtMs: startMs + ms,
                  createdAt: DateTime(2026),
                ),
              ],
      );

  Study study() => Study(
        id: 's',
        projectId: 'p',
        type: StudyType.samplingStudy,
        name: 'Bracket weld',
        performedAt: DateTime(2026, 7, 27, 8),
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
        nextPassIndex: 4,
        analyst: 'M. Sancha',
        machineWorkstation: 'CNC-2',
        notes: 'Repeat study.',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  /// Three passes of one operation: 10 s, 12 s (excluded), 11 s.
  /// Included mean is therefore 10.5 s, not 11.
  SamplingExportPayload payload() {
    final operations = [op('P', 1, reference: 9000)];
    final passes = <({Observation observation, OperationTiming timing})>[
      (observation: obs(0), timing: reading('P', 0, 10000)),
      (
        observation: obs(1),
        timing: reading('P', 100000, 12000,
            excludedAt: DateTime(2026), reason: 'wire feed jam')
      ),
      (observation: obs(2), timing: reading('P', 200000, 11000, manual: true)),
    ];

    final report = buildSamplingReport(
      operations: operations,
      passes: [
        for (final p in passes)
          PassTiming(
            observation: p.observation,
            timingByOperation: {'P': p.timing},
          ),
      ],
      subtypeById: const {},
      confidenceLevel: 0.95,
      relativePrecision: 0.05,
      nowMs: 0,
    );

    return SamplingExportPayload(
      study: study(),
      report: report,
      passes: [
        for (final p in passes)
          PassExport(
            observation: p.observation,
            report: buildTimeStudyReport(
              operations: operations,
              timing: {'P': p.timing},
              subtypeById: const {},
              segments: p.timing.segments,
            ),
          ),
      ],
      photosByStudyOperationId: const {},
    );
  }

  Excel decode() =>
      Excel.decodeBytes(buildSamplingXlsx(payload(), _l10n, localeName: 'en'));

  group('XLSX', () {
    test('ships exactly the four flat sheets', () {
      // Not sheets per pass: ten passes would be twenty-two of them, and a
      // formula written against one would need rewriting for the rest (§11.7).
      expect(decode().tables.keys.toSet(),
          {'Summary', 'Statistics', 'Observations', 'Segments'});
    });

    test('Observations is one row per pass × operation, with its flags', () {
      final rows = decode()['Observations'].rows;
      expect(rows.length, 4); // header + three readings

      // pass | operation | seconds | excluded | manual | reason
      expect(rows[1][0]?.value.toString(), '1');
      expect(_number(rows[1][2]), 10);
      expect(rows[1][3]?.value.toString(), '0');
      expect(rows[1][4]?.value.toString(), '0');

      expect(rows[2][0]?.value.toString(), '2');
      expect(_number(rows[2][2]), 12);
      expect(rows[2][3]?.value.toString(), '1'); // excluded
      expect(rows[2][5]?.value.toString(), 'wire feed jam');

      expect(rows[3][0]?.value.toString(), '3');
      expect(rows[3][4]?.value.toString(), '1'); // manual
    });

    test('the mean can be recomputed from the sheet and matches the report',
        () {
      // §5's guarantee, extended to the mean: filter to Excluded = 0, average,
      // and land on our number. This is the reason the flags ship at all.
      final rows = decode()['Observations'].rows.skip(1);
      final included = [
        for (final row in rows)
          if (row[3]?.value.toString() == '0') _number(row[2])!,
      ];
      final recomputed =
          included.reduce((a, b) => a + b) / included.length;

      final reported = payload().report.rows.single.statistics!.mean / 1000;
      expect(included, hasLength(2)); // the jam is out
      expect(recomputed, closeTo(reported, 1e-9));
      expect(recomputed, closeTo(10.5, 1e-9)); // not 11
    });

    test('Segments carries a Pass column and only measured intervals', () {
      final rows = decode()['Segments'].rows;
      // Pass 3 was typed, not measured — fabricated time is not a segment (§5),
      // so it contributes no row even though it counts toward the mean.
      expect(rows.length, 3); // header + passes 1 and 2
      expect(rows[1][0]?.value.toString(), '1');
      expect(rows[2][0]?.value.toString(), '2');
      expect(rows[1][1]?.value.toString(), 'Op P');
      expect(_number(rows[1][5]), 10);
    });

    test('an excluded pass still contributes its segments', () {
      // Exclusion is a statement about the average, not about whether the
      // measurement happened.
      final passNumbers = decode()['Segments']
          .rows
          .skip(1)
          .map((r) => r[0]?.value.toString())
          .toList();
      expect(passNumbers, contains('2'));
    });

    test('Statistics carries t and df so a hand check can reproduce n', () {
      final rows = decode()['Statistics'].rows;
      expect(rows.length, 2); // header + one operation

      final header = rows.first.map((c) => c?.value.toString()).toList();
      expect(header, contains('t'));
      expect(header, contains('df'));

      final tIndex = header.indexOf('t');
      expect(_number(rows[1][tIndex]), greaterThan(1));
    });

    test('Summary carries the criteria as numbers and names the verdict', () {
      final flat = [
        for (final row in decode()['Summary'].rows)
          for (final cell in row)
            if (cell?.value != null) cell!.value.toString(),
      ];
      expect(flat, contains('Bracket weld'));
      expect(flat, contains('M. Sancha'));
      // Fractions, not "95%" text: an analyst re-deriving n needs a number.
      expect(flat, contains('0.95'));
      expect(flat, contains('0.05'));
      // The operation the verdict hangs on travels into the artifact.
      expect(flat, contains('Op P'));
    });
  });

  group('PDF', () {
    test('produces a PDF with the pass appendix included', () async {
      final bytes = await buildSamplingPdf(payload(), _l10n, localeName: 'en');
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      // Three passes of appendix plus the aggregate sections make this
      // comfortably larger than an empty document.
      expect(bytes.length, greaterThan(2000));
    });

    test('builds even when nothing was measured at all', () async {
      // A study opened, passes created, nothing timed: the exporter must not
      // divide by zero or index an empty Pareto.
      final empty = SamplingExportPayload(
        study: study(),
        report: buildSamplingReport(
          operations: [op('P', 1)],
          passes: [
            PassTiming(observation: obs(0), timingByOperation: const {}),
          ],
          subtypeById: const {},
          confidenceLevel: 0.95,
          relativePrecision: 0.05,
          nowMs: 0,
        ),
        passes: const [],
        photosByStudyOperationId: const {},
      );
      final bytes = await buildSamplingPdf(empty, _l10n, localeName: 'en');
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
