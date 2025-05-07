import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ios_chipher_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ios_chipher_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:ios_chipher_app/features/media/data/repositories/crypto_repository_impl.dart';
import 'package:ios_chipher_app/features/media/data/repositories/file_system_repository_impl.dart';
import 'package:ios_chipher_app/features/media/data/repositories/gallery_repository_impl.dart';
import 'package:ios_chipher_app/features/media/data/repositories/media_repository_impl.dart';
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

  // Репозитории (реальные реализации)
  static final authRepositoryProvider = Provider<AuthRepository>((ref) {
    AppLogger.i('Инициализация AuthRepository');
    return AuthRepositoryImpl();
  });

  static final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
    AppLogger.i('Инициализация CryptoRepository');
    return CryptoRepositoryImpl();
  });

  static final fileSystemRepositoryProvider = Provider<FileSystemRepository>((
    ref,
  ) {
    AppLogger.i('Инициализация FileSystemRepository');
    return FileSystemRepositoryImpl();
  });

  static final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
    AppLogger.i('Инициализация GalleryRepository');
    return GalleryRepositoryImpl();
  });

  static final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
    AppLogger.i('Инициализация MediaRepository');
    final cryptoRepository = ref.watch(cryptoRepositoryProvider);
    final fileSystemRepository = ref.watch(fileSystemRepositoryProvider);
    final galleryRepository = ref.watch(galleryRepositoryProvider);

    return MediaRepositoryImpl(
      cryptoRepository: cryptoRepository,
      fileSystemRepository: fileSystemRepository,
      galleryRepository: galleryRepository,
    );
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
