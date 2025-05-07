import 'dart:typed_data';

import 'package:ios_chipher_app/core/utils/result.dart';

/// Абстрактный репозиторий для криптографических операций
abstract class CryptoRepository {
  /// Генерирует и безопасно сохраняет ключ шифрования
  ///
  /// Если ключ уже существует, возвращает существующий ключ
  Future<Result<void>> generateAndStoreEncryptionKey();

  /// Проверяет, существует ли ключ шифрования
  Future<Result<bool>> hasEncryptionKey();

  /// Шифрует данные с использованием сохраненного ключа
  ///
  /// [data] - данные для шифрования
  /// Возвращает зашифрованные данные
  Future<Result<Uint8List>> encryptData(Uint8List data);

  /// Расшифровывает данные с использованием сохраненного ключа
  ///
  /// [encryptedData] - зашифрованные данные
  /// Возвращает расшифрованные данные
  Future<Result<Uint8List>> decryptData(Uint8List encryptedData);

  /// Шифрует файл и сохраняет результат по указанному пути
  ///
  /// [inputFilePath] - путь к исходному файлу
  /// [outputFilePath] - путь для сохранения зашифрованного файла
  Future<Result<void>> encryptFile(String inputFilePath, String outputFilePath);

  /// Расшифровывает файл и сохраняет результат по указанному пути
  ///
  /// [encryptedFilePath] - путь к зашифрованному файлу
  /// [outputFilePath] - путь для сохранения расшифрованного файла
  Future<Result<void>> decryptFile(
    String encryptedFilePath,
    String outputFilePath,
  );

  /// Проверяет биометрическую аутентификацию устройства
  ///
  /// [localizedReason] - причина для отображения пользователю
  Future<Result<bool>> authenticateWithBiometrics(String localizedReason);

  /// Защищает ключ шифрования паролем
  ///
  /// [password] - пароль для защиты ключа
  Future<Result<void>> protectKeyWithPassword(String password);

  /// Проверяет правильность пароля
  ///
  /// [password] - пароль для проверки
  Future<Result<bool>> verifyPassword(String password);
}
