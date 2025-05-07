import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:ios_chipher_app/core/errors/failures.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/gallery_repository.dart';

/// Реализация репозитория для работы с галереей устройства
class GalleryRepositoryImpl implements GalleryRepository {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Future<Result<bool>> requestPermissions() async {
    try {
      // На iOS запрашиваем разрешения для доступа к фотогалерее
      final status = await Permission.photos.request();
      return Result.success(status.isGranted);
    } catch (e, stack) {
      AppLogger.e('Ошибка при запросе разрешений для галереи', e, stack);
      return Result.failure(
        PermissionFailure(
          message: 'Не удалось запросить разрешения для доступа к галерее',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> checkPermissions() async {
    try {
      final status = await Permission.photos.status;
      return Result.success(status.isGranted);
    } catch (e, stack) {
      AppLogger.e('Ошибка при проверке разрешений для галереи', e, stack);
      return Result.failure(
        PermissionFailure(
          message: 'Не удалось проверить разрешения для доступа к галерее',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String?>> pickImage() async {
    try {
      // Проверяем разрешения
      final permissionResult = await checkPermissions();
      if (permissionResult.isFailure) {
        return Result.failure(permissionResult.failure);
      }

      if (!permissionResult.value) {
        final requestResult = await requestPermissions();
        if (requestResult.isFailure || !requestResult.value) {
          return Result.failure(
            PermissionFailure(message: 'Нет разрешения на доступ к галерее'),
          );
        }
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      return Result.success(pickedFile?.path);
    } catch (e, stack) {
      AppLogger.e('Ошибка при выборе изображения из галереи', e, stack);
      return Result.failure(
        MediaGalleryFailure(
          message: 'Не удалось выбрать изображение из галереи',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String?>> pickVideo() async {
    try {
      // Проверяем разрешения
      final permissionResult = await checkPermissions();
      if (permissionResult.isFailure) {
        return Result.failure(permissionResult.failure);
      }

      if (!permissionResult.value) {
        final requestResult = await requestPermissions();
        if (requestResult.isFailure || !requestResult.value) {
          return Result.failure(
            PermissionFailure(message: 'Нет разрешения на доступ к галерее'),
          );
        }
      }

      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      return Result.success(pickedFile?.path);
    } catch (e, stack) {
      AppLogger.e('Ошибка при выборе видео из галереи', e, stack);
      return Result.failure(
        MediaGalleryFailure(
          message: 'Не удалось выбрать видео из галереи',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String?>> pickMediaFile() async {
    try {
      // Для простоты предлагаем пользователю выбрать между изображением и видео
      // В реальном приложении можно использовать file_picker для более гибкого выбора

      final pickImageResult = await pickImage();
      if (pickImageResult.isFailure) {
        return Result.failure(pickImageResult.failure);
      }

      if (pickImageResult.value != null) {
        return pickImageResult;
      }

      // Если изображение не выбрано, предлагаем выбрать видео
      return await pickVideo();
    } catch (e, stack) {
      AppLogger.e('Ошибка при выборе медиафайла из галереи', e, stack);
      return Result.failure(
        MediaGalleryFailure(
          message: 'Не удалось выбрать медиафайл из галереи',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> deleteFromGallery(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return Result.success(true);
      }
      return Result.success(false);
    } catch (e, stack) {
      AppLogger.e('Ошибка при удалении файла из галереи', e, stack);
      return Result.failure(
        MediaGalleryFailure(
          message: 'Не удалось удалить файл из галереи',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String>> getMediaType(String filePath) async {
    try {
      final extension = p.extension(filePath).toLowerCase();

      // Определяем тип медиафайла по расширению
      if ([
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.heic',
      ].contains(extension)) {
        return Result.success('image');
      } else if ([
        '.mp4',
        '.mov',
        '.avi',
        '.mkv',
        '.webm',
        '.m4v',
      ].contains(extension)) {
        return Result.success('video');
      } else {
        return Result.success('unknown');
      }
    } catch (e, stack) {
      AppLogger.e('Ошибка при определении типа медиафайла', e, stack);
      return Result.failure(
        MediaGalleryFailure(
          message: 'Не удалось определить тип медиафайла',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getMediaMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Result.failure(
          MediaGalleryFailure(message: 'Файл не существует: $filePath'),
        );
      }

      final type = await getMediaType(filePath);
      if (type.isFailure) {
        return Result.failure(type.failure);
      }

      final Map<String, dynamic> metadata = {
        'path': filePath,
        'name': p.basename(filePath),
        'extension': p.extension(filePath),
        'size': await file.length(),
        'type': type.value,
        'lastModified': (await file.lastModified()).millisecondsSinceEpoch,
      };

      return Result.success(metadata);
    } catch (e, stack) {
      AppLogger.e('Ошибка при получении метаданных медиафайла', e, stack);
      return Result.failure(
        MediaGalleryFailure(
          message: 'Не удалось получить метаданные медиафайла',
          stackTrace: stack,
        ),
      );
    }
  }
}
