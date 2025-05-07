import 'package:ios_chipher_app/core/utils/result.dart';

/// Абстрактный репозиторий для работы с галереей устройства
abstract class GalleryRepository {
  /// Запрашивает разрешения для доступа к галерее устройства
  Future<Result<bool>> requestPermissions();

  /// Проверяет наличие разрешений для доступа к галерее устройства
  Future<Result<bool>> checkPermissions();

  /// Открывает диалог выбора изображения
  ///
  /// Возвращает путь к выбранному изображению или null, если выбор отменен
  Future<Result<String?>> pickImage();

  /// Открывает диалог выбора видео
  ///
  /// Возвращает путь к выбранному видео или null, если выбор отменен
  Future<Result<String?>> pickVideo();

  /// Открывает диалог выбора любого медиафайла (изображение или видео)
  ///
  /// Возвращает путь к выбранному файлу или null, если выбор отменен
  Future<Result<String?>> pickMediaFile();

  /// Удаляет медиафайл из галереи устройства
  ///
  /// [filePath] - путь к файлу для удаления
  Future<Result<bool>> deleteFromGallery(String filePath);

  /// Определяет тип медиафайла по пути
  ///
  /// [filePath] - путь к файлу
  Future<Result<String>> getMediaType(String filePath);

  /// Извлекает метаданные из медиафайла
  ///
  /// [filePath] - путь к файлу
  /// Возвращает карту метаданных (размеры для изображения, длительность для видео и т.д.)
  Future<Result<Map<String, dynamic>>> getMediaMetadata(String filePath);
}
