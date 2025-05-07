import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_file_model.g.dart';

/// Модель для работы с медиафайлами в data-слое
@JsonSerializable()
class MediaFileModel extends MediaFile {
  const MediaFileModel({
    required super.id,
    required super.name,
    required super.path,
    required super.size,
    required super.type,
    required super.createdAt,
    required super.updatedAt,
    super.thumbnailPath,
    super.originalPath,
  });

  /// Создает модель из доменной сущности
  factory MediaFileModel.fromEntity(MediaFile entity) {
    return MediaFileModel(
      id: entity.id,
      name: entity.name,
      path: entity.path,
      size: entity.size,
      type: entity.type,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      thumbnailPath: entity.thumbnailPath,
      originalPath: entity.originalPath,
    );
  }

  /// Конвертирует модель в доменную сущность
  MediaFile toEntity() {
    return MediaFile(
      id: id,
      name: name,
      path: path,
      size: size,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt,
      thumbnailPath: thumbnailPath,
      originalPath: originalPath,
    );
  }

  /// Создает модель из JSON
  factory MediaFileModel.fromJson(Map<String, dynamic> json) =>
      _$MediaFileModelFromJson(json);

  /// Конвертирует модель в JSON
  Map<String, dynamic> toJson() => _$MediaFileModelToJson(this);

  /// Создает копию модели с новыми значениями
  MediaFileModel copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    String? type,
    String? thumbnailPath,
    String? originalPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaFileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      originalPath: originalPath ?? this.originalPath,
    );
  }
}
