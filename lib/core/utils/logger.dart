import 'package:logger/logger.dart';

/// Уровни логирования
enum LogLevel { verbose, debug, info, warning, error, nothing }

/// Логгер приложения
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Логирует сообщение с уровнем Verbose
  static void v(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Логирует сообщение с уровнем Debug
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Логирует сообщение с уровнем Info
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Логирует сообщение с уровнем Warning
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Логирует сообщение с уровнем Error
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Логирует сообщение с указанным уровнем
  static void log(
    LogLevel level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    switch (level) {
      case LogLevel.verbose:
        v(message, error, stackTrace);
        break;
      case LogLevel.debug:
        d(message, error, stackTrace);
        break;
      case LogLevel.info:
        i(message, error, stackTrace);
        break;
      case LogLevel.warning:
        w(message, error, stackTrace);
        break;
      case LogLevel.error:
        e(message, error, stackTrace);
        break;
      case LogLevel.nothing:
        // Ничего не делаем
        break;
    }
  }
}
