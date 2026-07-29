import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../analysis/application/sampling_report.dart';
import '../../analysis/application/time_study_report.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../../studies/presentation/study_formatting.dart';
import '../application/export_payload.dart';

/// Sheet names are fixed identifiers (not localized) so downstream spreadsheets
/// and macros that reference them keep working across app languages.
const _sheetSummary = 'Summary';
const _sheetOperations = 'Operations';
const _sheetSegments = 'Segments';
const _sheetStatistics = 'Statistics';
const _sheetObservations = 'Observations';
const _sheetStudies = 'Studies';
const _sheetComparison = 'Comparison';
const _sheetUnmatched = 'Unmatched';

/// The cross-study comparison as an analysis artifact (DESIGN.md §4, §5).
///
/// **Flat, not the side-by-side matrix the screen shows.** §5 divides the two
/// formats by job: the PDF presents, and presents the matrix; the spreadsheet is
/// for analysis, where one row per (operation, study) pivots into whatever shape
/// the analyst actually wants and a wide matrix does not.
///
/// `Unmatched` is a sheet rather than a footnote for the same reason it is
/// on screen (§11.9): the omission has to survive into the artifact, and a note
/// at the bottom of a sheet is the first thing lost to a filter.
Uint8List buildComparisonXlsx(
  ComparisonExportPayload payload,
  AppLocalizations l10n, {
  String? localeName,
}) {
  const ours = {_sheetStudies, _sheetComparison, _sheetUnmatched};
  final comparison = payload.comparison;

  final excel = Excel.createExcel();

  final studies = _RowWriter(excel[_sheetStudies]);
  studies.heading(payload.projectName);
  studies.blank();
  studies.header([
    l10n.studyNameLabel,
    l10n.studyFieldType,
    l10n.studyFieldDate,
    l10n.studyFieldAnalyst,
  ]);
  final dateFormat = DateFormat.yMMMd(localeName).add_Hm();
  for (final study in comparison.studies) {
    studies.row([
      TextCellValue(study.name),
      TextCellValue(studyTypeLabel(l10n, study.type)),
      TextCellValue(dateFormat.format(study.performedAt)),
      TextCellValue(study.analyst ?? ''),
    ]);
  }

  final rows = _RowWriter(excel[_sheetComparison]);
  rows.header([
    l10n.colOperation,
    l10n.studyNameLabel,
    l10n.studyFieldDate,
    _seconds(l10n, l10n.samplingMean),
    l10n.samplingCount,
    _seconds(l10n, l10n.colReference),
    l10n.reportEfficiency,
  ]);
  for (final row in comparison.rows) {
    for (var i = 0; i < row.cells.length; i++) {
      final cell = row.cells[i];
      // A study that did not time the operation contributes no row: a zero
      // would be a measurement and a blank row would be a reading.
      if (!cell.hasValue) continue;
      final study = comparison.studies[i];
      rows.row([
        TextCellValue(row.name),
        TextCellValue(study.name),
        DateTimeCellValue.fromDateTime(study.performedAt),
        DoubleCellValue(msToSeconds(cell.meanMs!.round())),
        // n beside every figure, so a downstream reader can weight a mean over
        // six passes against one press of a stopwatch (§11.9).
        IntCellValue(cell.readingCount),
        row.referenceStandardMs == null
            ? TextCellValue('')
            : DoubleCellValue(msToSeconds(row.referenceStandardMs!)),
        cell.efficiency == null
            ? TextCellValue('')
            : DoubleCellValue(cell.efficiency!),
      ]);
    }
  }

  final unmatched = _RowWriter(excel[_sheetUnmatched]);
  unmatched.header([l10n.colOperation, l10n.studyNameLabel]);
  for (final entry in comparison.unmatched) {
    unmatched.row([
      TextCellValue(entry.name),
      TextCellValue(entry.studyName),
    ]);
  }

  excel.setDefaultSheet(_sheetStudies);
  for (final name in excel.tables.keys.toList()) {
    if (!ours.contains(name)) excel.delete(name);
  }

  final bytes = excel.encode();
  if (bytes == null) throw StateError('XLSX encoding produced no bytes');
  return Uint8List.fromList(bytes);
}

