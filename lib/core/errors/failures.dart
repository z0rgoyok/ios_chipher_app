import 'package:equatable/equatable.dart';

/// Базовый класс для всех ошибок в приложении
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure({required this.message, this.code, this.stackTrace});

  @override
  List<Object?> get props => [message, code];
}

/// Ошибки при шифровании и дешифровании
class CryptographyFailure extends Failure {
  const CryptographyFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Ошибки при работе с файловой системой
class FileSystemFailure extends Failure {
  const FileSystemFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Ошибки при взаимодействии с системной галереей
class MediaGalleryFailure extends Failure {
  const MediaGalleryFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Ошибки при аутентификации
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.stackTrace});
}

/// Ошибки при работе с базой данных
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code, super.stackTrace});
}

/// Ошибки при работе с разрешениями
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
