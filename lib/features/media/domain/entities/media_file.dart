import 'package:equatable/equatable.dart';

/// Сущность, представляющая медиафайл
class MediaFile extends Equatable {
  /// Уникальный идентификатор медиафайла
  final String id;

  /// Исходное имя файла
  final String name;

  /// Путь к зашифрованному файлу
  final String path;

  /// Размер файла в байтах
  final int size;

  /// Тип медиафайла (image, video, etc.)
  final String type;

  /// Путь к миниатюре (может быть null, если миниатюра не создана)
  final String? thumbnailPath;

  /// Исходный путь к файлу (может использоваться для отслеживания)
  final String? originalPath;

  /// Дата и время создания записи
  final DateTime createdAt;

  /// Дата и время последнего обновления записи
  final DateTime updatedAt;

  const MediaFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailPath,
    this.originalPath,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    path,
    size,
    type,
    thumbnailPath,
    originalPath,
    createdAt,
    updatedAt,
  ];

  /// Возвращает расширение исходного файла
  String get originalExtension {
    final extensionIndex = name.lastIndexOf('.');
    if (extensionIndex != -1 && extensionIndex < name.length - 1) {
      return name.substring(extensionIndex + 1).toLowerCase();
    }
    return '';
  }

  /// Проверяет, является ли файл изображением
  bool get isImage => type == 'image';

  /// Проверяет, является ли файл видео
  bool get isVideo => type == 'video';
}
