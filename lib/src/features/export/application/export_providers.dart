import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/enums.dart';
import '../../media/data/media_repository.dart';
import '../../studies/application/timing_model.dart';
import 'export_delivery.dart';
import 'export_payload.dart';

final exportDeliveryProvider =
    Provider<ExportDelivery>((ref) => const ExportDelivery());

/// Resolves every photo attached to a run's operations into absolute file
/// paths, keyed by **StudyOperation id** so exporters can walk report rows.
///
/// Reads all operation-instance attachments in one query and groups them,
/// rather than one query per operation. Video is excluded — exports embed
/// photos only (DESIGN.md §3.8).
Future<Map<String, List<ExportPhoto>>> resolveOperationPhotos({
  required MediaRepository media,
  required Map<String, OperationTiming> timing,
}) async {
  final attachments =
      await media.watchByOwnerType(MediaOwnerType.operationInstance).first;

  final byInstance = <String, List<MediaAttachmentRef>>{};
  for (final a in attachments) {
    if (a.kind != MediaKind.photo) continue;
    (byInstance[a.ownerId] ??= []).add((
      absolutePath: await media.absolutePath(a),
      caption: a.caption,
    ));
  }

  final result = <String, List<ExportPhoto>>{};
  timing.forEach((studyOperationId, t) {
    final instanceId = t.instance?.id;
    if (instanceId == null) return;
    final photos = byInstance[instanceId];
    if (photos == null || photos.isEmpty) return;
    result[studyOperationId] = [
      for (final p in photos)
        ExportPhoto(absolutePath: p.absolutePath, caption: p.caption),
    ];
  });
  return result;
}

typedef MediaAttachmentRef = ({String absolutePath, String? caption});
