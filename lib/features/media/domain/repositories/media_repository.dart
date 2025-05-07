import 'dart:typed_data';

import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';

/// Абстрактный репозиторий для работы с медиафайлами
abstract class MediaRepository {
  /// Получает список всех зашифрованных медиафайлов
  Future<Result<List<MediaFile>>> getAllMediaFiles();

  /// Получает конкретный медиафайл по его ID
  Future<Result<MediaFile>> getMediaFileById(String id);

  /// Импортирует и шифрует файл из галереи устройства
  ///
  /// [filePath] - путь к файлу в галерее устройства
  /// [removeOriginal] - флаг, указывающий, нужно ли удалять оригинал после шифрования
  Future<Result<MediaFile>> importAndEncryptFile(
    String filePath, {
    bool removeOriginal = true,
  });

  /// Дешифрует медиафайл для временного просмотра
  ///
  /// Возвращает дешифрованные данные в памяти, не сохраняя на диск
  Future<Result<Uint8List>> decryptFileForViewing(String mediaFileId);

  /// Экспортирует и дешифрует файл во временную директорию для шаринга
  ///
  /// Возвращает путь к временному дешифрованному файлу
  Future<Result<String>> decryptFileForSharing(String mediaFileId);

  /// Удаляет зашифрованный медиафайл
  Future<Result<bool>> deleteMediaFile(String mediaFileId);

  /// Получает миниатюру для медиафайла
  ///
  /// [generateIfNotExists] - создавать миниатюру, если она отсутствует
  Future<Result<Uint8List>> getThumbnail(
    String mediaFileId, {
    bool generateIfNotExists = true,
  });
}
