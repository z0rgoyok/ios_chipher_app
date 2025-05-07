import 'dart:typed_data';

import 'package:ios_chipher_app/core/utils/result.dart';

/// Абстрактный репозиторий для работы с файловой системой
abstract class FileSystemRepository {
  /// Создает директорию для хранения шифрованных медиафайлов
  Future<Result<String>> createEncryptedMediaDirectory();

  /// Создает временную директорию для просмотра расшифрованных файлов
  Future<Result<String>> createTemporaryDecryptionDirectory();

  /// Очищает временную директорию
  Future<Result<void>> clearTemporaryDirectory();

  /// Сохраняет данные в файл
  ///
  /// [data] - данные для сохранения
  /// [filePath] - путь для сохранения файла
  Future<Result<void>> saveDataToFile(Uint8List data, String filePath);

  /// Читает данные из файла
  ///
  /// [filePath] - путь к файлу
  Future<Result<Uint8List>> readDataFromFile(String filePath);

  /// Удаляет файл
  ///
  /// [filePath] - путь к файлу
  Future<Result<void>> deleteFile(String filePath);

  /// Создает путь для нового зашифрованного файла с уникальным именем
  ///
  /// [originalExtension] - расширение исходного файла
  Future<Result<String>> generateEncryptedFilePath(String originalExtension);

  /// Создает путь для временного расшифрованного файла
  ///
  /// [originalName] - исходное имя файла
  Future<Result<String>> generateTemporaryFilePath(String originalName);

  /// Проверяет существование файла
  ///
  /// [filePath] - путь к файлу
  Future<Result<bool>> fileExists(String filePath);

  /// Получает размер файла
  ///
  /// [filePath] - путь к файлу
  Future<Result<int>> getFileSize(String filePath);
}