/// Builds the **analysis artifact**: numbers, not pictures (DESIGN.md §5).
/// Every duration is written as a numeric value in decimal seconds so the cells
/// are directly chartable and formula-friendly; the display formatting used in
/// the app/PDF would be dead text in a spreadsheet.
Uint8List buildStudyXlsx(
  StudyExportPayload payload,
  AppLocalizations l10n, {
  String? localeName,
}) {
  const ours = {_sheetSummary, _sheetOperations, _sheetSegments};

  final excel = Excel.createExcel();
  _writeSummary(excel[_sheetSummary], payload, l10n, localeName);
  _writeOperations(excel[_sheetOperations], payload.report, l10n);
  _writeSegments(excel[_sheetSegments], payload.report, l10n);

  // `createExcel` seeds a default sheet; drop it so only our sheets ship.
  excel.setDefaultSheet(_sheetSummary);
  for (final name in excel.tables.keys.toList()) {
    if (!ours.contains(name)) excel.delete(name);
  }

  final bytes = excel.encode();
  if (bytes == null) throw StateError('XLSX encoding produced no bytes');
  return Uint8List.fromList(bytes);
}

/// The Sampling Study analysis artifact (DESIGN.md §11.7).
///
/// One workbook, flat: `Summary` (criteria and verdict), `Statistics` (one row
/// per operation), `Observations` (one row per pass × operation) and `Segments`
/// (every pass, with a Pass column). Sheets per pass were rejected — ten passes
/// would be twenty-two sheets, and a formula written against one would have to
/// be rewritten for each of the others.
Uint8List buildSamplingXlsx(
  SamplingExportPayload payload,
  AppLocalizations l10n, {
  String? localeName,
}) {
  const ours = {
    _sheetSummary,
    _sheetStatistics,
    _sheetObservations,
    _sheetSegments,
  };

  final excel = Excel.createExcel();
  _writeSamplingSummary(excel[_sheetSummary], payload, l10n, localeName);
  _writeStatistics(excel[_sheetStatistics], payload.report, l10n);
  _writeObservations(excel[_sheetObservations], payload.report, l10n);
  _writeSamplingSegments(excel[_sheetSegments], payload, l10n);

  excel.setDefaultSheet(_sheetSummary);
  for (final name in excel.tables.keys.toList()) {
    if (!ours.contains(name)) excel.delete(name);
  }

  final bytes = excel.encode();
  if (bytes == null) throw StateError('XLSX encoding produced no bytes');
  return Uint8List.fromList(bytes);
}

void _writeSamplingSummary(
  Sheet sheet,
  SamplingExportPayload payload,
  AppLocalizations l10n,
  String? localeName,
) {
  final r = payload.report;
  final w = _RowWriter(sheet);

  w.heading(payload.study.name);
  for (final f in studyHeaderFields(payload.study, l10n, localeName: localeName)) {
    w.labelled(f.label, TextCellValue(f.value!));
  }
  if (payload.study.notes != null && payload.study.notes!.isNotEmpty) {
    w.labelled(l10n.studyFieldNotes, TextCellValue(payload.study.notes!));
  }
  w.blank();

  w.heading(l10n.studyCriteriaSection);
  // As fractions, not "95%" text: an analyst re-deriving n needs a number.
  w.labelled(l10n.studyConfidenceLevel, DoubleCellValue(r.confidenceLevel));
  w.labelled(
      l10n.studyRelativePrecision, DoubleCellValue(r.relativePrecision));
  w.labelled(l10n.passesTitle, IntCellValue(r.adequacy.passesTaken));
  w.labelled(
    l10n.samplingRequired,
    r.adequacy.passesRequired == null
        ? TextCellValue('')
        : IntCellValue(r.adequacy.passesRequired!),
  );
  // The governing operation is the instruction the verdict amounts to (§11.5),
  // so it travels into the artifact rather than staying on screen.
  w.labelled(
    l10n.samplingGovernedBy(''),
    TextCellValue(r.adequacy.governing?.operation.name ?? ''),
  );
  if (r.adequacy.neverTimed.isNotEmpty) {
    w.labelled(
      l10n.samplingNeverTimed(''),
      TextCellValue(r.adequacy.neverTimed.map((o) => o.name).join(', ')),
    );
  }
  w.blank();

  w.heading(l10n.samplingReportTitle);
  w.labelled(_seconds(l10n, l10n.samplingMeanWorkContent),
      DoubleCellValue(msToSeconds(r.meanWorkContentMs.round())));
  w.labelled(
    l10n.reportEfficiency,
    r.efficiency == null ? TextCellValue('') : DoubleCellValue(r.efficiency!),
  );
  w.labelled(l10n.samplingExcludedNote(0), IntCellValue(r.excludedReadingCount));
  w.labelled(l10n.samplingManualNote(0), IntCellValue(r.manualReadingCount));
  w.blank();

  w.heading(l10n.reportRollupTitle);
  w.header([l10n.operationCategoryLabel, _seconds(l10n, l10n.colObserved), '%']);
  final total = r.meanWorkContentMs;
  for (final c in OperationCategory.values) {
    final ms = r.workContentByCategory[c] ?? 0;
    if (ms == 0) continue;
    w.row([
      TextCellValue(categoryLabel(l10n, c)),
      DoubleCellValue(msToSeconds(ms.round())),
      DoubleCellValue(total == 0 ? 0 : ms / total),
    ]);
  }
  w.blank();

  if (r.wastePareto.isNotEmpty) {
    w.heading(l10n.reportParetoTitle);
    w.header([l10n.operationSubtypeLabel, _seconds(l10n, l10n.colObserved)]);
    for (final bar in r.wastePareto) {
      w.row([
        TextCellValue(bar.subtype != null
            ? subtypeName(l10n, bar.subtype!)
            : l10n.wasteUnlabeled),
        DoubleCellValue(msToSeconds(bar.ms.round())),
      ]);
    }
  }
}

