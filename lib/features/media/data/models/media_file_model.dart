import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_file_model.g.dart';

/// Модель для работы с медиафайлами в data-слое
@JsonSerializable()
class MediaFileModel {
  final String id;
  final String originalName;
  @JsonKey(unknownEnumValue: MediaType.unknown)
  final MediaType mediaType;
  final String encryptedPath;
  final int size;
  final DateTime createdAt;
  final DateTime encryptedAt;
  final String? thumbnailId;
  final Map<String, dynamic> metadata;

  MediaFileModel({
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

  /// Создает модель из доменной сущности
  factory MediaFileModel.fromEntity(MediaFile entity) {
    return MediaFileModel(
      id: entity.id,
      originalName: entity.originalName,
      mediaType: entity.mediaType,
      encryptedPath: entity.encryptedPath,
      size: entity.size,
      createdAt: entity.createdAt,
      encryptedAt: entity.encryptedAt,
      thumbnailId: entity.thumbnailId,
      metadata: entity.metadata,
    );
  }

  /// Конвертирует модель в доменную сущность
  MediaFile toEntity() {
    return MediaFile(
      id: id,
      originalName: originalName,
      mediaType: mediaType,
      encryptedPath: encryptedPath,
      size: size,
      createdAt: createdAt,
      encryptedAt: encryptedAt,
      thumbnailId: thumbnailId,
      metadata: metadata,
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
    String? originalName,
    MediaType? mediaType,
    String? encryptedPath,
    int? size,
    DateTime? createdAt,
    DateTime? encryptedAt,
    String? thumbnailId,
    Map<String, dynamic>? metadata,
  }) {
    return MediaFileModel(
      id: id ?? this.id,
      originalName: originalName ?? this.originalName,
      mediaType: mediaType ?? this.mediaType,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      encryptedAt: encryptedAt ?? this.encryptedAt,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      metadata: metadata ?? this.metadata,
    );
  }
}
