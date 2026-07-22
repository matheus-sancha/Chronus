import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../common/duration_format.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../analysis/application/time_study_report.dart';
import '../../analysis/application/timeline_axis.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../application/export_payload.dart';

/// Builds the **presentation artifact**: study header metadata, the summary
/// tiles, the category roll-up, the timeline strip, the waste Pareto, the
/// operation breakdown table and the attached photos — one fixed template, no
/// branding (DESIGN.md §5).
///
/// Charts are drawn as native PDF widgets rather than rasterized screenshots:
/// they stay vector-sharp, and the builder needs no widget tree, so it is unit
/// testable. Category identity is carried by a text column as well as colour,
/// so the report survives black-and-white printing.
Future<Uint8List> buildStudyPdf(
  StudyExportPayload payload,
  AppLocalizations l10n, {
  String? localeName,
}) async {
  final report = payload.report;
  final doc = pw.Document(title: payload.study.name);
  final photos = await _loadPhotos(payload);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 40),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: _text(payload.study.name, color: _muted),
            ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: _muted)),
      ),
      build: (context) => [
        _title(payload.study.name, l10n.reportTitle),
        _headerTable(payload, l10n, localeName),
        if (payload.study.notes != null && payload.study.notes!.isNotEmpty)
          _notes(l10n, payload.study.notes!),
        pw.SizedBox(height: 18),
        _summaryTiles(report, l10n),
        pw.SizedBox(height: 20),
        _section(l10n.reportRollupTitle),
        _rollup(report, l10n),
        if (report.timeline.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          _section(l10n.reportTimelineTitle),
          ..._timeline(report, l10n),
        ],
        if (report.wastePareto.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          _section(l10n.reportParetoTitle),
          _pareto(report, l10n),
        ],
        pw.SizedBox(height: 20),
        _section(l10n.studyOperationsSection),
        _breakdown(report, l10n),
        if (photos.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          _section(l10n.photosAction),
          ..._photoBlocks(photos),
        ],
      ],
    ),
  );

  return doc.save();
}

// --- text ------------------------------------------------------------------

/// The PDF built-in fonts cover Latin-1 — every letter pt-BR, Spanish and
/// English need — but **not** typographic punctuation, which the renderer drops
/// silently rather than failing. Fold those to ASCII on the way in, so a dash
/// or ellipsis introduced by a translator can never blank out a label.
///
/// Accented letters pass through untouched; only punctuation is rewritten.
String pdfSafeText(String text) => text.replaceAllMapped(
      RegExp(r'[‐-―‘’“”…   ]'),
      (m) => switch (m[0]) {
        '…' => '...',
        '‘' || '’' => "'",
        '“' || '”' => '"',
        ' ' || ' ' || ' ' => ' ',
        _ => '-',
      },
    );

/// Every string entering the document goes through [pdfSafeText] here, so no call
/// site has to remember to sanitize.
pw.Widget _text(String data, {double fontSize = 9, bool bold = false, PdfColor? color, pw.TextAlign? align, int? maxLines}) =>
    pw.Text(
      pdfSafeText(data),
      textAlign: align,
      maxLines: maxLines,
      style: pw.TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: bold ? pw.FontWeight.bold : null,
      ),
    );

// --- palette ---------------------------------------------------------------

const _muted = PdfColor.fromInt(0xFF6B7280);
const _rule = PdfColor.fromInt(0xFFD1D5DB);
const _tint = PdfColor.fromInt(0xFFF3F4F6);

/// Reuses the app's semantic category colours so a printed report and the
/// on-screen report read identically.
PdfColor _categoryPdfColor(OperationCategory category) =>
    PdfColor.fromInt(categoryColor(category).toARGB32());

// --- sections --------------------------------------------------------------

pw.Widget _title(String studyName, String reportLabel) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _text(reportLabel, fontSize: 10, color: _muted),
        pw.SizedBox(height: 2),
        _text(studyName, fontSize: 20, bold: true),
        pw.SizedBox(height: 10),
        pw.Divider(height: 1, color: _rule),
        pw.SizedBox(height: 10),
      ],
    );

pw.Widget _section(String title) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: _text(title, fontSize: 12, bold: true),
    );

