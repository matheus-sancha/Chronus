import 'package:flutter/material.dart';

import '../../../app/build_info.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/diagnostics.dart';

/// Lets a user write down what got in the way, from wherever they are.
///
/// There is no server to send it to and none is wanted (DESIGN.md §2), so the
/// note is appended to `feedback.txt` and rides along with "Save diagnostics" —
/// one file to ask for, and nothing lost if they never get around to messaging
/// anyone that day.
///
/// Reachable from Settings *and* from the study workspace, because friction is
/// felt during a run and forgotten by the time anyone opens Settings.
Future<void> showFeedbackDialog(BuildContext context) async {
  // Resolved before the dialog, so nothing reads the context across an async gap
  // (same pattern as BackupSection).
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final text = await showDialog<String>(
    context: context,
    builder: (context) => const _FeedbackDialog(),
  );
  if (text == null || text.trim().isEmpty) return;

  await Diag.log?.addFeedback(text, buildLabel: kBuildLabel);
  messenger.showSnackBar(SnackBar(content: Text(l10n.feedbackSaved)));
}

class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog();

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
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
      title: Text(l10n.feedbackAction),
      content: TextField(
        controller: _controller,
        autofocus: true,
        // Multi-line and unconstrained: a complaint worth having is rarely one
        // line, and Enter should break the line rather than submit.
        maxLines: 6,
        minLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.feedbackHint,
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
