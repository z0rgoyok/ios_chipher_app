import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/media_repository.dart';

/// Use case для получения всех медиафайлов
class GetAllMediaUseCase {
  final MediaRepository _mediaRepository;

  GetAllMediaUseCase(this._mediaRepository);

  /// Получает список всех медиафайлов
  Future<Result<List<MediaFile>>> call() async {
    return _mediaRepository.getAllMediaFiles();
  }
}
