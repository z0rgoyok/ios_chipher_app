import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/auth/domain/entities/auth_state.dart';

/// Абстрактный репозиторий для аутентификации
abstract class AuthRepository {
  /// Получает текущее состояние аутентификации
  Future<Result<AuthState>> getAuthState();

  /// Проверяет доступность биометрической аутентификации на устройстве
  Future<Result<bool>> checkBiometricAvailability();

  /// Аутентифицирует пользователя с использованием биометрии
  ///
  /// [localizedReason] - причина для отображения пользователю
  Future<Result<bool>> authenticateWithBiometrics(String localizedReason);

  /// Устанавливает или изменяет пароль приложения
  ///
  /// [password] - новый пароль
  /// [oldPassword] - старый пароль (требуется при изменении)
  Future<Result<bool>> setPassword(String password, {String? oldPassword});

  /// Проверяет пароль приложения
  ///
  /// [password] - пароль для проверки
  Future<Result<bool>> verifyPassword(String password);

  /// Сбрасывает аутентификацию (выход)
  Future<Result<void>> logout();

  /// Включает или отключает использование биометрической аутентификации
  ///
  /// [enable] - флаг, указывающий включить (true) или отключить (false)
  Future<Result<bool>> setBiometricEnabled(bool enable);

  /// Изменяет метод аутентификации
  ///
  /// [method] - новый метод аутентификации
  Future<Result<bool>> setAuthMethod(AuthMethod method);

  /// Сбрасывает все данные аутентификации и настройки (сброс приложения)
  Future<Result<bool>> resetAppAuthentication();
}
