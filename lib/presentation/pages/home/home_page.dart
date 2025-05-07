import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:ios_chipher_app/presentation/pages/home/home_notifier.dart';
import 'package:ios_chipher_app/presentation/pages/home/media_import_dialog.dart';
import 'package:ios_chipher_app/presentation/pages/media/media_view_page.dart';
import 'package:ios_chipher_app/presentation/pages/settings/settings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Главная страница приложения
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
          SnackBar(
            content: Text(l10n.importingMedia),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      try {
        AppLogger.i('Начинаем импорт медиафайла типа: $mediaType');

        if (mediaType == 'photo') {
          success = await ref.read(homeNotifierProvider.notifier).importImage();
          message = l10n.photoImportSuccess;
          AppLogger.i('Результат импорта фото: $success');
        } else if (mediaType == 'video') {
          success = await ref.read(homeNotifierProvider.notifier).importVideo();
          message = l10n.videoImportSuccess;
          AppLogger.i('Результат импорта видео: $success');
        } else {
          success = await ref.read(homeNotifierProvider.notifier).importMedia();
          message = l10n.mediaImportSuccess;
          AppLogger.i('Результат импорта медиа: $success');
        }
      } catch (e, stackTrace) {
        success = false;
        message = '${l10n.importError}: ${e.toString()}';
        AppLogger.e('Исключение при импорте медиафайла', e, stackTrace);
      }

      // Показываем сообщение о результате
      if (context.mounted) {
        String errorMsg = mediaState.error ?? l10n.unknownImportError;
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
                      label: l10n.errorDetails,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(l10n.errorDetails),
                                content: Text(errorMsg),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.ok),
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
        title: Text(l10n.appName),
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
        tooltip: l10n.addMediaTooltip,
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
    final l10n = AppLocalizations.of(context)!;

    // Показываем индикатор загрузки
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Показываем сообщение, если нет медиафайлов
    if (state.mediaFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(l10n.noProtectedFiles, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              l10n.pressToAddMedia,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
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
                  color: Colors.grey[700],
                ),

                // Индикатор типа файла
                if (!item.isImage)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "0:00", // Заглушка для демонстрации
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
