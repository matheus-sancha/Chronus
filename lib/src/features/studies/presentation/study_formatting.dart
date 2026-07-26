import 'package:flutter/material.dart';

import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/timing_model.dart';

String studyTypeLabel(AppLocalizations l10n, StudyType type) => switch (type) {
      StudyType.timeStudy => l10n.studyTypeTime,
      StudyType.samplingStudy => l10n.studyTypeSampling,
    };

/// Colour for an operation's time against its reference standard: amber
/// approaching, red over, default on track or not applicable.
///
/// Fixed hues, matching `categoryColor` — the meaning has to read the same on
/// any floor and under any theme. Colour is never the only carrier: the figure
/// itself and the per-row reference standard are always on screen beside it.
Color? paceColor(OperationPace? pace) => switch (pace) {
      OperationPace.approaching => const Color(0xFFF59E0B),
      OperationPace.over => const Color(0xFFDC2626),
      OperationPace.onTrack || null => null,
    };
