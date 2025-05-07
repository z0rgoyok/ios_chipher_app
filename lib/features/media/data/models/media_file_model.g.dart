// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaFileModel _$MediaFileModelFromJson(Map<String, dynamic> json) =>
    MediaFileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      size: (json['size'] as num).toInt(),
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
      originalPath: json['originalPath'] as String?,
    );

Map<String, dynamic> _$MediaFileModelToJson(MediaFileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'size': instance.size,
      'type': instance.type,
      'thumbnailPath': instance.thumbnailPath,
      'originalPath': instance.originalPath,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
