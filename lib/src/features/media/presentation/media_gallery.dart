import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../common/confirm_dialog.dart';
import '../../../data/database/database.dart';
import '../../../data/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/media_providers.dart';

const _imageTypeGroup = XTypeGroup(
  label: 'images',
  extensions: ['jpg', 'jpeg', 'png', 'heic', 'heif', 'webp', 'gif', 'bmp'],
);

/// Opens the photo gallery for one owner (a study or, most often, an operation
/// instance). Full-screen so it works the same on desktop and phone.
Future<void> showMediaGallery(
  BuildContext context, {
  required MediaOwnerType ownerType,
  required String ownerId,
  required String title,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog.fullscreen(
      child: _MediaGalleryScreen(
        ownerType: ownerType,
        ownerId: ownerId,
        title: title,
      ),
    ),
  );
}

class _MediaGalleryScreen extends ConsumerWidget {
  const _MediaGalleryScreen({
    required this.ownerType,
    required this.ownerId,
    required this.title,
  });

  final MediaOwnerType ownerType;
  final String ownerId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items =
        ref.watch(mediaForOwnerProvider((ownerType, ownerId))).value ??
            const <MediaAttachment>[];
    final basePath = ref.watch(appMediaBasePathProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPhoto(ref),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.addPhoto),
      ),
      body: (items.isEmpty || basePath == null)
          ? Center(
              child: Text(
                items.isEmpty ? l10n.photosEmpty : '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final media = items[i];
                final path = _absolute(basePath, media);
                return InkWell(
                  onTap: () => _viewPhoto(context, ref, media, path),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(path), fit: BoxFit.cover),
                  ),
                );
              },
            ),
    );
  }

  String _absolute(String basePath, MediaAttachment media) =>
      p.joinAll([basePath, ...media.relativePath.split('/')]);

  Future<void> _addPhoto(WidgetRef ref) async {
    final file = await openFile(acceptedTypeGroups: [_imageTypeGroup]);
    if (file == null) return;
    await ref.read(mediaRepositoryProvider).addFile(
          ownerType: ownerType,
          ownerId: ownerId,
          kind: MediaKind.photo,
          sourcePath: file.path,
        );
  }

  Future<void> _viewPhoto(
    BuildContext context,
    WidgetRef ref,
    MediaAttachment media,
    String path,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => _PhotoViewer(media: media, path: path),
    );
  }
}

/// Enlarged photo with caption + delete.
class _PhotoViewer extends ConsumerWidget {
  const _PhotoViewer({required this.media, required this.path});

  final MediaAttachment media;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: InteractiveViewer(child: Image.file(File(path)))),
          if (media.caption != null && media.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(media.caption!,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.label_outline),
                label: Text(l10n.captionLabel),
                onPressed: () => _editCaption(context, ref),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.actionDelete),
                onPressed: () => _delete(context, ref),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.actionCancel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editCaption(BuildContext context, WidgetRef ref) async {
    final caption = await showDialog<String>(
      context: context,
      builder: (_) => _CaptionDialog(initial: media.caption),
    );
    if (caption == null) return;
    await ref.read(mediaRepositoryProvider).setCaption(media.id, caption);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDelete(
      context,
      title: l10n.deletePhotoTitle,
      message: l10n.deletePhotoMessage,
    );
    if (!confirmed) return;
    await ref.read(mediaRepositoryProvider).remove(media);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _CaptionDialog extends StatefulWidget {
  const _CaptionDialog({required this.initial});

  final String? initial;

  @override
  State<_CaptionDialog> createState() => _CaptionDialogState();
}

class _CaptionDialogState extends State<_CaptionDialog> {
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
      title: Text(l10n.captionLabel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
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
