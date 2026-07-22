import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:file_selector/file_selector.dart' as fs;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// How an exported artifact leaves the app, per platform (DESIGN.md §5):
/// **iOS → native share sheet**, **Windows → save-file dialog**. Isolated here
/// so the PDF/XLSX builders stay pure and platform-free.
enum ExportFormat {
  pdf('pdf', 'application/pdf'),
  xlsx('xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

  const ExportFormat(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}

/// The outcome of a delivery, so callers can tell "saved" from "user backed
/// out" without inspecting platform details.
enum ExportResult { delivered, cancelled }

class ExportDelivery {
  const ExportDelivery();

  /// Writes [bytes] out via the platform's idiomatic mechanism.
  ///
  /// [sharePositionOrigin] is required by iPadOS to anchor the share popover;
  /// pass the source widget's global rect. Ignored elsewhere.
  Future<ExportResult> deliver({
    required Uint8List bytes,
    required String fileName,
    required ExportFormat format,
    Rect? sharePositionOrigin,
  }) async {
    if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
      // The share sheet needs a real file; the temp copy is the OS's to reap.
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: format.mimeType)],
          fileNameOverrides: [fileName],
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
      return result.status == ShareResultStatus.dismissed
          ? ExportResult.cancelled
          : ExportResult.delivered;
    }

    final location = await fs.getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        fs.XTypeGroup(
          label: format.extension.toUpperCase(),
          extensions: [format.extension],
        ),
      ],
    );
    if (location == null) return ExportResult.cancelled;

    await File(location.path).writeAsBytes(bytes, flush: true);
    return ExportResult.delivered;
  }
}
