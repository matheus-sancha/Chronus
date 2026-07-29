import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../analysis/application/cross_study_comparison.dart';
import '../application/export_delivery.dart';
import '../application/export_providers.dart';
import '../application/export_payload.dart';
import '../data/pdf_export.dart';
import '../data/xlsx_export.dart';
import 'export_button.dart';

/// Exports a cross-study comparison (DESIGN.md §5: exportable at the
/// comparison level too, in both formats).
///
/// A separate widget from [ExportButton] rather than a third constructor on it:
/// that one resolves photos from a study's timing and names the file after the
/// study, and a comparison has neither. The shared part — the format menu, the
/// busy state, the delivery — is small enough that duplicating it costs less
/// than the branching would.
class ComparisonExportButton extends ConsumerStatefulWidget {
  const ComparisonExportButton({
    super.key,
    required this.projectName,
    required this.comparison,
  });

  final String projectName;
  final CrossStudyComparison comparison;

  @override
  ConsumerState<ComparisonExportButton> createState() =>
      _ComparisonExportButtonState();
}

class _ComparisonExportButtonState
    extends ConsumerState<ComparisonExportButton> {
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
    return PopupMenuButton<ReportFormat>(
      icon: const Icon(Icons.ios_share),
      tooltip: l10n.exportAction,
      onSelected: _export,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ReportFormat.pdf,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.exportPdf),
          ),
        ),
        PopupMenuItem(
          value: ReportFormat.xlsx,
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

  Future<void> _export(ReportFormat format) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Captured before the await: iPadOS anchors the share popover to this rect.
    final origin = _globalRect();
    final locale = Localizations.localeOf(context).toString();

    setState(() => _busy = true);
    try {
      final payload = ComparisonExportPayload(
        projectName: widget.projectName,
        comparison: widget.comparison,
      );
      final Uint8List bytes = switch (format) {
        ReportFormat.pdf =>
          await buildComparisonPdf(payload, l10n, localeName: locale),
        ReportFormat.xlsx =>
          buildComparisonXlsx(payload, l10n, localeName: locale),
      };

      final result = await ref.read(exportDeliveryProvider).deliver(
            bytes: bytes,
            fileName: comparisonFileName(
                widget.projectName, format.delivery.extension),
            format: format.delivery,
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
