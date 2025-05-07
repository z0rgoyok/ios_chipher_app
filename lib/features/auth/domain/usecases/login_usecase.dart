import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/auth/domain/entities/auth_state.dart';
import 'package:ios_chipher_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ios_chipher_app/core/errors/failures.dart';

/// Параметры для аутентификации
class LoginParams {
  /// Пароль для аутентификации (если используется)
  final String? password;

  /// Использовать биометрическую аутентификацию
  final bool useBiometric;

  /// Причина для отображения диалога биометрии
  final String biometricReason;

  const LoginParams({
    this.password,
    this.useBiometric = false,
    this.biometricReason = 'Войдите в приложение',
  });
}

/// Use case для аутентификации пользователя
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  /// Выполняет аутентификацию пользователя
  ///
  /// В зависимости от текущего метода аутентификации и переданных параметров
  /// использует пароль и/или биометрию
  Future<Result<AuthState>> call(LoginParams params) async {
    // Получаем текущее состояние аутентификации
    final authStateResult = await _authRepository.getAuthState();
    if (authStateResult.isFailure) {
      return Result.failure(authStateResult.failure);
    }

    final authState = authStateResult.value;
    bool authenticated = false;

    // Проверяем метод аутентификации
    switch (authState.authMethod) {
      case AuthMethod.none:
        // Если метод не настроен, считаем аутентификацию успешной
        authenticated = true;
        break;

      case AuthMethod.password:
        // Только пароль
        if (params.password == null) {
          return Result.failure(const AuthFailure(message: 'Пароль не указан'));
        }

        final verifyResult = await _authRepository.verifyPassword(
          params.password!,
        );
        if (verifyResult.isFailure) {
          return Result.failure(verifyResult.failure);
        }

        authenticated = verifyResult.value;
        break;

      case AuthMethod.biometric:
        // Только биометрия
        if (!params.useBiometric) {
          return Result.failure(
            const AuthFailure(
              message: 'Требуется биометрическая аутентификация',
            ),
          );
        }

        final biometricResult = await _authRepository
            .authenticateWithBiometrics(params.biometricReason);
        if (biometricResult.isFailure) {
          return Result.failure(biometricResult.failure);
        }

        authenticated = biometricResult.value;
        break;

      case AuthMethod.both:
        // Пароль + биометрия
        if (params.password == null && !params.useBiometric) {
          return Result.failure(
            const AuthFailure(
              message: 'Требуется пароль или биометрическая аутентификация',
            ),
          );
        }

        if (params.password != null) {
          final verifyResult = await _authRepository.verifyPassword(
            params.password!,
          );
          if (verifyResult.isFailure) {
            return Result.failure(verifyResult.failure);
          }
          authenticated = verifyResult.value;
        } else if (params.useBiometric) {
          final biometricResult = await _authRepository
              .authenticateWithBiometrics(params.biometricReason);
          if (biometricResult.isFailure) {
            return Result.failure(biometricResult.failure);
          }
          authenticated = biometricResult.value;
        }
        break;
    }

    if (!authenticated) {
      return Result.failure(
        const AuthFailure(message: 'Ошибка аутентификации'),
      );
    }

    // Обновляем состояние аутентификации
    final updatedState = authState.copyWith(
      isAuthenticated: true,
      lastAuthTime: DateTime.now(),
    );

    return Result.success(updatedState);
  }
}
