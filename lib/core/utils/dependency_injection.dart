import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ios_chipher_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/crypto_repository.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/file_system_repository.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/gallery_repository.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/media_repository.dart';
import 'package:ios_chipher_app/features/media/domain/usecases/get_all_media_usecase.dart';
import 'package:ios_chipher_app/features/media/domain/usecases/import_media_usecase.dart';
import 'package:ios_chipher_app/features/media/domain/usecases/share_media_usecase.dart';
import 'package:ios_chipher_app/features/media/domain/usecases/view_media_usecase.dart';

/// Провайдеры для инъекции зависимостей в приложении
class DI {
  DI._();

  // Репозитории (в реальном приложении здесь будут созданы реальные реализации)
  static final authRepositoryProvider = Provider<AuthRepository>((ref) {
    AppLogger.i('Инициализация AuthRepository');
    throw UnimplementedError('AuthRepository еще не реализован');
  });

  static final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
    AppLogger.i('Инициализация MediaRepository');
    throw UnimplementedError('MediaRepository еще не реализован');
  });

  static final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
    AppLogger.i('Инициализация CryptoRepository');
    throw UnimplementedError('CryptoRepository еще не реализован');
  });

  static final fileSystemRepositoryProvider = Provider<FileSystemRepository>((
    ref,
  ) {
    AppLogger.i('Инициализация FileSystemRepository');
    throw UnimplementedError('FileSystemRepository еще не реализован');
  });

  static final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
    AppLogger.i('Инициализация GalleryRepository');
    throw UnimplementedError('GalleryRepository еще не реализован');
  });

  // Use cases
  static final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return LoginUseCase(authRepository);
  });

  static final getAllMediaUseCaseProvider = Provider<GetAllMediaUseCase>((ref) {
    final mediaRepository = ref.watch(mediaRepositoryProvider);
    return GetAllMediaUseCase(mediaRepository);
  });

  static final importMediaUseCaseProvider = Provider<ImportMediaUseCase>((ref) {
    final mediaRepository = ref.watch(mediaRepositoryProvider);
    final galleryRepository = ref.watch(galleryRepositoryProvider);
    return ImportMediaUseCase(mediaRepository, galleryRepository);
  });

  static final viewMediaUseCaseProvider = Provider<ViewMediaUseCase>((ref) {
    final mediaRepository = ref.watch(mediaRepositoryProvider);
    return ViewMediaUseCase(mediaRepository);
  });

  static final shareMediaUseCaseProvider = Provider<ShareMediaUseCase>((ref) {
    final mediaRepository = ref.watch(mediaRepositoryProvider);
    return ShareMediaUseCase(mediaRepository);
  });
}
