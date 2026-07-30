import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../common/confirm_dialog.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/timing_providers.dart';
import '../data/observation_repository.dart';

/// The passes of a Sampling Study — the screen a sampling study opens on
/// (DESIGN.md §11.1).
///
/// Deliberately *not* a switcher inside the timing workspace. The workspace is
/// the one screen with real use behind it, and keeping the set of passes out of
/// it means Phase 7 changes nothing about how a run is timed: no pass state, no
/// new keyboard semantics, and `lapActionFor` keeps its three outcomes.
///
/// The cost, named in §11.1 and accepted: a pass boundary is a back-navigation
/// and a tap, at the moment the analyst has least attention to spare.
class PassList extends ConsumerWidget {
  const PassList({
    super.key,
    required this.projectId,
    required this.studyId,
  });

  final String projectId;
  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final passesAsync = ref.watch(passesProvider(studyId));

    return passesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (passes) => Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: passes.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _PassRow(
                pass: passes[i],
                onReport: () => context.push(
                  '/projects/$projectId/studies/$studyId'
                  '/passes/${passes[i].id}/report',
                ),
                // A study always keeps at least one pass (§11.1), so the delete
                // action is offered only when there is something to fall back
                // on. The repository enforces this too — this only avoids
                // offering an action that would be refused.
                canDelete: passes.length > 1,
                onOpen: () => context.push(
                  '/projects/$projectId/studies/$studyId/passes/${passes[i].id}',
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.passTimedCount(
                      passes.where((p) => p.isComplete).length,
                      passes.length,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.passAdd),
                  onPressed: () => _addPass(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPass(BuildContext context, WidgetRef ref) async {
    final pass =
        await ref.read(observationRepositoryProvider).addPass(studyId);
    if (!context.mounted) return;
    // Straight into it: the analyst pressed "new pass" because the operator is
    // already starting the next cycle.
    context.push('/projects/$projectId/studies/$studyId/passes/${pass.id}');
  }
}

class _PassRow extends ConsumerWidget {
  const _PassRow({
    required this.pass,
    required this.canDelete,
    required this.onOpen,
    required this.onReport,
  });

  final PassSummary pass;
  final bool canDelete;
  final VoidCallback onOpen;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final when = DateFormat.MMMd(localeName)
        .add_Hm()
        .format(pass.observation.performedAt);

    return ListTile(
      onTap: onOpen,
      title: Row(
        children: [
          Text(l10n.passLabel(pass.number)),
          if (pass.isExcluded) ...[
            const SizedBox(width: 8),
            // A badge rather than strikethrough or a grey row: excluded is a
            // deliberate, reversible state, not a disabled one — the pass is
            // still openable and still has its own report (§11.3).
            Chip(
              label: Text(l10n.passExcludedBadge),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelStyle: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
      subtitle: Text(
        [
          when,
          if (pass.isEmpty)
            l10n.passNothingTimed
          else
            l10n.passTimedCount(pass.timedOperations, pass.totalOperations),
          // The reason travels with the row, not just into the database: the
          // analyst reading this in a month is usually the one who needs telling.
          if (pass.observation.exclusionReason != null)
            pass.observation.exclusionReason!,
        ].join(' · '),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => switch (value) {
          'report' => onReport(),
          'exclude' => _toggleExcluded(context, ref),
          'delete' => _delete(context, ref),
          _ => null,
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'report',
            // A pass is a time study, so it gets the full Time Study report —
            // Gantt included. That is how an analyst explains an outlier
            // (what ran alongside it, where it paused) BEFORE excluding it.
            enabled: !pass.isEmpty,
            child: Text(l10n.passReport),
          ),
          PopupMenuItem(
            value: 'exclude',
            child: Text(pass.isExcluded ? l10n.passInclude : l10n.passExclude),
          ),
          PopupMenuItem(
            value: 'delete',
            // Shown but disabled rather than hidden, so the reason can be given.
            // "Where did delete go?" is a worse experience than being told that
            // a pass with measurements is excluded instead (§11.3).
            enabled: canDelete && pass.isEmpty,
            child: Text(l10n.passDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleExcluded(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final repository = ref.read(observationRepositoryProvider);
    if (pass.isExcluded) {
      await repository.setExcluded(pass.id, excluded: false);
      return;
    }
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ExcludeDialog(passLabel: l10n.passLabel(pass.number)),
    );
    if (reason == null) return; // cancelled
    await repository.setExcluded(pass.id, excluded: true, reason: reason);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final label = l10n.passLabel(pass.number);
    final confirmed = await confirmDelete(
      context,
      title: l10n.passDeleteConfirmTitle(label),
      message: l10n.passDeleteConfirmMessage,
    );
    if (!confirmed) return;
    final deleted =
        await ref.read(observationRepositoryProvider).deleteIfEmpty(pass.id);
    if (deleted || !context.mounted) return;
    // The repository refused — it re-checks rather than trusting the menu, and
    // timing could have landed in this pass while the dialog was open.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.passDeleteBlocked)),
    );
  }
}

/// Asks why, and treats "no reason" as a valid answer.
///
/// The reason is optional on purpose: requiring one would make the honest
/// answer ("it was obviously wrong") into a hurdle, and an analyst blocked by a
/// required field types a full stop.
class _ExcludeDialog extends StatefulWidget {
  const _ExcludeDialog({required this.passLabel});

  final String passLabel;

  @override
  State<_ExcludeDialog> createState() => _ExcludeDialogState();
}

class _ExcludeDialogState extends State<_ExcludeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.passExcludeTitle(widget.passLabel)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.passExcludeMessage),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.passExcludeReasonHint,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.passExclude),
        ),
      ],
    );
  }
}
