import 'package:ios_chipher_app/core/errors/failures.dart';
import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/gallery_repository.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/media_repository.dart';

/// Параметры для импорта медиафайла
class ImportMediaParams {
  /// Путь к файлу (если известен)
  final String? filePath;

  /// Тип медиа для выбора (если filePath не указан)
  final MediaType? mediaType;

  /// Флаг, указывающий, нужно ли удалять оригинал
  final bool removeOriginal;

  const ImportMediaParams({
    this.filePath,
    this.mediaType,
    this.removeOriginal = true,
  });
}

/// Use case для импорта медиафайла
class ImportMediaUseCase {
  final MediaRepository _mediaRepository;
  final GalleryRepository _galleryRepository;

  ImportMediaUseCase(this._mediaRepository, this._galleryRepository);

  /// Выполняет импорт медиафайла
  ///
  /// Если [params.filePath] не указан, открывает диалог выбора файла согласно [params.mediaType]
  Future<Result<MediaFile>> call(ImportMediaParams params) async {
    // Проверяем разрешения
    final permissionsResult = await _galleryRepository.checkPermissions();
    if (permissionsResult.isFailure) {
      // Пытаемся запросить разрешения
      final requestResult = await _galleryRepository.requestPermissions();
      if (requestResult.isFailure) {
        return Result.failure(requestResult.failure);
      }
      if (!requestResult.value) {
        return Result.failure(permissionsResult.failure);
      }
    }

    // Получаем путь к файлу
    String? filePath = params.filePath;
    if (filePath == null) {
      final pickResult = await _pickMediaFile(params.mediaType);
      if (pickResult.isFailure) {
        return Result.failure(pickResult.failure);
      }

      filePath = pickResult.value;
      if (filePath == null) {
        // Пользователь отменил выбор
        return Result.failure(
          const MediaGalleryFailure(
            message: 'Выбор файла отменен пользователем',
          ),
        );
      }
    }

    // Импортируем и шифруем файл
    return _mediaRepository.importAndEncryptFile(
      filePath,
      removeOriginal: params.removeOriginal,
    );
  }

  /// Вспомогательный метод для выбора медиафайла
  Future<Result<String?>> _pickMediaFile(MediaType? mediaType) async {
    if (mediaType == MediaType.image) {
      return _galleryRepository.pickImage();
    } else if (mediaType == MediaType.video) {
      return _galleryRepository.pickVideo();
    } else {
      return _galleryRepository.pickMediaFile();
    }
  }
}
