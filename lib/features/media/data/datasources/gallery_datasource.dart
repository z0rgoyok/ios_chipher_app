/// Интерфейс для работы с галереей устройства
abstract class GalleryDataSource {
  /// Запрашивает необходимые разрешения для доступа к галерее
  Future<bool> requestPermissions();

  /// Проверяет наличие разрешений для доступа к галерее
  Future<bool> checkPermissions();

  /// Открывает галерею для выбора изображения
  Future<String?> pickImage();

  /// Открывает галерею для выбора видео
  Future<String?> pickVideo();

  /// Открывает галерею для выбора любого медиафайла
  Future<String?> pickMediaFile();

  /// Удаляет файл из галереи устройства
  Future<bool> deleteFromGallery(String filePath);

  /// Определяет тип медиафайла
  Future<String> getMediaType(String filePath);

  /// Получает метаданные медиафайла
  Future<Map<String, dynamic>> getMediaMetadata(String filePath);
}
