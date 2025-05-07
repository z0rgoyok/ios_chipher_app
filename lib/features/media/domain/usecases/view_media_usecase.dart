import 'dart:typed_data';

import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/media_repository.dart';

/// Use case для просмотра медиафайла
class ViewMediaUseCase {
  final MediaRepository _mediaRepository;

  ViewMediaUseCase(this._mediaRepository);

  /// Подготавливает медиафайл для просмотра, расшифровывая его в памяти
  ///
  /// [mediaFileId] - идентификатор медиафайла
  Future<Result<Uint8List>> call(String mediaFileId) async {
    return _mediaRepository.decryptFileForViewing(mediaFileId);
  }
}