/// Study metadata in two columns, blank optional fields omitted.
pw.Widget _headerTable(
    StudyExportPayload payload, AppLocalizations l10n, String? localeName) {
  final fields = studyHeaderFields(payload.study, l10n, localeName: localeName);
  return pw.Wrap(
    children: [
      for (final f in fields)
        pw.Container(
          width: 258,
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: _labelled(f.label, f.value!),
        ),
    ],
  );
}

pw.Widget _notes(AppLocalizations l10n, String notes) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: _labelled(l10n.studyFieldNotes, notes),
    );

pw.Widget _labelled(String label, String value) => pw.RichText(
      text: pw.TextSpan(children: [
        pw.TextSpan(
            text: pdfSafeText('$label: '),
            style: const pw.TextStyle(fontSize: 9, color: _muted)),
        pw.TextSpan(
            text: pdfSafeText(value), style: const pw.TextStyle(fontSize: 9)),
      ]),
    );

pw.Widget _summaryTiles(TimeStudyReport r, AppLocalizations l10n) {
  pw.Widget tile(String label, String value) => pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.only(right: 8),
          padding: const pw.EdgeInsets.all(10),
          decoration: const pw.BoxDecoration(
            color: _tint,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _text(label, fontSize: 8, color: _muted),
              pw.SizedBox(height: 3),
              _text(value, fontSize: 15, bold: true),
            ],
          ),
        ),
      );

  // Same six figures, in the same order, as the report screen.
  return pw.Column(children: [
    pw.Row(children: [
      tile(l10n.reportTotalElapsed, formatHmsd(r.totalElapsedMs)),
      tile(l10n.reportWorkContent, formatHmsd(r.totalWorkContentMs)),
      tile(l10n.reportSimultaneous, formatHmsd(r.simultaneousMs)),
    ]),
    pw.SizedBox(height: 8),
    pw.Row(children: [
      tile(l10n.reportUnattributed, formatHmsd(r.unattributedMs)),
      tile(l10n.timingValueAddedRatio, _percent(r.valueAddedRatio, 1)),
      tile(l10n.reportEfficiency,
          r.efficiency == null ? '—' : _percent(r.efficiency!, 0)),
    ]),
  ]);
}

/// 100 % stacked bar of work content by category + a labelled legend.
pw.Widget _rollup(TimeStudyReport r, AppLocalizations l10n) {
  final total = r.totalWorkContentMs;
  final cats = [
    for (final c in OperationCategory.values)
      if ((r.workContentByCategory[c] ?? 0) > 0) (c, r.workContentByCategory[c]!),
  ];
  if (cats.isEmpty) return pw.SizedBox();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        height: 16,
        child: pw.Row(
          children: [
            for (var i = 0; i < cats.length; i++) ...[
              if (i > 0) pw.SizedBox(width: 2),
              pw.Expanded(
                flex: cats[i].$2,
                child: pw.Container(
                    color: _categoryPdfColor(cats[i].$1)),
              ),
            ],
          ],
        ),
      ),
      pw.SizedBox(height: 8),
      for (final (c, ms) in cats)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(children: [
            pw.Container(width: 8, height: 8, color: _categoryPdfColor(c)),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _text(categoryLabel(l10n, c))),
            _text(formatHmsd(ms)),
            pw.SizedBox(width: 12),
            pw.SizedBox(
              width: 44,
              child: _text(_percent(ms / total, 1), align: pw.TextAlign.right),
            ),
          ]),
        ),
    ],
  );
}

// --- timeline Gantt ---------------------------------------------------------

const _ganttLabelWidth = 104.0;
const _ganttRowHeight = 13.0;
const _ganttBarHeight = 8.0;

/// Rows are chunked so a long study breaks across pages between rows rather
/// than overflowing, and each chunk repeats the axis — a page of unlabelled
/// bars would be unreadable.
const _ganttRowsPerChunk = 22;

