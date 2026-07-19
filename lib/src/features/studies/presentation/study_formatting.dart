import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';

String studyTypeLabel(AppLocalizations l10n, StudyType type) => switch (type) {
      StudyType.timeStudy => l10n.studyTypeTime,
      StudyType.samplingStudy => l10n.studyTypeSampling,
    };