/// One row per operation: the summary an analyst checks against their handbook.
///
/// The t value and degrees of freedom travel with it deliberately — Student's t
/// asks for one to three more passes than the Z formula in most cronoanálise
/// texts, and without them a hand check finds a disagreement and no way to
/// explain it. With them, `n = (t·s/(E·x̄))²` reproduces this row.
void _writeStatistics(
    Sheet sheet, SamplingReport report, AppLocalizations l10n) {
  final w = _RowWriter(sheet);
  w.header([
    l10n.colOperation,
    l10n.operationCategoryLabel,
    l10n.operationSubtypeLabel,
    l10n.samplingCount,
    _seconds(l10n, l10n.samplingMean),
    _seconds(l10n, l10n.colMin),
    _seconds(l10n, l10n.colMax),
    _seconds(l10n, l10n.samplingRange),
    _seconds(l10n, l10n.samplingStdDev),
    l10n.samplingCv,
    l10n.samplingRequired,
    't',
    'df',
    _seconds(l10n, l10n.colReference),
    l10n.reportEfficiency,
  ]);

  for (final row in report.rows) {
    final s = row.statistics;
    final size = row.sampleSize;
    w.row([
      TextCellValue(row.operation.name),
      TextCellValue(categoryLabel(l10n, row.operation.category)),
      TextCellValue(row.subtype == null ? '' : subtypeName(l10n, row.subtype!)),
      IntCellValue(row.includedCount),
      _optionalSeconds(s?.mean),
      s == null ? TextCellValue('') : DoubleCellValue(msToSeconds(s.min)),
      s == null ? TextCellValue('') : DoubleCellValue(msToSeconds(s.max)),
      s == null ? TextCellValue('') : DoubleCellValue(msToSeconds(s.range)),
      _optionalSeconds(s?.standardDeviation),
      _optionalDouble(s?.coefficientOfVariation),
      // An unplanned operation is reported but not judged (§11.2), so its
      // required-n is blank rather than a number nobody should act on.
      row.countsTowardVerdict && size?.required_ != null
          ? IntCellValue(size!.required_!)
          : TextCellValue(''),
      _optionalDouble(size?.tValue),
      size?.degreesOfFreedom == null
          ? TextCellValue('')
          : IntCellValue(size!.degreesOfFreedom!),
      row.referenceStandardMs == null
          ? TextCellValue('')
          : DoubleCellValue(msToSeconds(row.referenceStandardMs!)),
      _optionalDouble(row.efficiency),
    ]);
  }
}

/// One row per pass × operation — the raw readings the statistics came from.
///
/// The excluded and manual flags travel with the values, which is what extends
/// §5's guarantee from the reported overlap to the reported mean: filter this
/// sheet to `Excluded = 0` and average it, and you get our number.
void _writeObservations(
    Sheet sheet, SamplingReport report, AppLocalizations l10n) {
  final w = _RowWriter(sheet);
  w.header([
    l10n.passesTitle,
    l10n.colOperation,
    _seconds(l10n, l10n.colObserved),
    l10n.passExcludedBadge,
    l10n.samplingManualNote(0),
    l10n.passExcludeReasonHint,
  ]);

  for (final row in report.rows) {
    for (final reading in row.readings) {
      // A pass that never timed this operation contributes no row at all: a
      // zero would be a measurement, and a blank row would be a reading.
      if (reading.ms == null) continue;
      w.row([
        IntCellValue(reading.passNumber),
        TextCellValue(row.operation.name),
        DoubleCellValue(msToSeconds(reading.ms!)),
        // 1/0 rather than a word, so the column filters and sums.
        IntCellValue(reading.isExcluded ? 1 : 0),
        IntCellValue(reading.isManual ? 1 : 0),
        TextCellValue(reading.reason ?? ''),
      ]);
    }
  }
}

