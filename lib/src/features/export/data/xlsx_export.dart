import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../analysis/application/time_study_report.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../application/export_payload.dart';

/// Sheet names are fixed identifiers (not localized) so downstream spreadsheets
/// and macros that reference them keep working across app languages.
const _sheetSummary = 'Summary';
const _sheetOperations = 'Operations';

/// Builds the **analysis artifact**: numbers, not pictures (DESIGN.md §5).
/// Every duration is written as a numeric value in decimal seconds so the cells
/// are directly chartable and formula-friendly; the display formatting used in
/// the app/PDF would be dead text in a spreadsheet.
Uint8List buildStudyXlsx(
  StudyExportPayload payload,
  AppLocalizations l10n, {
  String? localeName,
}) {
  final excel = Excel.createExcel();
  _writeSummary(excel[_sheetSummary], payload, l10n, localeName);
  _writeOperations(excel[_sheetOperations], payload.report, l10n);

  // `createExcel` seeds a default sheet; drop it so only our sheets ship.
  excel.setDefaultSheet(_sheetSummary);
  for (final name in excel.tables.keys.toList()) {
    if (name != _sheetSummary && name != _sheetOperations) excel.delete(name);
  }

  final bytes = excel.encode();
  if (bytes == null) throw StateError('XLSX encoding produced no bytes');
  return Uint8List.fromList(bytes);
}

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
  w.labelled(_seconds(l10n, l10n.reportSimultaneous),
      DoubleCellValue(msToSeconds(r.totalWorkContentMs)));
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
  final w = _RowWriter(sheet);
  w.header([
    '#',
    l10n.colOperation,
    l10n.operationCategoryLabel,
    l10n.operationSubtypeLabel,
    _seconds(l10n, l10n.colObserved),
    _seconds(l10n, l10n.colReference),
    l10n.reportEfficiency,
    l10n.colNotes,
  ]);

  for (var i = 0; i < report.rows.length; i++) {
    final row = report.rows[i];
    w.row([
      IntCellValue(i + 1),
      TextCellValue(row.operation.name),
      TextCellValue(categoryLabel(l10n, row.operation.category)),
      TextCellValue(row.subtype == null ? '' : subtypeName(l10n, row.subtype!)),
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
