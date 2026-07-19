import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
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
  final _allowance = TextEditingController();
  final _partProduct = TextEditingController();
  final _processOperation = TextEditingController();
  final _machine = TextEditingController();
  final _lineCell = TextEditingController();
  final _operator = TextEditingController();
  final _shift = TextEditingController();
  final _workOrder = TextEditingController();
  final _notes = TextEditingController();

  StudyType _type = StudyType.timeStudy;
  DateTime _performedAt = DateTime.now();
  String? _processType;
  bool _initialized = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _analyst,
      _allowance,
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
    _allowance.text = _formatAllowance(study.allowancePercent);
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
    _initialized = true;
  }

  static String _formatAllowance(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toString();

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
    final allowance = double.tryParse(_allowance.text.trim().replaceAll(',', '.')) ?? 0.0;
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
      allowancePercent: Value(allowance),
      notes: Value(_nullIfBlank(_notes.text)),
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
                _text(
                  _allowance,
                  l10n.studyFieldAllowance,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
