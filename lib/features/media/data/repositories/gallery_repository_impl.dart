import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';
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
      AppLogger.i('Запрашиваем разрешения для галереи');

      if (Platform.isIOS) {
        // Используем photo_manager для iOS, так как он лучше работает с iOS Photo Library
        final result = await PhotoManager.requestPermissionExtend();
        AppLogger.i('Результат запроса разрешений на iOS: $result');
        return Result.success(
          result.isAuth || result == PermissionState.limited,
        );
      } else if (Platform.isAndroid) {
        // На Android запрашиваем разрешения в зависимости от версии
        AppLogger.i('Запрашиваем разрешения для Android');
        bool hasPermission = false;

        if (await _isAndroid13OrAbove()) {
          // Android 13+ (SDK 33+)
          AppLogger.i(
            'Android 13+: Запрашиваем READ_MEDIA_IMAGES и READ_MEDIA_VIDEO',
          );
          final photos = await Permission.photos.request();
          final videos = await Permission.videos.request();
          hasPermission = photos.isGranted && videos.isGranted;
        } else {
          // Android 12 и ниже
          AppLogger.i('Android 12-: Запрашиваем READ_EXTERNAL_STORAGE');
          final storage = await Permission.storage.request();
          hasPermission = storage.isGranted;
        }

        AppLogger.i('Результат запроса разрешений на Android: $hasPermission');
        return Result.success(hasPermission);
      }

      return Result.success(false);
    } catch (e, stack) {
      AppLogger.e('Ошибка при запросе разрешений для галереи', e, stack);
      return Result.failure(
        PermissionFailure(
          message:
              'Не удалось запросить разрешения для доступа к галерее: ${e.toString()}',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> checkPermissions() async {
    try {
      AppLogger.i('Проверяем разрешения для галереи');

      if (Platform.isIOS) {
        // Используем photo_manager для iOS
        final result = await PhotoManager.requestPermissionExtend();
        AppLogger.i('Статус разрешений на iOS: $result');
        return Result.success(
          result.isAuth || result == PermissionState.limited,
        );
      } else if (Platform.isAndroid) {
        // На Android проверяем разрешения в зависимости от версии
        bool hasPermission = false;

        if (await _isAndroid13OrAbove()) {
          // Android 13+ (SDK 33+)
          AppLogger.i(
            'Android 13+: Проверяем READ_MEDIA_IMAGES и READ_MEDIA_VIDEO',
          );
          final photos = await Permission.photos.status;
          final videos = await Permission.videos.status;
          hasPermission = photos.isGranted && videos.isGranted;
        } else {
          // Android 12 и ниже
          AppLogger.i('Android 12-: Проверяем READ_EXTERNAL_STORAGE');
          final storage = await Permission.storage.status;
          hasPermission = storage.isGranted;
        }

        AppLogger.i('Статус разрешений на Android: $hasPermission');
        return Result.success(hasPermission);
      }

      return Result.success(false);
    } catch (e, stack) {
      AppLogger.e('Ошибка при проверке разрешений для галереи', e, stack);
      return Result.failure(
        PermissionFailure(
          message:
              'Не удалось проверить разрешения для доступа к галерее: ${e.toString()}',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Проверяет, является ли версия Android 13 или выше (SDK >= 33)
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      return sdkInt >= 33; // Android 13 = API 33
    }
    return false;
  }

  /// Получает версию SDK Android
  Future<int> _getAndroidSdkVersion() async {
    try {
      return Platform.operatingSystemVersion
              .replaceAll(RegExp(r'[^\d.]'), '')
              .split('.')
              .first
              .parseInt ??
          0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Result<String?>> pickImage() async {
    try {
      AppLogger.i('Выбираем изображение из галереи');

      // Проверяем разрешения
      AppLogger.i('Проверяем разрешения перед выбором изображения');
      final permissionResult = await checkPermissions();

      if (permissionResult.isFailure) {
        final errorMsg = permissionResult.failure.message;
        AppLogger.w('Ошибка при проверке разрешений для галереи: $errorMsg');
        return Result.failure(permissionResult.failure);
      }

      if (!permissionResult.value) {
        AppLogger.i('Нет разрешений. Запрашиваем разрешения...');
        final requestResult = await requestPermissions();

        if (requestResult.isFailure) {
          final errorMsg = requestResult.failure.message;
          AppLogger.e('Ошибка при запросе разрешений: $errorMsg');
          return Result.failure(
            PermissionFailure(
              message: 'Ошибка при запросе разрешений: $errorMsg',
            ),
          );
        }

        if (!requestResult.value) {
          AppLogger.w('Пользователь отказал в доступе к галерее');
          return Result.failure(
            PermissionFailure(
              message:
                  'Доступ к галерее запрещен. Пожалуйста, предоставьте доступ в настройках устройства.',
            ),
          );
        }
      }

      AppLogger.i('Открываем диалог выбора изображения');
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        AppLogger.i('Пользователь отменил выбор изображения');
        return Result.failure(
          MediaGalleryFailure(
            message: 'Выбор изображения отменен пользователем',
          ),
        );
      }

      AppLogger.i('Выбранное изображение: ${pickedFile.path}');
      return Result.success(pickedFile.path);
    } catch (e, stack) {
      final errorMsg =
          'Ошибка при выборе изображения из галереи: ${e.toString()}';
      AppLogger.e(errorMsg, e, stack);
      return Result.failure(
        MediaGalleryFailure(message: errorMsg, stackTrace: stack),
      );
    }
  }

  @override
  Future<Result<String?>> pickVideo() async {
    try {
      AppLogger.i('Выбираем видео из галереи');

      // Проверяем разрешения
      AppLogger.i('Проверяем разрешения перед выбором видео');
      final permissionResult = await checkPermissions();

      if (permissionResult.isFailure) {
        final errorMsg = permissionResult.failure.message;
        AppLogger.w('Ошибка при проверке разрешений для галереи: $errorMsg');
        return Result.failure(permissionResult.failure);
      }

      if (!permissionResult.value) {
        AppLogger.i('Нет разрешений. Запрашиваем разрешения...');
        final requestResult = await requestPermissions();

        if (requestResult.isFailure) {
          final errorMsg = requestResult.failure.message;
          AppLogger.e('Ошибка при запросе разрешений: $errorMsg');
          return Result.failure(
            PermissionFailure(
              message: 'Ошибка при запросе разрешений: $errorMsg',
            ),
          );
        }

        if (!requestResult.value) {
          AppLogger.w('Пользователь отказал в доступе к галерее');
          return Result.failure(
            PermissionFailure(
              message:
                  'Доступ к галерее запрещен. Пожалуйста, предоставьте доступ в настройках устройства.',
            ),
          );
        }
      }

      AppLogger.i('Открываем диалог выбора видео');
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        AppLogger.i('Пользователь отменил выбор видео');
        return Result.failure(
          MediaGalleryFailure(message: 'Выбор видео отменен пользователем'),
        );
      }

      AppLogger.i('Выбранное видео: ${pickedFile.path}');
      return Result.success(pickedFile.path);
    } catch (e, stack) {
      final errorMsg = 'Ошибка при выборе видео из галереи: ${e.toString()}';
      AppLogger.e(errorMsg, e, stack);
      return Result.failure(
        MediaGalleryFailure(message: errorMsg, stackTrace: stack),
      );
    }
  }

  @override
  Future<Result<String?>> pickMediaFile() async {
    try {
      AppLogger.i('Выбираем медиафайл');

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
          message: 'Не удалось выбрать медиафайл из галереи: ${e.toString()}',
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

extension _IntParsing on String {
  int? get parseInt {
    try {
      return int.parse(this);
    } catch (_) {
      return null;
    }
  }
}
