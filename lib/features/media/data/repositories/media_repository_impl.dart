import 'dart:typed_data';
import 'package:ios_chipher_app/core/errors/failures.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/data/models/media_file_model.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/crypto_repository.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/file_system_repository.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/gallery_repository.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/media_repository.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// Реализация репозитория для работы с медиафайлами
class MediaRepositoryImpl implements MediaRepository {
  final CryptoRepository _cryptoRepository;
  final FileSystemRepository _fileSystemRepository;
  final GalleryRepository _galleryRepository;

  final String _databaseName = 'media_files.db';
  final String _tableName = 'media_files';
  final int _databaseVersion = 1;

  final Uuid _uuid = const Uuid();
  Database? _database;

  MediaRepositoryImpl({
    required CryptoRepository cryptoRepository,
    required FileSystemRepository fileSystemRepository,
    required GalleryRepository galleryRepository,
  }) : _cryptoRepository = cryptoRepository,
       _fileSystemRepository = fileSystemRepository,
       _galleryRepository = galleryRepository;

  /// Инициализация базы данных
  Future<Database> _initDatabase() async {
    if (_database != null) return _database!;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    return _database!;
  }

  /// Создание таблицы при первом запуске
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        size INTEGER NOT NULL,
        type TEXT NOT NULL,
        thumbnail_path TEXT,
        original_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<Result<List<MediaFile>>> getAllMediaFiles() async {
    try {
      final db = await _initDatabase();
      final records = await db.query(_tableName, orderBy: 'created_at DESC');

      final List<MediaFile> files =
          records.map((record) => MediaFileModel.fromJson(record)).toList();
      return Result.success(files);
    } catch (e, stack) {
      AppLogger.e('Ошибка при получении списка медиафайлов', e, stack);
      return Result.failure(
        DatabaseFailure(
          message: 'Не удалось получить список медиафайлов',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<MediaFile>> getMediaFileById(String id) async {
    try {
      final db = await _initDatabase();
      final records = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (records.isEmpty) {
        return Result.failure(
          DatabaseFailure(message: 'Медиафайл с ID $id не найден'),
        );
      }

      final MediaFile mediaFile = MediaFileModel.fromJson(records.first);
      return Result.success(mediaFile);
    } catch (e, stack) {
      AppLogger.e('Ошибка при получении медиафайла', e, stack);
      return Result.failure(
        DatabaseFailure(
          message: 'Не удалось получить медиафайл',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<MediaFile>> importAndEncryptFile(
    String filePath, {
    bool removeOriginal = true,
  }) async {
    try {
      AppLogger.i('Начинаем импорт и шифрование файла: $filePath');

      // Проверяем существование файла
      AppLogger.i('Проверяем существование файла');
      final fileExistsResult = await _fileSystemRepository.fileExists(filePath);
      if (fileExistsResult.isFailure) {
        AppLogger.e(
          'Ошибка при проверке существования файла: ${fileExistsResult.failure.message}',
        );
        return Result.failure(fileExistsResult.failure);
      }

      if (!fileExistsResult.value) {
        AppLogger.e('Исходный файл не существует: $filePath');
        return Result.failure(
          FileSystemFailure(message: 'Исходный файл не существует: $filePath'),
        );
      }

      AppLogger.i('Файл существует');

      // Получаем метаданные файла
      AppLogger.i('Получаем метаданные файла');
      final metadataResult = await _galleryRepository.getMediaMetadata(
        filePath,
      );
      if (metadataResult.isFailure) {
        AppLogger.e(
          'Ошибка при получении метаданных файла: ${metadataResult.failure.message}',
        );
        return Result.failure(metadataResult.failure);
      }

      final metadata = metadataResult.value;
      final extension = metadata['extension'] as String;
      final fileType = metadata['type'] as String;
      final fileName = metadata['name'] as String;

      AppLogger.i(
        'Метаданные файла: тип=$fileType, имя=$fileName, расширение=$extension',
      );

      // Генерируем путь для зашифрованного файла
      AppLogger.i('Генерируем путь для зашифрованного файла');
      final encryptedPathResult = await _fileSystemRepository
          .generateEncryptedFilePath(extension);
      if (encryptedPathResult.isFailure) {
        AppLogger.e(
          'Ошибка при генерации пути для зашифрованного файла: ${encryptedPathResult.failure.message}',
        );
        return Result.failure(encryptedPathResult.failure);
      }

      final encryptedPath = encryptedPathResult.value;
      AppLogger.i('Сгенерирован путь для зашифрованного файла: $encryptedPath');

      // Шифруем файл
      AppLogger.i('Начинаем шифрование файла');
      final encryptResult = await _cryptoRepository.encryptFile(
        filePath,
        encryptedPath,
      );
      if (encryptResult.isFailure) {
        AppLogger.e(
          'Ошибка при шифровании файла: ${encryptResult.failure.message}',
        );
        return Result.failure(encryptResult.failure);
      }

      AppLogger.i('Файл успешно зашифрован');

      // Если файл был успешно зашифрован, удаляем оригинал если требуется
      if (removeOriginal) {
        AppLogger.i('Удаляем оригинальный файл');
        final deleteResult = await _galleryRepository.deleteFromGallery(
          filePath,
        );

        if (deleteResult.isFailure) {
          AppLogger.w(
            'Не удалось удалить оригинальный файл: ${deleteResult.failure.message}',
          );
        } else if (deleteResult.value) {
          AppLogger.i('Оригинальный файл успешно удален');
        } else {
          AppLogger.w('Оригинальный файл не был удален');
        }
      }

      // Генерируем миниатюру для медиафайла (реализация создания миниатюры в реальном приложении)
      AppLogger.i('Генерируем миниатюру для медиафайла');
      final thumbnailPath = await _generateThumbnail(encryptedPath, fileType);
      AppLogger.i('Миниатюра создана: $thumbnailPath');

      // Создаем запись о медиафайле
      AppLogger.i('Создаем запись о медиафайле в БД');
      final now = DateTime.now();
      final mediaFile = MediaFileModel(
        id: _uuid.v4(),
        name: fileName,
        path: encryptedPath,
        size: metadata['size'] as int,
        type: fileType,
        thumbnailPath: thumbnailPath,
        originalPath: filePath,
        createdAt: now,
        updatedAt: now,
      );

      // Сохраняем в базу данных
      try {
        AppLogger.i('Инициализируем базу данных');
        final db = await _initDatabase();
        AppLogger.i('Добавляем запись в базу данных');
        await db.insert(_tableName, mediaFile.toJson());
        AppLogger.i('Запись успешно добавлена в базу данных');
      } catch (dbError, dbStack) {
        AppLogger.e('Ошибка при сохранении в базу данных', dbError, dbStack);
        return Result.failure(
          DatabaseFailure(
            message:
                'Не удалось сохранить данные о медиафайле: ${dbError.toString()}',
            stackTrace: dbStack,
          ),
        );
      }

      AppLogger.i('Импорт и шифрование файла успешно завершены');
      return Result.success(mediaFile);
    } catch (e, stack) {
      AppLogger.e('Ошибка при импорте и шифровании файла', e, stack);
      return Result.failure(
        MediaGalleryFailure(
          message:
              'Не удалось импортировать и зашифровать файл: ${e.toString()}',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Генерирует миниатюру для медиафайла
  Future<String?> _generateThumbnail(String filePath, String type) async {
    // В реальном приложении здесь будет логика создания миниатюры
    // в зависимости от типа файла (изображение или видео)
    // Для демонстрации вернем null
    return null;
  }

  @override
  Future<Result<Uint8List>> decryptFileForViewing(String mediaFileId) async {
    try {
      // Получаем информацию о медиафайле
      final mediaFileResult = await getMediaFileById(mediaFileId);
      if (mediaFileResult.isFailure) {
        return Result.failure(mediaFileResult.failure);
      }

      final mediaFile = mediaFileResult.value;

      // Проверяем существование зашифрованного файла
      final fileExistsResult = await _fileSystemRepository.fileExists(
        mediaFile.path,
      );
      if (fileExistsResult.isFailure) {
        return Result.failure(fileExistsResult.failure);
      }

      if (!fileExistsResult.value) {
        return Result.failure(
          FileSystemFailure(
            message: 'Зашифрованный файл не существует: ${mediaFile.path}',
          ),
        );
      }

      // Читаем зашифрованные данные
      final encryptedDataResult = await _fileSystemRepository.readDataFromFile(
        mediaFile.path,
      );
      if (encryptedDataResult.isFailure) {
        return Result.failure(encryptedDataResult.failure);
      }

      // Расшифровываем данные
      final decryptResult = await _cryptoRepository.decryptData(
        encryptedDataResult.value,
      );
      if (decryptResult.isFailure) {
        return Result.failure(decryptResult.failure);
      }

      return Result.success(decryptResult.value);
    } catch (e, stack) {
      AppLogger.e('Ошибка при расшифровке файла для просмотра', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось расшифровать файл для просмотра',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<String>> decryptFileForSharing(String mediaFileId) async {
    try {
      // Получаем информацию о медиафайле
      final mediaFileResult = await getMediaFileById(mediaFileId);
      if (mediaFileResult.isFailure) {
        return Result.failure(mediaFileResult.failure);
      }

      final mediaFile = mediaFileResult.value;

      // Проверяем существование зашифрованного файла
      final fileExistsResult = await _fileSystemRepository.fileExists(
        mediaFile.path,
      );
      if (fileExistsResult.isFailure) {
        return Result.failure(fileExistsResult.failure);
      }

      if (!fileExistsResult.value) {
        return Result.failure(
          FileSystemFailure(
            message: 'Зашифрованный файл не существует: ${mediaFile.path}',
          ),
        );
      }

      // Генерируем путь для временного расшифрованного файла
      final tempPathResult = await _fileSystemRepository
          .generateTemporaryFilePath(mediaFile.name);
      if (tempPathResult.isFailure) {
        return Result.failure(tempPathResult.failure);
      }

      // Расшифровываем файл
      final decryptResult = await _cryptoRepository.decryptFile(
        mediaFile.path,
        tempPathResult.value,
      );

      if (decryptResult.isFailure) {
        return Result.failure(decryptResult.failure);
      }

      return Result.success(tempPathResult.value);
    } catch (e, stack) {
      AppLogger.e('Ошибка при расшифровке файла для шаринга', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось расшифровать файл для шаринга',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> deleteMediaFile(String mediaFileId) async {
    try {
      // Получаем информацию о медиафайле
      final mediaFileResult = await getMediaFileById(mediaFileId);
      if (mediaFileResult.isFailure) {
        return Result.failure(mediaFileResult.failure);
      }

      final mediaFile = mediaFileResult.value;

      // Удаляем зашифрованный файл
      final deleteFileResult = await _fileSystemRepository.deleteFile(
        mediaFile.path,
      );
      if (deleteFileResult.isFailure) {
        return Result.failure(deleteFileResult.failure);
      }

      // Удаляем миниатюру, если она существует
      if (mediaFile.thumbnailPath != null) {
        await _fileSystemRepository.deleteFile(mediaFile.thumbnailPath!);
      }

      // Удаляем запись из базы данных
      final db = await _initDatabase();
      await db.delete(_tableName, where: 'id = ?', whereArgs: [mediaFileId]);

      return Result.success(true);
    } catch (e, stack) {
      AppLogger.e('Ошибка при удалении медиафайла', e, stack);
      return Result.failure(
        DatabaseFailure(
          message: 'Не удалось удалить медиафайл',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<Uint8List>> getThumbnail(
    String mediaFileId, {
    bool generateIfNotExists = true,
  }) async {
    try {
      // Получаем информацию о медиафайле
      final mediaFileResult = await getMediaFileById(mediaFileId);
      if (mediaFileResult.isFailure) {
        return Result.failure(mediaFileResult.failure);
      }

      final mediaFile = mediaFileResult.value;

      // Проверяем, есть ли миниатюра
      if (mediaFile.thumbnailPath != null) {
        final thumbnailExistsResult = await _fileSystemRepository.fileExists(
          mediaFile.thumbnailPath!,
        );
        if (thumbnailExistsResult.isFailure) {
          return Result.failure(thumbnailExistsResult.failure);
        }

        if (thumbnailExistsResult.value) {
          // Читаем миниатюру из файла
          final thumbnailDataResult = await _fileSystemRepository
              .readDataFromFile(mediaFile.thumbnailPath!);
          if (thumbnailDataResult.isFailure) {
            return Result.failure(thumbnailDataResult.failure);
          }

          return Result.success(thumbnailDataResult.value);
        }
      }

      // Если миниатюры нет и нужно создать
      if (generateIfNotExists) {
        // В реальном приложении здесь будет логика генерации миниатюры
        // Для простоты вернем изображение-заглушку
        return Result.failure(
          FileSystemFailure(message: 'Генерация миниатюр пока не реализована'),
        );
      }

      return Result.failure(FileSystemFailure(message: 'Миниатюра не найдена'));
    } catch (e, stack) {
      AppLogger.e('Ошибка при получении миниатюры', e, stack);
      return Result.failure(
        FileSystemFailure(
          message: 'Не удалось получить миниатюру',
          stackTrace: stack,
        ),
      );
    }
  }
}
