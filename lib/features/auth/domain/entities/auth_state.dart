import 'package:equatable/equatable.dart';

/// Перечисление возможных типов аутентификации
enum AuthMethod {
  none,
  password,
  biometric,
  both, // комбинированный (пароль + биометрия)
}

/// Класс, представляющий текущее состояние аутентификации
class AuthState extends Equatable {
  /// Флаг, указывающий, прошел ли пользователь аутентификацию
  final bool isAuthenticated;

  /// Текущий метод аутентификации
  final AuthMethod authMethod;

  /// Флаг, указывающий, настроена ли биометрическая аутентификация
  final bool isBiometricAvailable;

  /// Флаг, указывающий, настроена ли аутентификация по паролю
  final bool isPasswordSet;

  /// Флаг, указывающий, является ли это первым запуском приложения
  final bool isFirstLaunch;

  /// Время последней аутентификации (для автоматической блокировки)
  final DateTime? lastAuthTime;

  const AuthState({
    this.isAuthenticated = false,
    this.authMethod = AuthMethod.none,
    this.isBiometricAvailable = false,
    this.isPasswordSet = false,
    this.isFirstLaunch = false,
    this.lastAuthTime,
  });

  @override
  List<Object?> get props => [
    isAuthenticated,
    authMethod,
    isBiometricAvailable,
    isPasswordSet,
    isFirstLaunch,
    lastAuthTime,
  ];

  /// Создает копию объекта с новыми значениями
  AuthState copyWith({
    bool? isAuthenticated,
    AuthMethod? authMethod,
    bool? isBiometricAvailable,
    bool? isPasswordSet,
    bool? isFirstLaunch,
    DateTime? lastAuthTime,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authMethod: authMethod ?? this.authMethod,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isPasswordSet: isPasswordSet ?? this.isPasswordSet,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      lastAuthTime: lastAuthTime ?? this.lastAuthTime,
    );
  }

  /// Сбрасывает состояние аутентификации, сохраняя настройки
  AuthState logout() {
    return copyWith(isAuthenticated: false, lastAuthTime: null);
  }

  /// Обновляет время последней аутентификации
  AuthState updateLastAuthTime() {
    return copyWith(lastAuthTime: DateTime.now());
  }

  /// Проверяет, истекло ли время сессии
  bool isSessionExpired(Duration timeout) {
    if (lastAuthTime == null) return true;

    final now = DateTime.now();
    return now.difference(lastAuthTime!) > timeout;
  }
}