CellValue _optionalSeconds(num? value) => value == null
    ? TextCellValue('')
    : DoubleCellValue(msToSeconds(value.round()));

CellValue _optionalDouble(double? value) =>
    value == null ? TextCellValue('') : DoubleCellValue(value);

void _writeSummary(
  Sheet sheet,
  StudyExportPayload payload,
  AppLocalizations l10n,
  String? localeName,
) {
  final r = payload.report;
  final w = _RowWriter(sheet);

  w.heading(payload.study.name);
  for (final f in studyHeaderFields(payload.study, l10n, localeName: localeName)) {
    w.labelled(f.label, TextCellValue(f.value!));
  }
  if (payload.study.notes != null && payload.study.notes!.isNotEmpty) {
    w.labelled(l10n.studyFieldNotes, TextCellValue(payload.study.notes!));
  }
  w.blank();

  w.heading(l10n.reportTitle);
  w.labelled(_seconds(l10n, l10n.reportTotalElapsed),
      DoubleCellValue(msToSeconds(r.totalElapsedMs)));
  w.labelled(_seconds(l10n, l10n.reportWorkContent),
      DoubleCellValue(msToSeconds(r.totalWorkContentMs)));
  w.labelled(_seconds(l10n, l10n.reportSimultaneous),
      DoubleCellValue(msToSeconds(r.simultaneousMs)));
  w.labelled(_seconds(l10n, l10n.reportUnattributed),
      DoubleCellValue(msToSeconds(r.unattributedMs)));
  w.labelled(l10n.timingValueAddedRatio, DoubleCellValue(r.valueAddedRatio));
  w.labelled(
    l10n.reportEfficiency,
    r.efficiency == null ? TextCellValue('') : DoubleCellValue(r.efficiency!),
  );
  w.blank();

  w.heading(l10n.reportRollupTitle);
  w.header([l10n.operationCategoryLabel, _seconds(l10n, l10n.colObserved), '%']);
  final total = r.totalWorkContentMs;
  for (final c in OperationCategory.values) {
    final ms = r.workContentByCategory[c] ?? 0;
    if (ms == 0) continue;
    w.row([
      TextCellValue(categoryLabel(l10n, c)),
      DoubleCellValue(msToSeconds(ms)),
      DoubleCellValue(total == 0 ? 0 : ms / total),
    ]);
  }
  w.blank();

  if (r.wastePareto.isNotEmpty) {
    w.heading(l10n.reportParetoTitle);
    w.header([l10n.operationSubtypeLabel, _seconds(l10n, l10n.colObserved)]);
    for (final bar in r.wastePareto) {
      w.row([
        TextCellValue(bar.subtype != null
            ? subtypeName(l10n, bar.subtype!)
            : l10n.wasteUnlabeled),
        DoubleCellValue(msToSeconds(bar.ms)),
      ]);
    }
  }
}

void _writeOperations(
    Sheet sheet, TimeStudyReport report, AppLocalizations l10n) {
  // Measured extent per operation, so Start/End describe what the clock saw
  // rather than where a fabricated block happens to land.
  final measured = <String, TimelineRow>{
    for (final row in report.timeline)
      if (row.hasMeasured) row.operation.id: row,
  };

  final w = _RowWriter(sheet);
  w.header([
    '#',
    l10n.colOperation,
    l10n.operationCategoryLabel,
    l10n.operationSubtypeLabel,
    l10n.colStart,
    l10n.colEnd,
    _seconds(l10n, l10n.colObserved),
    _seconds(l10n, l10n.colReference),
    l10n.reportEfficiency,
    l10n.colNotes,
  ]);

  for (var i = 0; i < report.rows.length; i++) {
    final row = report.rows[i];
    final timed = measured[row.operation.id];
    final blocks = timed?.blocks.where((b) => b.measured);

    w.row([
      IntCellValue(i + 1),
      TextCellValue(row.operation.name),
      TextCellValue(categoryLabel(l10n, row.operation.category)),
      TextCellValue(row.subtype == null ? '' : subtypeName(l10n, row.subtype!)),
      _clock(report, blocks?.first.startMs),
      _clock(report, blocks?.last.endMs),
      row.observedMs == null
          ? TextCellValue('')
          : DoubleCellValue(msToSeconds(row.observedMs!)),
      row.referenceStandardMs == null
          ? TextCellValue('')
          : DoubleCellValue(msToSeconds(row.referenceStandardMs!)),
      row.efficiency == null
          ? TextCellValue('')
          : DoubleCellValue(row.efficiency!),
      TextCellValue(row.notes ?? ''),
    ]);
  }
}

