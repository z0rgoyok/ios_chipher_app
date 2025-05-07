import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_chipher_app/core/errors/failures.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/auth/domain/entities/auth_state.dart';
import 'package:ios_chipher_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _passwordKey = 'app_password';
  static const String _authMethodKey = 'auth_method';
  static const String _biometricEnabledKey = 'biometric_enabled';

  @override
  Future<Result<AuthState>> getAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPasswordSet = prefs.containsKey(_passwordKey);
      final authMethodStr =
          prefs.getString(_authMethodKey) ?? AuthMethod.password.name;
      final authMethod = AuthMethod.values.firstWhere(
        (e) => e.name == authMethodStr,
        orElse: () => AuthMethod.password,
      );
      final isBiometricAvailable = prefs.getBool(_biometricEnabledKey) ?? false;

      return Result.success(
        AuthState(
          isAuthenticated: false,
          authMethod: authMethod,
          isPasswordSet: isPasswordSet,
          isBiometricAvailable: isBiometricAvailable,
        ),
      );
    } catch (e, stack) {
      AppLogger.e('Ошибка при получении статуса аутентификации', e, stack);
      return Result.failure(
        AuthFailure(
          message: 'Не удалось получить статус аутентификации',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> checkBiometricAvailability() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      return Result.success(canAuthenticate);
    } on PlatformException catch (e, stack) {
      AppLogger.e('Ошибка при проверке доступности биометрии', e, stack);
      return Result.failure(
        AuthFailure(
          message: 'Не удалось проверить доступность биометрии',
          stackTrace: stack,
        ),
      );
    } catch (e, stack) {
      AppLogger.e('Неизвестная ошибка при проверке биометрии', e, stack);
      return Result.failure(
        AuthFailure(
          message: 'Непредвиденная ошибка при проверке биометрии',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> authenticateWithBiometrics(
    String localizedReason,
  ) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return Result.success(authenticated);
    } on PlatformException catch (e, stack) {
      AppLogger.e('Ошибка при биометрической аутентификации', e, stack);
      return Result.failure(
        AuthFailure(
          message: 'Не удалось выполнить биометрическую аутентификацию',
          stackTrace: stack,
        ),
      );
    } catch (e, stack) {
      AppLogger.e(
        'Неизвестная ошибка при биометрической аутентификации',
        e,
        stack,
      );
      return Result.failure(
        AuthFailure(
          message: 'Непредвиденная ошибка при биометрической аутентификации',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> setPassword(
    String password, {
    String? oldPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Если пароль уже установлен, проверяем старый пароль
      if (prefs.containsKey(_passwordKey) && oldPassword != null) {
        final storedPassword = prefs.getString(_passwordKey);
        if (storedPassword != oldPassword) {
          return Result.failure(
            const AuthFailure(message: 'Неверный старый пароль'),
          );
        }
      }

      await prefs.setString(_passwordKey, password);

      // Если пароль устанавливается впервые, устанавливаем метод аутентификации
      if (!prefs.containsKey(_authMethodKey)) {
        await prefs.setString(_authMethodKey, AuthMethod.password.name);
      }

      return Result.success(true);
    } catch (e, stack) {
      AppLogger.e('Ошибка при установке пароля', e, stack);
      return Result.failure(
        AuthFailure(message: 'Не удалось установить пароль', stackTrace: stack),
      );
    }
  }

  @override
  Future<Result<bool>> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString(_passwordKey);

      if (storedPassword == null) {
        return Result.failure(
          const AuthFailure(message: 'Пароль не установлен'),
        );
      }

      return Result.success(storedPassword == password);
    } catch (e, stack) {
      AppLogger.e('Ошибка при проверке пароля', e, stack);
      return Result.failure(
        AuthFailure(message: 'Не удалось проверить пароль', stackTrace: stack),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      // Логика выхода не изменяет сохраненных учетных данных,
      // только изменяет состояние аутентификации в памяти приложения
      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при выходе из системы', e, stack);
      return Result.failure(
        AuthFailure(message: 'Не удалось выйти из системы', stackTrace: stack),
      );
    }
  }

  @override
  Future<Result<bool>> setBiometricEnabled(bool enable) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Проверка доступности биометрии при включении
      if (enable) {
        final availabilityResult = await checkBiometricAvailability();
        if (availabilityResult.isFailure || !(availabilityResult.value)) {
          return Result.failure(
            const AuthFailure(
              message:
                  'Биометрическая аутентификация не поддерживается на этом устройстве',
            ),
          );
        }
      }

      await prefs.setBool(_biometricEnabledKey, enable);
      return Result.success(enable);
    } catch (e, stack) {
      AppLogger.e('Ошибка при изменении настроек биометрии', e, stack);
      return Result.failure(
        AuthFailure(
          message: 'Не удалось изменить настройки биометрии',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> setAuthMethod(AuthMethod method) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Для биометрии проверяем поддержку устройством
      if (method == AuthMethod.biometric) {
        final availabilityResult = await checkBiometricAvailability();
        if (availabilityResult.isFailure || !(availabilityResult.value)) {
          return Result.failure(
            const AuthFailure(
              message:
                  'Биометрическая аутентификация не поддерживается на этом устройстве',
            ),
          );
        }
        await prefs.setBool(_biometricEnabledKey, true);
      }

      await prefs.setString(_authMethodKey, method.name);
      return Result.success(true);
    } catch (e, stack) {
      AppLogger.e('Ошибка при изменении метода аутентификации', e, stack);
      return Result.failure(
        AuthFailure(
          message: 'Не удалось изменить метод аутентификации',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> resetAppAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_passwordKey);
      await prefs.remove(_authMethodKey);
      await prefs.remove(_biometricEnabledKey);

      return Result.success(true);
    } catch (e, stack) {
      AppLogger.e('Ошибка при сбросе аутентификации', e, stack);
      return Result.failure(
        AuthFailure(
          message: 'Не удалось сбросить аутентификацию',
          stackTrace: stack,
        ),
      );
    }
  }
}
