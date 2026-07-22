import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../analysis/application/time_study_report.dart';
import '../../studies/presentation/study_formatting.dart';

/// A photo to embed in an export, already resolved to an absolute file path by
/// `MediaRepository.absolutePath`. Video is deliberately absent — it is flagged
/// in-app-only and cannot be embedded (DESIGN.md §3.8).
class ExportPhoto {
  const ExportPhoto({required this.absolutePath, this.caption});

  final String absolutePath;
  final String? caption;
}

/// Everything an exporter needs, gathered once so the PDF and XLSX builders are
/// pure functions over data — no widget tree, no database, so both are unit
/// testable. Localization arrives as an [AppLocalizations] (constructible in
/// tests as `AppLocalizationsEn()`), not as pre-resolved strings.
class StudyExportPayload {
  const StudyExportPayload({
    required this.study,
    required this.report,
    required this.photosByStudyOperationId,
  });

  final Study study;
  final TimeStudyReport report;

  /// Keyed by `StudyOperation.id` (not instance id) so exporters can walk the
  /// report rows directly.
  final Map<String, List<ExportPhoto>> photosByStudyOperationId;

  bool get hasPhotos =>
      photosByStudyOperationId.values.any((list) => list.isNotEmpty);
}

/// One labelled study-header field. `value` is null when the optional field was
/// left blank; exporters skip those.
typedef HeaderField = ({String label, String? value});

/// The study header metadata as label/value pairs, in the order both exports
/// present them. Shared so the PDF and the XLSX Summary sheet never drift apart.
List<HeaderField> studyHeaderFields(
  Study study,
  AppLocalizations l10n, {
  String? localeName,
}) {
  final dateFormat = DateFormat.yMMMd(localeName).add_Hm();
  return [
    (label: l10n.studyFieldType, value: studyTypeLabel(l10n, study.type)),
    (label: l10n.studyFieldDate, value: dateFormat.format(study.performedAt)),
    (label: l10n.studyFieldAnalyst, value: study.analyst),
    (label: l10n.studyFieldProcessType, value: study.processType),
    (label: l10n.studyFieldPartProduct, value: study.partProduct),
    (label: l10n.studyFieldProcessOperation, value: study.processOperation),
    (label: l10n.studyFieldMachine, value: study.machineWorkstation),
    (label: l10n.studyFieldLineCell, value: study.lineCell),
    (label: l10n.studyFieldOperator, value: study.operatorName),
    (label: l10n.studyFieldShift, value: study.shift),
    (label: l10n.studyFieldWorkOrder, value: study.workOrderNumber),
  ].where((f) => f.value != null && f.value!.trim().isNotEmpty).toList();
}

/// A filesystem-safe file name for the exported artifact, e.g.
/// `Line-3-cycle-2026-07-21.pdf`.
String exportFileName(Study study, String extension) {
  final slug = study.name
      .trim()
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-');
  final date = DateFormat('yyyy-MM-dd').format(study.performedAt);
  final base = slug.isEmpty ? 'study' : slug;
  return '$base-$date.$extension';
}

/// Milliseconds as decimal seconds, for the XLSX (numbers, not pictures).
double msToSeconds(int ms) => ms / 1000;
