import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common/confirm_dialog.dart';
import '../../../common/duration_format.dart';
import '../../../common/duration_input.dart';
import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/classification_labels.dart';
import '../../catalog/presentation/operation_fields.dart';
import '../../catalog/presentation/operation_picker.dart';
import '../../media/application/media_providers.dart';
import '../../media/presentation/media_gallery.dart';
import '../../templates/application/templates_providers.dart';
import '../application/studies_providers.dart';
import '../application/timing_model.dart';
import '../application/timing_providers.dart';
import '../data/study_operation_repository.dart';
import '../data/timing_repository.dart';
import 'study_formatting.dart';

/// The study workspace: build the operation sequence and time it, all in one
/// place. Each row is an independent per-operation timer (start / pause / stop /
/// reset); several may run at once. See DESIGN.md §3.5.
class StudyDetailScreen extends ConsumerWidget {
  const StudyDetailScreen({
    super.key,
    required this.projectId,
    required this.studyId,
  });

  final String projectId;
  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final studyAsync = ref.watch(studyByIdProvider(studyId));

    return Scaffold(
      appBar: AppBar(
        title: Text(studyAsync.value?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: l10n.saveAsTemplateAction,
            onPressed: studyAsync.hasValue
                ? () => _saveAsTemplate(context, ref, studyAsync.value!.name)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.studyEditTitle,
            onPressed: studyAsync.hasValue
                ? () => context.push('/projects/$projectId/studies/$studyId/edit')
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.actionDelete,
            onPressed: studyAsync.hasValue
                ? () => _deleteStudy(context, ref, studyAsync.value!.name)
                : null,
          ),
        ],
      ),
      body: studyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (study) =>
            _Workspace(study: study, projectId: projectId, studyId: studyId),
      ),
    );
  }

  Future<void> _saveAsTemplate(
      BuildContext context, WidgetRef ref, String studyName) async {
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _TemplateNameDialog(initial: studyName),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(templateRepositoryProvider)
        .saveStudyAsTemplate(studyId: studyId, name: name.trim());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveAsTemplateAction)),
      );
    }
  }

  Future<void> _deleteStudy(
      BuildContext context, WidgetRef ref, String name) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteStudyTitle,
      message: l10n.deleteStudyMessage(name),
    );
    if (!confirmed) return;
    await ref.read(studyRepositoryProvider).delete(studyId);
    if (context.mounted) context.pop();
  }
}

class _Workspace extends ConsumerStatefulWidget {
  const _Workspace({
    required this.study,
    required this.projectId,
    required this.studyId,
  });

  final Study study;
  final String projectId;
  final String studyId;

