/// Типы медиафайлов
enum MediaType {
  /// Изображение
  image,

  /// Видео
  video,

  /// Другой тип медиа
  other;

  /// Преобразует строковое представление типа в enum
  static MediaType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      default:
        return MediaType.other;
    }
  }

  /// Преобразует enum в строковое представление
  String toStringValue() {
    switch (this) {
      case MediaType.image:
        return 'image';
      case MediaType.video:
        return 'video';
      case MediaType.other:
        return 'other';
    }
  }
}
