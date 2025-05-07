import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/media_repository.dart';

/// Use case для шаринга медиафайла
class ShareMediaUseCase {
  final MediaRepository _mediaRepository;

  ShareMediaUseCase(this._mediaRepository);

  /// Подготавливает медиафайл для шаринга, расшифровывая его во временный файл
  ///
  /// [mediaFileId] - идентификатор медиафайла
  /// Возвращает путь к временному файлу, который можно использовать для шаринга
  Future<Result<String>> call(String mediaFileId) async {
    return _mediaRepository.decryptFileForSharing(mediaFileId);
  }
}