/// The same wall-clock Gantt the screen draws: one row per operation in
/// planned-sequence order, blocks at their true timestamps, concurrency visible
/// as vertically aligned bars and pauses as gaps.
///
/// Positioning uses proportional [pw.Expanded] flex rather than absolute
/// offsets: every row's cells sum to exactly the timeline span, so rows stay
/// aligned to one axis at any page width.
List<pw.Widget> _timeline(TimeStudyReport r, AppLocalizations l10n) {
  if (r.timelineSpanMs <= 0) return const [];

  final chunks = <pw.Widget>[];
  for (var start = 0; start < r.timeline.length; start += _ganttRowsPerChunk) {
    final end =
        math.min(start + _ganttRowsPerChunk, r.timeline.length);
    chunks.add(pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        if (start > 0) pw.SizedBox(height: 8),
        _ganttAxis(r),
        pw.SizedBox(height: 3),
        for (final row in r.timeline.sublist(start, end)) _ganttRow(r, row),
      ],
    ));
  }

  if (!r.timelineHasClock) {
    chunks.add(pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: _text(l10n.timelineRelativeAxis, fontSize: 7, color: _muted),
    ));
  }
  return chunks;
}

pw.Widget _ganttAxis(TimeStudyReport r) {
  final ticks = timelineTicks(r);
  return pw.Row(children: [
    pw.SizedBox(width: _ganttLabelWidth),
    pw.Expanded(
      child: pw.Row(children: [
        for (var i = 0; i < ticks.length; i++)
          pw.Expanded(
            child: _text(
              ticks[i].label,
              fontSize: 6.5,
              color: _muted,
              // Bracket the bars: first tick hugs the origin, last the end.
              align: i == 0
                  ? pw.TextAlign.left
                  : i == ticks.length - 1
                      ? pw.TextAlign.right
                      : pw.TextAlign.center,
            ),
          ),
      ]),
    ),
  ]);
}

pw.Widget _ganttRow(TimeStudyReport r, TimelineRow row) {
  final color = _categoryPdfColor(row.operation.category);
  final cells = <pw.Widget>[];
  var cursor = r.timelineStartMs;

  for (var i = 0; i < row.blocks.length; i++) {
    final block = row.blocks[i];
    final gap = block.startMs - cursor;
    if (gap > 0) {
      cells.add(pw.Expanded(
        flex: gap,
        // An interior gap is a pause: bridge it so the row still reads as one
        // operation. A leading gap is just empty axis.
        child: i == 0
            ? pw.SizedBox()
            : pw.Container(height: 0.5, color: color),
      ));
    }
    cells.add(pw.Expanded(
      // Zero-length blocks would make flex collapse the row's arithmetic.
      flex: math.max(block.durationMs, 1),
      child: block.measured
          ? pw.Container(
              height: _ganttBarHeight,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            )
          : pw.CustomPaint(
              painter: (canvas, size) => _paintHatch(canvas, size, color),
              // CustomPaint with no child collapses to zero, exactly like its
              // Flutter counterpart — the child is what gives it a box.
              child: pw.Container(height: _ganttBarHeight),
            ),
    ));
    cursor = block.endMs;
  }

  final tail = r.timelineEndMs - cursor;
  if (tail > 0) cells.add(pw.Expanded(flex: tail, child: pw.SizedBox()));

  return pw.Container(
    height: _ganttRowHeight,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(
          width: _ganttLabelWidth,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(right: 6),
            child: _text(row.operation.name, fontSize: 6.5, maxLines: 1),
          ),
        ),
        pw.Expanded(child: pw.Row(children: cells)),
      ],
    ),
  );
}

/// Diagonal hatching for reported-but-not-measured time.
///
/// Real lines, not a lighter tint: a tint of green and a tint of red are the
/// same grey once the report is printed, which is precisely when the reader
/// most needs to tell measured from fabricated.
void _paintHatch(PdfGraphics canvas, PdfPoint size, PdfColor color) {
  const spacing = 2.5;
  canvas
    ..saveContext()
    ..drawRect(0, 0, size.x, size.y)
    ..clipPath()
    ..setStrokeColor(color)
    ..setLineWidth(0.6);
  for (var i = -size.y; i < size.x; i += spacing) {
    canvas
      ..moveTo(i, 0)
      ..lineTo(i + size.y, size.y);
  }
  canvas
    ..strokePath()
    ..restoreContext()
    // Outline drawn outside the clip so the block keeps a crisp edge.
    ..setStrokeColor(color)
    ..setLineWidth(0.5)
    ..drawRect(0, 0, size.x, size.y)
    ..strokePath();
}

