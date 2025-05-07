import 'package:flutter/material.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';

/// Диалог для выбора типа медиафайла при импорте
class MediaImportDialog extends StatelessWidget {
  const MediaImportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Импорт медиафайла'),
      content: const Text('Выберите тип файла, который хотите импортировать'),
      actions: [
        _buildImportOption(context, 'Фото', Icons.photo, () {
          AppLogger.i('Выбран импорт фото');
          Navigator.of(context).pop('photo');
        }),
        _buildImportOption(context, 'Видео', Icons.videocam, () {
          AppLogger.i('Выбран импорт видео');
          Navigator.of(context).pop('video');
        }),
        _buildImportOption(context, 'Любой медиафайл', Icons.perm_media, () {
          AppLogger.i('Выбран импорт любого медиафайла');
          Navigator.of(context).pop('any');
        }),
        TextButton(
          onPressed: () {
            AppLogger.i('Импорт отменен пользователем');
            Navigator.of(context).pop();
          },
          child: const Text('Отмена'),
        ),
      ],
    );
  }

  /// Создает кнопку для выбора типа медиафайла
  Widget _buildImportOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      dense: true,
    );
  }
}

/// Показывает диалог выбора типа медиафайла
///
/// Возвращает выбранный тип:
/// - 'photo' - фото
/// - 'video' - видео
/// - 'any' - любой медиафайл
/// - null - если диалог был закрыт
Future<String?> showMediaImportDialog(BuildContext context) async {
  AppLogger.i('Открываем диалог выбора медиафайла');
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return const MediaImportDialog();
    },
  );
}
