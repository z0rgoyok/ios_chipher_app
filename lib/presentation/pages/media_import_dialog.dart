import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Диалог для выбора типа медиафайла при импорте
class MediaImportDialog extends StatelessWidget {
  const MediaImportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.mediaImportTitle),
      content: Text(l10n.mediaImportMessage),
      actions: [
        _buildImportOption(context, l10n.photoOption, Icons.photo, () {
          debugPrint('Выбран импорт фото');
          Navigator.of(context).pop('photo');
        }),
        _buildImportOption(context, l10n.videoOption, Icons.videocam, () {
          debugPrint('Выбран импорт видео');
          Navigator.of(context).pop('video');
        }),
        _buildImportOption(context, l10n.anyMediaOption, Icons.perm_media, () {
          debugPrint('Выбран импорт любого медиафайла');
          Navigator.of(context).pop('any');
        }),
        TextButton(
          onPressed: () {
            debugPrint('Импорт отменен пользователем');
            Navigator.of(context).pop();
          },
          child: Text(l10n.cancel),
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
  debugPrint('Открываем диалог выбора медиафайла');
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return const MediaImportDialog();
    },
  );
}
