import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Страница просмотра медиафайла
class MediaViewPage extends HookConsumerWidget {
  final String mediaId;
  final bool isImage;

  const MediaViewPage({
    super.key,
    required this.mediaId,
    required this.isImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В реальном приложении здесь будет использоваться ViewMediaUseCase
    // через провайдер состояния
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isImage ? l10n.imageViewTitle : l10n.videoViewTitle),
        actions: [
          // Кнопка шаринга
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // В реальном приложении будет использоваться ShareMediaUseCase
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.sharingNotImplemented),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          // Кнопка удаления
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // В реальном приложении здесь будет отображаться медиафайл
            Icon(
              isImage ? Icons.image : Icons.videocam,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isImage ? l10n.imagePreview : l10n.videoPreview,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $mediaId',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            if (!isImage)
              ElevatedButton.icon(
                onPressed: () {
                  // В реальном приложении здесь будет воспроизведение видео
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.playVideoNotImplemented),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.playVideo),
              ),
          ],
        ),
      ),
    );
  }

  /// Показывает диалог подтверждения удаления
  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteConfirmTitle),
            content: Text(l10n.deleteConfirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  // В реальном приложении здесь будет удаление файла
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Возврат на предыдущий экран

                  // Показываем уведомление
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.fileDeleted),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
