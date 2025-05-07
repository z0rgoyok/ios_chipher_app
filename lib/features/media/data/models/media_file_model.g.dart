// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaFileModel _$MediaFileModelFromJson(Map<String, dynamic> json) =>
    MediaFileModel(
      id: json['id'] as String,
      originalName: json['originalName'] as String,
      mediaType: $enumDecode(
        _$MediaTypeEnumMap,
        json['mediaType'],
        unknownValue: MediaType.unknown,
      ),
      encryptedPath: json['encryptedPath'] as String,
      size: (json['size'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      encryptedAt: DateTime.parse(json['encryptedAt'] as String),
      thumbnailId: json['thumbnailId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MediaFileModelToJson(MediaFileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalName': instance.originalName,
      'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
      'encryptedPath': instance.encryptedPath,
      'size': instance.size,
      'createdAt': instance.createdAt.toIso8601String(),
      'encryptedAt': instance.encryptedAt.toIso8601String(),
      'thumbnailId': instance.thumbnailId,
      'metadata': instance.metadata,
    };

const _$MediaTypeEnumMap = {
  MediaType.image: 'image',
  MediaType.video: 'video',
  MediaType.unknown: 'unknown',
};
