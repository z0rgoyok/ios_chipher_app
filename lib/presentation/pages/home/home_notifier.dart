import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_chipher_app/core/utils/dependency_injection.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_file.dart';
import 'package:ios_chipher_app/features/media/domain/entities/media_type.dart';
import 'package:ios_chipher_app/features/media/domain/usecases/get_all_media_usecase.dart';
import 'package:ios_chipher_app/features/media/domain/usecases/import_media_usecase.dart';

/// Состояние для медиафайлов
class MediaState {
  final List<MediaFile> mediaFiles;
  final bool isLoading;
  final String? error;

  const MediaState({
    this.mediaFiles = const [],
    this.isLoading = false,
    this.error,
  });

  MediaState copyWith({
    List<MediaFile>? mediaFiles,
    bool? isLoading,
    String? error,
  }) {
    return MediaState(
      mediaFiles: mediaFiles ?? this.mediaFiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Нотифаер для управления состоянием медиа файлов
class HomeNotifier extends StateNotifier<MediaState> {
  final GetAllMediaUseCase _getAllMediaUseCase;
  final ImportMediaUseCase _importMediaUseCase;

  HomeNotifier({
    required GetAllMediaUseCase getAllMediaUseCase,
    required ImportMediaUseCase importMediaUseCase,
  }) : _getAllMediaUseCase = getAllMediaUseCase,
       _importMediaUseCase = importMediaUseCase,
       super(const MediaState());

  /// Загружает все медиафайлы из хранилища
  Future<void> loadMediaFiles() async {
    AppLogger.i('Начинаем загрузку медиафайлов');
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAllMediaUseCase.call();

    if (result.isSuccess) {
      AppLogger.i('Успешно загружено ${result.value.length} медиафайлов');
      state = state.copyWith(mediaFiles: result.value, isLoading: false);
    } else {
      final errorMsg = result.failure.message;
      AppLogger.e('Ошибка при загрузке медиафайлов: $errorMsg');
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  /// Импортирует изображение из галереи
  Future<bool> importImage({bool removeOriginal = true}) async {
    AppLogger.i('Начинаем импорт изображения');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _importMediaUseCase.call(
        ImportMediaParams(
          mediaType: MediaType.image,
          removeOriginal: removeOriginal,
        ),
      );

      if (result.isSuccess) {
        AppLogger.i('Изображение успешно импортировано');
        await loadMediaFiles(); // Перезагружаем список после импорта
        return true;
      } else {
        final errorMsg = result.failure.message;
        AppLogger.e(
          'Ошибка при импорте изображения: $errorMsg',
          result.failure,
        );
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      final errorMsg =
          'Непредвиденная ошибка при импорте изображения: ${e.toString()}';
      AppLogger.e(errorMsg, e, stackTrace);
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    }
  }

  /// Импортирует видео из галереи
  Future<bool> importVideo({bool removeOriginal = true}) async {
    AppLogger.i('Начинаем импорт видео');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _importMediaUseCase.call(
        ImportMediaParams(
          mediaType: MediaType.video,
          removeOriginal: removeOriginal,
        ),
      );

      if (result.isSuccess) {
        AppLogger.i('Видео успешно импортировано');
        await loadMediaFiles(); // Перезагружаем список после импорта
        return true;
      } else {
        final errorMsg = result.failure.message;
        AppLogger.e('Ошибка при импорте видео: $errorMsg', result.failure);
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      final errorMsg =
          'Непредвиденная ошибка при импорте видео: ${e.toString()}';
      AppLogger.e(errorMsg, e, stackTrace);
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    }
  }

  /// Импортирует любой медиафайл из галереи
  Future<bool> importMedia({bool removeOriginal = true}) async {
    AppLogger.i('Начинаем импорт любого медиафайла');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _importMediaUseCase.call(
        ImportMediaParams(removeOriginal: removeOriginal),
      );

      if (result.isSuccess) {
        AppLogger.i('Медиафайл успешно импортирован');
        await loadMediaFiles(); // Перезагружаем список после импорта
        return true;
      } else {
        final errorMsg = result.failure.message;
        AppLogger.e('Ошибка при импорте медиафайла: $errorMsg', result.failure);
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }
    } catch (e, stackTrace) {
      final errorMsg =
          'Непредвиденная ошибка при импорте медиафайла: ${e.toString()}';
      AppLogger.e(errorMsg, e, stackTrace);
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    }
  }
}

/// Провайдер для состояния медиа
final homeNotifierProvider = StateNotifierProvider<HomeNotifier, MediaState>((
  ref,
) {
  return HomeNotifier(
    getAllMediaUseCase: ref.watch(DI.getAllMediaUseCaseProvider),
    importMediaUseCase: ref.watch(DI.importMediaUseCaseProvider),
  );
});
