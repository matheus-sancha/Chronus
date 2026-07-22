import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../analysis/application/time_study_report.dart';
import '../../media/application/media_providers.dart';
import '../../studies/application/timing_model.dart';
import '../application/export_delivery.dart';
import '../application/export_payload.dart';
import '../application/export_providers.dart';
import '../data/pdf_export.dart';
import '../data/xlsx_export.dart';

/// The report's export affordance: pick a format, build the artifact, hand it
/// to the platform (share sheet on iOS, save dialog on Windows).
///
/// Building happens off the report data already in hand, so the export always
/// matches exactly what the analyst is looking at.
class ExportButton extends ConsumerStatefulWidget {
  const ExportButton({
    super.key,
    required this.study,
    required this.report,
    required this.timing,
  });

  final Study study;
  final TimeStudyReport report;
  final Map<String, OperationTiming> timing;

  @override
  ConsumerState<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends ConsumerState<ExportButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_busy) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return PopupMenuButton<ExportFormat>(
      icon: const Icon(Icons.ios_share),
      tooltip: l10n.exportAction,
      onSelected: _export,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ExportFormat.pdf,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.exportPdf),
          ),
        ),
        PopupMenuItem(
          value: ExportFormat.xlsx,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.table_chart_outlined),
            title: Text(l10n.exportXlsx),
          ),
        ),
      ],
    );
  }

  Future<void> _export(ExportFormat format) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Captured before the await: iPadOS anchors the share popover to this rect.
    final origin = _globalRect();
    // Drives number/date formatting in the artifact (DESIGN.md §5).
    final locale = Localizations.localeOf(context).toString();

    setState(() => _busy = true);
    try {
      final photos = await resolveOperationPhotos(
        media: ref.read(mediaRepositoryProvider),
        timing: widget.timing,
      );
      final payload = StudyExportPayload(
        study: widget.study,
        report: widget.report,
        photosByStudyOperationId: photos,
      );
      final Uint8List bytes = switch (format) {
        ExportFormat.pdf => await buildStudyPdf(payload, l10n, localeName: locale),
        ExportFormat.xlsx => buildStudyXlsx(payload, l10n, localeName: locale),
      };

      final result = await ref.read(exportDeliveryProvider).deliver(
            bytes: bytes,
            fileName: exportFileName(widget.study, format.extension),
            format: format,
            sharePositionOrigin: origin,
          );
      if (result == ExportResult.delivered) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.exportDone)));
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.exportFailed('$error'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Rect? _globalRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
