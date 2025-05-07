import 'dart:typed_data';

/// Интерфейс для работы с файловой системой
abstract class FileSystemDataSource {
  /// Создает директорию для хранения зашифрованных медиафайлов
  Future<String> createEncryptedMediaDirectory();

  /// Создает временную директорию для расшифрованных файлов
  Future<String> createTemporaryDirectory();

  /// Очищает временную директорию
  Future<void> clearTemporaryDirectory();

  /// Сохраняет данные в файл
  Future<void> saveFile(String path, Uint8List data);

  /// Читает данные из файла
  Future<Uint8List> readFile(String path);

  /// Удаляет файл
  Future<void> deleteFile(String path);

  /// Генерирует уникальное имя файла для хранения зашифрованного файла
  Future<String> generateEncryptedFilePath(String extension);

  /// Генерирует путь для временного файла
  Future<String> generateTemporaryFilePath(String originalName);

  /// Проверяет существование файла
  Future<bool> fileExists(String path);

  /// Получает размер файла
  Future<int> getFileSize(String path);
}
