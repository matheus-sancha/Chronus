import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../analysis/application/sampling_statistics.dart';
import '../application/studies_providers.dart';

/// Full study header-metadata form. Loads the study, edits every v1 field, and
/// writes the whole header back on save.
class StudyEditScreen extends ConsumerStatefulWidget {
  const StudyEditScreen({
    super.key,
    required this.projectId,
    required this.studyId,
  });

  final String projectId;
  final String studyId;

  @override
  ConsumerState<StudyEditScreen> createState() => _StudyEditScreenState();
}

class _StudyEditScreenState extends ConsumerState<StudyEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _analyst = TextEditingController();
  final _partProduct = TextEditingController();
  final _processOperation = TextEditingController();
  final _machine = TextEditingController();
  final _lineCell = TextEditingController();
  final _operator = TextEditingController();
  final _shift = TextEditingController();
  final _workOrder = TextEditingController();
  final _notes = TextEditingController();

  StudyType _type = StudyType.timeStudy;

  /// Sample-size criteria, per study rather than a global preference (§11.5):
  /// a global one would silently re-judge every past study when changed.
  double _confidenceLevel = 0.95;
  double _relativePrecision = 0.05;
  DateTime _performedAt = DateTime.now();
  String? _processType;
  bool _initialized = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _analyst,
      _partProduct,
      _processOperation,
      _machine,
      _lineCell,
      _operator,
      _shift,
      _workOrder,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(Study study) {
    _name.text = study.name;
    _analyst.text = study.analyst ?? '';
    _partProduct.text = study.partProduct ?? '';
    _processOperation.text = study.processOperation ?? '';
    _machine.text = study.machineWorkstation ?? '';
    _lineCell.text = study.lineCell ?? '';
    _operator.text = study.operatorName ?? '';
    _shift.text = study.shift ?? '';
    _workOrder.text = study.workOrderNumber ?? '';
    _notes.text = study.notes ?? '';
    _type = study.type;
    _performedAt = study.performedAt;
    _processType = study.processType;
    _confidenceLevel = study.confidenceLevel;
    _relativePrecision = study.relativePrecision;
    _initialized = true;
  }

  String? _nullIfBlank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _performedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _performedAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _performedAt.hour,
          _performedAt.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final changes = StudiesCompanion(
      name: Value(_name.text.trim()),
      type: Value(_type),
      performedAt: Value(_performedAt),
      analyst: Value(_nullIfBlank(_analyst.text)),
      partProduct: Value(_nullIfBlank(_partProduct.text)),
      processOperation: Value(_nullIfBlank(_processOperation.text)),
      machineWorkstation: Value(_nullIfBlank(_machine.text)),
      lineCell: Value(_nullIfBlank(_lineCell.text)),
      operatorName: Value(_nullIfBlank(_operator.text)),
      shift: Value(_nullIfBlank(_shift.text)),
      workOrderNumber: Value(_nullIfBlank(_workOrder.text)),
      processType: Value(_processType),
      notes: Value(_nullIfBlank(_notes.text)),
      confidenceLevel: Value(_confidenceLevel),
      relativePrecision: Value(_relativePrecision),
    );
    await ref.read(studyRepositoryProvider).update(widget.studyId, changes);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final studyAsync = ref.watch(studyByIdProvider(widget.studyId));
    final optionsAsync = ref.watch(processTypeOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.studyEditTitle),
        actions: [
          TextButton(
            onPressed: _initialized ? _save : null,
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: studyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (study) {
          if (!_initialized) _hydrate(study);
          final dateFmt = MaterialLocalizations.of(context);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.studyNameLabel),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '' : null,
                ),
                const SizedBox(height: 16),
                SegmentedButton<StudyType>(
                  segments: [
                    ButtonSegment(
                      value: StudyType.timeStudy,
                      label: Text(l10n.studyTypeTime),
                    ),
                    ButtonSegment(
                      value: StudyType.samplingStudy,
                      label: Text(l10n.studyTypeSampling),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                // Only a Sampling Study has a sample size to be adequate for;
                // the columns exist on every study and are simply unused by a
                // Time Study (§11.5).
                if (_type == StudyType.samplingStudy) ...[
                  const SizedBox(height: 16),
                  Text(l10n.studyCriteriaSection,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<double>(
                    initialValue: _confidenceLevel,
                    decoration:
                        InputDecoration(labelText: l10n.studyConfidenceLevel),
                    // The three levels the t table holds. A free-text field
                    // would allow a value with no tabulated t behind it.
                    items: [
                      for (final level in supportedConfidenceLevels)
                        DropdownMenuItem(
                          value: level,
                          child: Text('${(level * 100).round()}%'),
                        ),
                    ],
                    onChanged: (v) =>
                        setState(() => _confidenceLevel = v ?? 0.95),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<double>(
                    initialValue: _relativePrecision,
                    decoration:
                        InputDecoration(labelText: l10n.studyRelativePrecision),
                    items: [
                      for (final precision in const [0.01, 0.02, 0.05, 0.10])
                        DropdownMenuItem(
                          value: precision,
                          child: Text('± ${(precision * 100).round()}%'),
                        ),
                    ],
                    onChanged: (v) =>
                        setState(() => _relativePrecision = v ?? 0.05),
                  ),
                ],
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(l10n.studyFieldDate),
                  subtitle: Text(dateFmt.formatFullDate(_performedAt)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: _pickDate,
                ),
                _text(_analyst, l10n.studyFieldAnalyst),
                optionsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (options) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DropdownButtonFormField<String?>(
                      initialValue: _processType,
                      decoration: InputDecoration(
                        labelText: l10n.studyFieldProcessType,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.processTypeNone),
                        ),
                        for (final o in options)
                          DropdownMenuItem(
                            value: o.name,
                            child: Text(o.name),
                          ),
                      ],
                      onChanged: (v) => setState(() => _processType = v),
                    ),
                  ),
                ),
                const Divider(height: 32),
                _text(_partProduct, l10n.studyFieldPartProduct),
                _text(_processOperation, l10n.studyFieldProcessOperation),
                _text(_machine, l10n.studyFieldMachine),
                _text(_lineCell, l10n.studyFieldLineCell),
                _text(_operator, l10n.studyFieldOperator),
                _text(_shift, l10n.studyFieldShift),
                _text(_workOrder, l10n.studyFieldWorkOrder),
                _text(_notes, l10n.studyFieldNotes, maxLines: 3),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _text(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helpTooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: helpTooltip == null
              ? null
              : Tooltip(
                  message: helpTooltip,
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 6),
                  child: const Icon(Icons.info_outline),
                ),
        ),
      ),
    );
  }
}
