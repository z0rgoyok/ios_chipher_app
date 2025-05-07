import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:ios_chipher_app/core/errors/failures.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/file_system_repository.dart';

/// Реализация репозитория для работы с файловой системой
class FileSystemRepositoryImpl implements FileSystemRepository {
  static const String _encryptedMediaDir = 'encrypted_media';
  static const String _tempDecryptDir = 'temp_decrypt';
  final Uuid _uuid = const Uuid();

  /// Получает базовую директорию приложения
  Future<Directory> _getAppDir() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  @override
  Future<Result<String>> createEncryptedMediaDirectory() async {
    try {
      final appDir = await _getAppDir();
      final encryptedDir = Directory(p.join(appDir.path, _encryptedMediaDir));

      if (!await encryptedDir.exists()) {
        await encryptedDir.create(recursive: true);
      }

      return Result.success(encryptedDir.path);
    } catch (e, stack) {
      AppLogger.e(
        'Ошибка при создании директории для шифрованных файлов',
        e,
        stack,
      );
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось создать директорию для шифрованных файлов',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String>> createTemporaryDecryptionDirectory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final decryptDir = Directory(p.join(tempDir.path, _tempDecryptDir));

      if (!await decryptDir.exists()) {
        await decryptDir.create(recursive: true);
      }

      return Result.success(decryptDir.path);
    } catch (e, stack) {
      AppLogger.e('Ошибка при создании временной директории', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось создать временную директорию',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> clearTemporaryDirectory() async {
    try {
      final tempDirResult = await createTemporaryDecryptionDirectory();

      if (tempDirResult.isFailure) {
        return Result.failure(tempDirResult.failure);
      }

      final decryptDir = Directory(tempDirResult.value);

      // Удаляем все файлы в директории, но сохраняем саму директорию
      final files = decryptDir.listSync();
      for (final file in files) {
        await file.delete(recursive: true);
      }

      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при очистке временной директории', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось очистить временную директорию',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveDataToFile(Uint8List data, String filePath) async {
    try {
      final file = File(filePath);

      // Создаем директорию, если ее нет
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await file.writeAsBytes(data);
      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при сохранении данных в файл', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось сохранить данные в файл',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<Uint8List>> readDataFromFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return Result.failure(
          FileSystemFailure(message: 'Файл не существует: $filePath'),
        );
      }

      final data = await file.readAsBytes();
      return Result.success(data);
    } catch (e, stack) {
      AppLogger.e('Ошибка при чтении данных из файла', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось прочитать данные из файла',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteFile(String filePath) async {
    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при удалении файла', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось удалить файл',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String>> generateEncryptedFilePath(
    String originalExtension,
  ) async {
    try {
      final dirResult = await createEncryptedMediaDirectory();

      if (dirResult.isFailure) {
        return Result.failure(dirResult.failure);
      }

      final uniqueId = _uuid.v4();
      final extension =
          originalExtension.startsWith('.')
              ? originalExtension
              : '.$originalExtension';

      final fileName = '$uniqueId$extension.enc';
      final filePath = p.join(dirResult.value, fileName);

      return Result.success(filePath);
    } catch (e, stack) {
      AppLogger.e(
        'Ошибка при генерации пути для зашифрованного файла',
        e,
        stack,
      );
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось создать путь для зашифрованного файла',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String>> generateTemporaryFilePath(String originalName) async {
    try {
      final dirResult = await createTemporaryDecryptionDirectory();

      if (dirResult.isFailure) {
        return Result.failure(dirResult.failure);
      }

      final uniqueId = _uuid.v4();
      final extension = p.extension(originalName);
      final baseName = p.basenameWithoutExtension(originalName);

      // Создаем новое имя с уникальным префиксом, но сохраняем оригинальное имя
      final fileName = '${uniqueId}_$baseName$extension';
      final filePath = p.join(dirResult.value, fileName);

      return Result.success(filePath);
    } catch (e, stack) {
      AppLogger.e('Ошибка при генерации пути для временного файла', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось создать путь для временного файла',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      return Result.success(exists);
    } catch (e, stack) {
      AppLogger.e('Ошибка при проверке существования файла', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось проверить существование файла',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<int>> getFileSize(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return Result.failure(
          FileSystemFailure(message: 'Файл не существует: $filePath'),
        );
      }

      final fileStats = await file.stat();
      return Result.success(fileStats.size);
    } catch (e, stack) {
      AppLogger.e('Ошибка при получении размера файла', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось получить размер файла',
          stackTrace: stack,
        ),
      );
    }
  }
}