  @override
  ConsumerState<_Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends ConsumerState<_Workspace> {
  Timer? _ticker;
  bool _live = false;

  String get _studyId => widget.studyId;
  TimingRepository get _timing => ref.read(timingRepositoryProvider);
  StudyOperationRepository get _seq =>
      ref.read(studyOperationRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_live && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ops = ref.watch(studyOperationsProvider(_studyId)).value ??
        const <StudyOperation>[];
    final observation = ref.watch(observationProvider(_studyId)).value;
    final instances = observation == null
        ? const <OperationInstance>[]
        : (ref.watch(operationInstancesProvider(observation.id)).value ??
            const <OperationInstance>[]);
    final segments = observation == null
        ? const <OperationTimeSegment>[]
        : (ref.watch(operationSegmentsProvider(observation.id)).value ??
            const <OperationTimeSegment>[]);
    final subtypes = ref.watch(subtypesProvider).value ?? const [];
    final subtypeById = {for (final s in subtypes) s.id: s};
    final mediaCounts =
        ref.watch(operationMediaCountsProvider).value ?? const <String, int>{};

    final timing = timingByOperation(instances: instances, segments: segments);
    _live = timing.values.any((t) => t.state == OperationTimingState.running);
    final total = totalWallClockMs(segments);
    final timed = ops.where((o) => timing[o.id]?.isTimed ?? false).length;

    return Column(
      children: [
        _headerBar(context, l10n, total),
        if (ops.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.timedProgress(timed, ops.length),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: ops.isEmpty
              ? Center(child: Text(l10n.sequenceEmpty))
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: ops.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = ops.map((e) => e.id).toList();
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    _seq.reorder(ids);
                  },
                  itemBuilder: (context, i) {
                    final op = ops[i];
                    final t = timing[op.id] ??
                        OperationTiming(instance: null, segments: const []);
                    final photoCount = t.instance != null
                        ? (mediaCounts[t.instance!.id] ?? 0)
                        : 0;
                    return _row(
                        context, l10n, i, op, t, subtypeById, photoCount);
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: _addOperation,
              icon: const Icon(Icons.add),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              label: Text(l10n.addOperationTitle),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerBar(BuildContext context, AppLocalizations l10n, int totalMs) {
    final dateFmt = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${studyTypeLabel(l10n, widget.study.type)} · '
                  '${dateFmt.formatMediumDate(widget.study.performedAt)}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (widget.study.analyst != null &&
                    widget.study.analyst!.isNotEmpty)
                  Text(
                    widget.study.analyst!,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.workspaceTotalLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              Text(
                formatHmsd(totalMs),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    AppLocalizations l10n,
    int index,
    StudyOperation op,
    OperationTiming t,
    Map<String, OperationSubtype> subtypeById,
    int photoCount,
  ) {
    final theme = Theme.of(context);
    final actual = t.actualMs();
    final isPending = t.state == OperationTimingState.pending;
    final hasNote = t.instance?.notes?.isNotEmpty ?? false;

    return Padding(
      key: ValueKey(op.id),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Opacity(
        opacity: isPending && !t.isTimed ? 0.65 : 1,
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 4),
            _StateGlyph(state: t.state, category: op.category),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(op.name,
                            style: theme.textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (hasNote)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(Icons.sticky_note_2_outlined,
                              size: 15, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      if (photoCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_outlined,
                                  size: 15,
                                  color: theme.colorScheme.onSurfaceVariant),
                              Text(' $photoCount',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Text(
                    _subtitle(l10n, op, subtypeById),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 78,
              child: Text(
                op.referenceStandardMs != null
                    ? formatHmsd(op.referenceStandardMs!)
                    : '—',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            InkWell(
              onTap: () => _editManual(op, t),
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      actual != null ? formatHmsd(actual) : '—',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (t.manualActualMs != null)
                      Text(l10n.manualBadge,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ),
            _controls(l10n, op, t),
            _menu(l10n, op, t.instance?.notes),
          ],
        ),
      ),
    );
  }

  String _subtitle(AppLocalizations l10n, StudyOperation op,
      Map<String, OperationSubtype> subtypeById) {
    final parts = <String>[categoryLabel(l10n, op.category)];
    final sub = op.subtypeId != null ? subtypeById[op.subtypeId] : null;
    if (sub != null) parts.add(subtypeName(l10n, sub));
    if (op.isUnplanned) parts.add(l10n.timingUnplannedTag);
    return parts.join(' · ');
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onPressed,
      {Color? color}) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: onPressed,
    );
  }

  Widget _controls(AppLocalizations l10n, StudyOperation op, OperationTiming t) {
    final start = _iconBtn(Icons.play_arrow, l10n.tooltipStart,
        () => _timing.start(studyId: _studyId, studyOperationId: op.id),
        color: categoryColor(op.category));
    final resume = _iconBtn(Icons.play_arrow, l10n.tooltipResume,
        () => _timing.start(studyId: _studyId, studyOperationId: op.id),
        color: categoryColor(op.category));
    final pause = _iconBtn(
        Icons.pause, l10n.tooltipPause, () => _pause(op));
    final stop = _iconBtn(Icons.stop, l10n.tooltipStop,
        () => _timing.stop(studyId: _studyId, studyOperationId: op.id));
    final stopNext = _iconBtn(Icons.skip_next, l10n.tooltipStopNext,
        () => _timing.stopAndStartNext(studyId: _studyId, studyOperationId: op.id),
        color: categoryColor(op.category));
    final reset =
        _iconBtn(Icons.refresh, l10n.tooltipReset, () => _reset(op));

    final children = switch (t.state) {
      OperationTimingState.pending => [start],
      OperationTimingState.running => [pause, stop, stopNext, reset],
      OperationTimingState.paused => [resume, stop, reset],
      OperationTimingState.done => [resume, reset],
    };
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _menu(AppLocalizations l10n, StudyOperation op, String? note) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => switch (value) {
        'note' => _editNote(op, note),
        'photos' => _openPhotos(op),
        'duplicate' => _seq.duplicate(op.id),
        'edit' => _editOperation(op),
        'delete' => _deleteOperation(op),
        _ => null,
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'note', child: Text(l10n.noteAction)),
        PopupMenuItem(value: 'photos', child: Text(l10n.photosAction)),
        PopupMenuItem(value: 'duplicate', child: Text(l10n.actionDuplicate)),
        PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
        PopupMenuItem(value: 'delete', child: Text(l10n.actionDelete)),
      ],
    );
  }

  Future<void> _openPhotos(StudyOperation op) async {
    final instanceId = await _timing.ensureInstanceId(
        studyId: _studyId, studyOperationId: op.id);
    if (!mounted) return;
    await showMediaGallery(
      context,
      ownerType: MediaOwnerType.operationInstance,
      ownerId: instanceId,
      title: op.name,
    );
  }

  Future<void> _editNote(StudyOperation op, String? current) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(initial: current),
    );
    if (text == null) return; // cancelled
    await _timing.setNote(
        studyId: _studyId, studyOperationId: op.id, note: text);
  }

  // --- actions --------------------------------------------------------------

  Future<void> _pause(StudyOperation op) async {
    final l10n = AppLocalizations.of(context);
    await _timing.pause(studyId: _studyId, studyOperationId: op.id);
    if (!mounted) return;
    final log = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.interruptionTitle),
        content: Text(l10n.interruptionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.interruptionSkip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.interruptionLog),
          ),
        ],
      ),
    );
    if (log != true || !mounted) return;
    final subtype = await showModalBottomSheet<OperationSubtype>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _UnplannedSheet(),
    );
    if (subtype == null) return;
    final newOp = await _seq.insertUnplannedAfter(
      studyId: _studyId,
      afterStudyOperationId: op.id,
      name: subtypeName(l10n, subtype),
      category: subtype.category,
      subtypeId: subtype.id,
    );
    await _timing.start(studyId: _studyId, studyOperationId: newOp.id);
  }

  Future<void> _reset(StudyOperation op) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.resetConfirmTitle,
      message: l10n.resetConfirmMessage(op.name),
    );
    if (!confirmed) return;
    await _timing.reset(studyId: _studyId, studyOperationId: op.id);
  }

  Future<void> _editManual(StudyOperation op, OperationTiming t) async {
    final result = await showDialog<_ManualResult>(
      context: context,
      builder: (_) => _ManualTimeDialog(
        initialMs: t.actualMs(),
        canClear: t.manualActualMs != null,
      ),
    );
    switch (result) {
      case _ManualSet(:final ms):
        await _timing.setManualActual(
            studyId: _studyId, studyOperationId: op.id, milliseconds: ms);
      case _ManualClear():
        await _timing.clearManualActual(
            studyId: _studyId, studyOperationId: op.id);
      case null:
        break;
    }
  }

  Future<void> _addOperation() async {
    final pick = await showOperationPicker(context);
    switch (pick) {
      case PickCatalog(:final operation):
        await _seq.addFromCatalog(studyId: _studyId, operation: operation);
      case PickCustom():
        if (mounted) await _editOperation(null);
      case null:
        break;
    }
  }

  /// Opens the shared operation editor. [op] null => add a custom operation.
  Future<void> _editOperation(StudyOperation? op) async {
    final l10n = AppLocalizations.of(context);
    final draft = OperationDraft(
      name: op?.name ?? '',
      category: op?.category ?? OperationCategory.productive,
      subtypeId: op?.subtypeId,
      referenceStandardMs: op?.referenceStandardMs,
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(op == null
                ? l10n.customOperationTitle
                : l10n.catalogEditTitle),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.actionSave),
              ),
            ],
          ),
          body: OperationFieldsForm(draft: draft),
        ),
      ),
    );
    if (saved == true && draft.name.isNotEmpty) {
      if (op == null) {
        await _seq.addCustom(
          studyId: _studyId,
          name: draft.name,
          category: draft.category,
          subtypeId: draft.subtypeId,
          referenceStandardMs: draft.referenceStandardMs,
        );
      } else {
        await _seq.update(
          id: op.id,
          name: draft.name,
          category: draft.category,
          subtypeId: draft.subtypeId,
          referenceStandardMs: draft.referenceStandardMs,
        );
      }
    }
    draft.dispose();
  }

  Future<void> _deleteOperation(StudyOperation op) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deleteOperationTitle,
      message: l10n.deleteOperationMessage(op.name),
    );
    if (!confirmed) return;
    await _seq.remove(op.id);
  }
}

