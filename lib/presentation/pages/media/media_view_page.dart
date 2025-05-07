import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(isImage ? 'Просмотр изображения' : 'Просмотр видео'),
        actions: [
          // Кнопка шаринга
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // В реальном приложении будет использоваться ShareMediaUseCase
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция шаринга будет реализована позже'),
                  duration: Duration(seconds: 2),
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
              isImage
                  ? 'Здесь будет отображаться изображение'
                  : 'Здесь будет отображаться видео',
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
                    const SnackBar(
                      content: Text(
                        'Функция воспроизведения будет реализована позже',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Воспроизвести'),
              ),
          ],
        ),
      ),
    );
  }

  /// Показывает диалог подтверждения удаления
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text(
              'Вы уверены, что хотите удалить этот файл? Это действие нельзя отменить.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  // В реальном приложении здесь будет удаление файла
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Возврат на предыдущий экран

                  // Показываем уведомление
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Файл удален'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