/// Ranked waste bars — one hue for the whole single series; identity is in the
/// text label.
pw.Widget _pareto(TimeStudyReport r, AppLocalizations l10n) {
  final color = _categoryPdfColor(OperationCategory.unproductive);
  final max = r.wastePareto.first.ms;
  return pw.Column(children: [
    for (final bar in r.wastePareto)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(children: [
          pw.SizedBox(
            width: 110,
            child: _text(
              bar.subtype != null
                  ? subtypeName(l10n, bar.subtype!)
                  : l10n.wasteUnlabeled,
              maxLines: 1,
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Row(children: [
              pw.Expanded(
                flex: max == 0 ? 0 : bar.ms,
                child: pw.Container(height: 12, color: color),
              ),
              pw.Expanded(flex: max == 0 ? 1 : (max - bar.ms), child: pw.SizedBox()),
            ]),
          ),
          pw.SizedBox(width: 6),
          pw.SizedBox(
            width: 52,
            child: _text(formatHmsd(bar.ms), align: pw.TextAlign.right),
          ),
        ]),
      ),
  ]);
}

pw.Widget _breakdown(TimeStudyReport r, AppLocalizations l10n) {
  String t(int? ms) => ms == null ? '—' : formatHmsd(ms);

  return pw.TableHelper.fromTextArray(
    border: pw.TableBorder.symmetric(
      inside: const pw.BorderSide(color: _rule, width: 0.5),
      outside: const pw.BorderSide(color: _rule, width: 0.5),
    ),
    headerDecoration: const pw.BoxDecoration(color: _tint),
    headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
    cellStyle: const pw.TextStyle(fontSize: 8),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    cellAlignments: {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerLeft,
      3: pw.Alignment.centerRight,
      4: pw.Alignment.centerRight,
      5: pw.Alignment.centerRight,
      6: pw.Alignment.centerLeft,
    },
    columnWidths: {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(1.6),
      2: const pw.FlexColumnWidth(1.8),
      3: const pw.FlexColumnWidth(1.4),
      4: const pw.FlexColumnWidth(1.4),
      5: const pw.FlexColumnWidth(1.2),
      6: const pw.FlexColumnWidth(3),
    },
    headers: [
      l10n.colOperation,
      l10n.operationCategoryLabel,
      l10n.operationSubtypeLabel,
      l10n.colObserved,
      l10n.colReference,
      l10n.reportEfficiency,
      l10n.colNotes,
    ].map(pdfSafeText).toList(),
    data: [
      for (final row in r.rows)
        [
          row.operation.name,
          categoryLabel(l10n, row.operation.category),
          row.subtype == null ? '—' : subtypeName(l10n, row.subtype!),
          t(row.observedMs),
          t(row.referenceStandardMs),
          row.efficiency == null ? '—' : _percent(row.efficiency!, 0),
          row.notes ?? '',
        ].map(pdfSafeText).toList(),
    ],
  );
}

// --- photos ----------------------------------------------------------------

/// Photos grouped under the operation they belong to. Missing files (deleted
/// outside the app) are skipped rather than failing the whole export.
Future<List<({String operation, List<({pw.ImageProvider image, String? caption})> items})>>
    _loadPhotos(StudyExportPayload payload) async {
  final groups =
      <({String operation, List<({pw.ImageProvider image, String? caption})> items})>[];

  for (final row in payload.report.rows) {
    final photos = payload.photosByStudyOperationId[row.operation.id];
    if (photos == null || photos.isEmpty) continue;

    final items = <({pw.ImageProvider image, String? caption})>[];
    for (final photo in photos) {
      final file = File(photo.absolutePath);
      if (!await file.exists()) continue;
      items.add((
        image: pw.MemoryImage(await file.readAsBytes()),
        caption: photo.caption,
      ));
    }
    if (items.isNotEmpty) {
      groups.add((operation: row.operation.name, items: items));
    }
  }
  return groups;
}

List<pw.Widget> _photoBlocks(
    List<({String operation, List<({pw.ImageProvider image, String? caption})> items})>
        groups) {
  return [
    for (final group in groups)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _text(group.operation, bold: true),
            pw.SizedBox(height: 5),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in group.items)
                  pw.Container(
                    width: 160,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(item.image, width: 160, height: 120,
                            fit: pw.BoxFit.cover),
                        if (item.caption != null && item.caption!.isNotEmpty)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 2),
                            child: _text(item.caption!,
                                fontSize: 7, color: _muted),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
  ];
}

String _percent(double ratio, int decimals) =>
    '${(ratio * 100).toStringAsFixed(decimals)}%';
