import 'package:equatable/equatable.dart';

/// Тип медиафайла
enum MediaType { image, video, unknown }

/// Базовая сущность медиафайла
class MediaFile extends Equatable {
  /// Уникальный идентификатор файла
  final String id;

  /// Имя файла до шифрования
  final String originalName;

  /// Тип медиафайла (изображение/видео)
  final MediaType mediaType;

  /// Путь к зашифрованному файлу в приложении
  final String encryptedPath;

  /// Размер файла в байтах
  final int size;

  /// Дата и время создания файла
  final DateTime createdAt;

  /// Дата и время шифрования файла
  final DateTime encryptedAt;

  /// Идентификатор для миниатюры (если есть)
  final String? thumbnailId;

  /// Метаданные, спец. для данного типа файла (разрешение, длительность и т.д.)
  final Map<String, dynamic> metadata;

  const MediaFile({
    required this.id,
    required this.originalName,
    required this.mediaType,
    required this.encryptedPath,
    required this.size,
    required this.createdAt,
    required this.encryptedAt,
    this.thumbnailId,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    originalName,
    mediaType,
    encryptedPath,
    size,
    createdAt,
    encryptedAt,
    thumbnailId,
  ];

  /// Возвращает расширение исходного файла
  String get originalExtension {
    final extensionIndex = originalName.lastIndexOf('.');
    if (extensionIndex != -1 && extensionIndex < originalName.length - 1) {
      return originalName.substring(extensionIndex + 1).toLowerCase();
    }
    return '';
  }

  /// Проверяет, является ли файл изображением
  bool get isImage => mediaType == MediaType.image;

  /// Проверяет, является ли файл видео
  bool get isVideo => mediaType == MediaType.video;
}