/// One row per **measured** segment — the raw evidence, and the only form that
/// lets an analyst recompute overlap or cross-reference machine logs.
///
/// These are exactly the intervals the Gantt draws and `simultaneousMs` is
/// swept from, so the reported figure can be reproduced from this sheet.
/// Fabricated (manual-override) time is deliberately absent: it is not a
/// segment. A paused operation appears as two rows.
void _writeSegments(
    Sheet sheet, TimeStudyReport report, AppLocalizations l10n) {
  final w = _RowWriter(sheet);
  w.header([
    l10n.colOperation,
    '#',
    l10n.colStart,
    l10n.colEnd,
    _seconds(l10n, l10n.colObserved),
  ]);
  _writeSegmentRows(w, report, passNumber: null);
}

/// The Segments sheet of a Sampling Study: the same rows, from every pass, with
/// a leading Pass column (DESIGN.md §11.7).
///
/// One flat table rather than a sheet per pass — one row per fact, so the whole
/// study pivots. Excluded passes are here too: a segment is evidence of what the
/// clock saw, and exclusion is a statement about the average, not about whether
/// the measurement happened.
void _writeSamplingSegments(
    Sheet sheet, SamplingExportPayload payload, AppLocalizations l10n) {
  final w = _RowWriter(sheet);
  w.header([
    l10n.passesTitle,
    l10n.colOperation,
    '#',
    l10n.colStart,
    l10n.colEnd,
    _seconds(l10n, l10n.colObserved),
  ]);
  for (final pass in payload.passes) {
    _writeSegmentRows(w, pass.report, passNumber: pass.number);
  }
}

void _writeSegmentRows(_RowWriter w, TimeStudyReport report,
    {required int? passNumber}) {
  for (final row in report.timeline) {
    var index = 0;
    for (final block in row.blocks) {
      if (!block.measured) continue;
      index++;
      w.row([
        if (passNumber != null) IntCellValue(passNumber),
        TextCellValue(row.operation.name),
        IntCellValue(index),
        _clock(report, block.startMs),
        _clock(report, block.endMs),
        DoubleCellValue(msToSeconds(block.durationMs)),
      ]);
    }
  }
}

/// A wall-clock timestamp when the study was timed live, otherwise blank — a
/// transcribed study has no clock readings to report, and inventing them here
/// would be worse than an empty cell.
CellValue _clock(TimeStudyReport report, int? epochMs) {
  if (epochMs == null || !report.timelineHasClock) return TextCellValue('');
  final t = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return DateTimeCellValue(
    year: t.year,
    month: t.month,
    day: t.day,
    hour: t.hour,
    minute: t.minute,
    second: t.second,
  );
}

/// Marks a duration column with its unit, since the values are raw seconds.
String _seconds(AppLocalizations l10n, String label) =>
    '$label (${l10n.settingsUnitSeconds.toLowerCase()})';

/// Appends rows top-to-bottom, tracking the cursor so callers never juggle row
/// indices (which is where sheet-building code usually goes wrong).
class _RowWriter {
  _RowWriter(this._sheet);

  final Sheet _sheet;
  int _row = 0;

  void heading(String text) {
    _cell(0, TextCellValue(text), bold: true);
    _row++;
  }

  void labelled(String label, CellValue value) {
    _cell(0, TextCellValue(label));
    _cell(1, value);
    _row++;
  }

  void header(List<String> labels) {
    for (var i = 0; i < labels.length; i++) {
      _cell(i, TextCellValue(labels[i]), bold: true);
    }
    _row++;
  }

  void row(List<CellValue> values) {
    for (var i = 0; i < values.length; i++) {
      _cell(i, values[i]);
    }
    _row++;
  }

  void blank() => _row++;

  void _cell(int column, CellValue value, {bool bold = false}) {
    final cell = _sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: _row),
    );
    cell.value = value;
    if (bold) cell.cellStyle = CellStyle(bold: true);
  }
}
