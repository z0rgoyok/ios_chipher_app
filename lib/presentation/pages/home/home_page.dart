import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:ios_chipher_app/presentation/pages/home/home_notifier.dart';
import 'package:ios_chipher_app/presentation/pages/home/media_import_dialog.dart';
import 'package:ios_chipher_app/presentation/pages/media/media_view_page.dart';
import 'package:ios_chipher_app/presentation/pages/settings/settings_page.dart';

/// Главная страница приложения
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaState = ref.watch(homeNotifierProvider);

    // Используем useEffect для загрузки данных только при первом построении
    useEffect(
      () {
        AppLogger.i('HomePage: Первичная инициализация');
        // Вызываем загрузку медиафайлов только один раз при создании виджета
        Future.microtask(() {
          ref.read(homeNotifierProvider.notifier).loadMediaFiles();
        });

        // Возвращаем функцию очистки (если нужно)
        return null;
      },
      const [],
    ); // Пустой массив означает, что эффект выполнится только один раз

    // Метод для добавления медиа
    Future<void> handleAddMedia() async {
      final mediaType = await showMediaImportDialog(context);
      if (mediaType == null) return;

      bool success = false;
      String message = '';

      // Показываем индикатор загрузки
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Импорт медиафайла...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      try {
        AppLogger.i('Начинаем импорт медиафайла типа: $mediaType');

        if (mediaType == 'photo') {
          success = await ref.read(homeNotifierProvider.notifier).importImage();
          message = 'Фото успешно импортировано и зашифровано';
          AppLogger.i('Результат импорта фото: $success');
        } else if (mediaType == 'video') {
          success = await ref.read(homeNotifierProvider.notifier).importVideo();
          message = 'Видео успешно импортировано и зашифровано';
          AppLogger.i('Результат импорта видео: $success');
        } else {
          success = await ref.read(homeNotifierProvider.notifier).importMedia();
          message = 'Медиафайл успешно импортирован и зашифрован';
          AppLogger.i('Результат импорта медиа: $success');
        }
      } catch (e, stackTrace) {
        success = false;
        message = 'Ошибка при импорте: ${e.toString()}';
        AppLogger.e('Исключение при импорте медиафайла', e, stackTrace);
      }

      // Показываем сообщение о результате
      if (context.mounted) {
        String errorMsg = mediaState.error ?? 'Неизвестная ошибка импорта';
        AppLogger.w('Сообщение об ошибке: $errorMsg');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? message : errorMsg),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
            action:
                success
                    ? null
                    : SnackBarAction(
                      label: 'Детали',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Детали ошибки'),
                                content: Text(errorMsg),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
          ),
        );
      }
    }

    // Метод для обработки нажатия на элемент
    void handleItemTap(MediaFile item) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  MediaViewPage(mediaId: item.id, isImage: item.isImage),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Media Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, mediaState, handleItemTap),
      floatingActionButton: FloatingActionButton(
        onPressed: handleAddMedia,
        tooltip: 'Добавить медиафайл',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Строит основное содержимое страницы
  Widget _buildBody(
    BuildContext context,
    MediaState state,
    void Function(MediaFile) onItemTap,
  ) {
    // Показываем индикатор загрузки
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Показываем сообщение, если нет медиафайлов
    if (state.mediaFiles.isEmpty) {
      return const Center(
        child: Text(
          'Нет файлов. Нажмите "+" чтобы добавить файлы',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Показываем сетку с медиафайлами
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.mediaFiles.length,
      itemBuilder: (context, index) {
        final item = state.mediaFiles[index];
        return GestureDetector(
          onTap: () => onItemTap(item),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // В реальном приложении здесь будет отображаться миниатюра
                Icon(
                  item.isImage ? Icons.image : Icons.video_file,
                  size: 40,
                  color: Colors.grey[600],
                ),

                // Индикатор типа файла
                if (!item.isImage)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
