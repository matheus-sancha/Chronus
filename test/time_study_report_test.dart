import 'package:chronus/src/data/database/database.dart';
import 'package:chronus/src/data/database/enums.dart';
import 'package:chronus/src/features/analysis/application/time_study_report.dart';
import 'package:chronus/src/features/studies/application/timing_model.dart';
import 'package:flutter_test/flutter_test.dart';

StudyOperation _op(String id, OperationCategory cat, double order,
        {String? subtypeId, int? reference}) =>
    StudyOperation(
      id: id,
      studyId: 's',
      catalogOperationId: null,
      orderIndex: order,
      name: id,
      category: cat,
      subtypeId: subtypeId,
      referenceStandardMs: reference,
      isUnplanned: false,
      createdAt: DateTime(2026),
    );

OperationInstance _inst(String opId) => OperationInstance(
      id: 'i$opId',
      observationId: 'o',
      studyOperationId: opId,
      manualActualMs: null,
      completedAt: DateTime(2026),
      notes: null,
      createdAt: DateTime(2026),
    );

OperationTimeSegment _seg(String opId, int start, int end) =>
    OperationTimeSegment(
      id: 'g$opId',
      operationInstanceId: 'i$opId',
      startAtMs: start,
      endAtMs: end,
      createdAt: DateTime(2026),
    );

void main() {
  test('report computes efficiency, roll-ups, timeline and elapsed', () {
    final subtype = OperationSubtype(
      id: 'w',
      category: OperationCategory.unproductive,
      name: 'Waiting',
      isBuiltIn: true,
      createdAt: DateTime(2026),
    );

    // P (productive) 0..10000, reference 8000 → efficiency 80%.
    // W (waste) 5000..9000 (inside P), no reference.
    final segP = _seg('P', 0, 10000);
    final segW = _seg('W', 5000, 9000);

    final report = buildTimeStudyReport(
      operations: [
        _op('P', OperationCategory.productive, 1, reference: 8000),
        _op('W', OperationCategory.unproductive, 2, subtypeId: 'w'),
      ],
      timing: {
        'P': OperationTiming(instance: _inst('P'), segments: [segP]),
        'W': OperationTiming(instance: _inst('W'), segments: [segW]),
      },
      subtypeById: {'w': subtype},
      segments: [segP, segW],
    );

    // Work content = 10000 + 4000; elapsed = span 0..10000.
    expect(report.totalWorkContentMs, 14000);
    expect(report.totalElapsedMs, 10000);
    expect(report.valueAddedRatio, closeTo(10000 / 14000, 1e-9));

    // Efficiency: aggregate over ops with a reference = 8000 / 10000 = 0.8.
    expect(report.efficiency, closeTo(0.8, 1e-9));
    final pRow = report.rows.firstWhere((r) => r.operation.id == 'P');
    final wRow = report.rows.firstWhere((r) => r.operation.id == 'W');
    expect(pRow.efficiency, closeTo(0.8, 1e-9)); // 8000 / 10000
    expect(wRow.efficiency, isNull); // no reference

    // Timeline ordered by first start: P (start 0) before W (start 5000).
    expect(report.timeline.map((t) => t.operation.id), ['P', 'W']);

    // Pareto has the single waste subtype.
    expect(report.wastePareto.single.subtype?.name, 'Waiting');
    expect(report.wastePareto.single.ms, 4000);
  });
}
