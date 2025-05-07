import 'package:ios_chipher_app/features/media/data/models/media_file_model.dart';

/// Интерфейс для работы с локальной базой данных
abstract class LocalDatabaseDataSource {
  /// Инициализирует базу данных
  Future<void> init();

  /// Получает все медиафайлы из базы данных
  Future<List<MediaFileModel>> getAllMediaFiles();

  /// Получает медиафайл по ID
  Future<MediaFileModel?> getMediaFileById(String id);

  /// Сохраняет медиафайл в базу данных
  Future<void> saveMediaFile(MediaFileModel mediaFile);

  /// Удаляет медиафайл из базы данных
  Future<void> deleteMediaFile(String id);

  /// Проверяет существование медиафайла в базе данных
  Future<bool> hasMediaFile(String id);

  /// Обновляет информацию о медиафайле
  Future<void> updateMediaFile(MediaFileModel mediaFile);

  /// Закрывает соединение с базой данных
  Future<void> close();
}