/// Leading state indicator: pending ○ · running ● · paused ‖ · done ✓.
class _StateGlyph extends StatelessWidget {
  const _StateGlyph({required this.state, required this.category});

  final OperationTimingState state;
  final OperationCategory category;

  @override
  Widget build(BuildContext context) {
    final accent = categoryColor(category);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final (icon, color) = switch (state) {
      OperationTimingState.pending => (Icons.radio_button_unchecked, muted),
      OperationTimingState.running => (Icons.play_circle, accent),
      OperationTimingState.paused => (Icons.pause_circle, accent),
      OperationTimingState.done => (Icons.check_circle, accent),
    };
    return Icon(icon, color: color, size: 22);
  }
}

/// Bottom sheet of unproductive (waste) subtypes for a quick unplanned insert.
class _UnplannedSheet extends ConsumerWidget {
  const _UnplannedSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subtypes = ref.watch(subtypesProvider).value ?? const [];
    final wastes = subtypes
        .where((s) => s.category == OperationCategory.unproductive)
        .toList();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.timingInsertUnplannedTitle,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final s in wastes)
                  ListTile(
                    leading:
                        Icon(Icons.circle, size: 14, color: categoryColor(s.category)),
                    title: Text(subtypeName(l10n, s)),
                    onTap: () => Navigator.of(context).pop(s),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

sealed class _ManualResult {}

class _ManualSet extends _ManualResult {
  _ManualSet(this.ms);
  final int ms;
}

class _ManualClear extends _ManualResult {}

/// Dialog to enter/override the actual time, or clear an existing override.
class _ManualTimeDialog extends StatefulWidget {
  const _ManualTimeDialog({required this.initialMs, required this.canClear});

  final int? initialMs;
  final bool canClear;

  @override
  State<_ManualTimeDialog> createState() => _ManualTimeDialogState();
}

class _ManualTimeDialogState extends State<_ManualTimeDialog> {
  int? _ms;

  @override
  void initState() {
    super.initState();
    _ms = widget.initialMs;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.manualTimeTitle),
      content: DurationInput(
        label: l10n.colActual,
        initialMs: widget.initialMs,
        onChanged: (ms) => _ms = ms,
      ),
      actions: [
        if (widget.canClear)
          TextButton(
            onPressed: () => Navigator.of(context).pop(_ManualClear()),
            child: Text(l10n.manualClear),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pop(_ms == null ? _ManualClear() : _ManualSet(_ms!)),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

/// Free-form note about one operation. Returns the text on save (empty clears
/// the note); returns null when cancelled.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String? initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.noteDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: l10n.noteHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

/// Prompts for a template name (defaults to the study's name).
class _TemplateNameDialog extends StatefulWidget {
  const _TemplateNameDialog({required this.initial});

  final String initial;

  @override
  State<_TemplateNameDialog> createState() => _TemplateNameDialogState();
}

class _TemplateNameDialogState extends State<_TemplateNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.saveAsTemplateAction),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.templateNameLabel),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
