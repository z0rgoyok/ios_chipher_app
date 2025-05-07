import 'dart:typed_data';

/// Интерфейс для работы с криптографическими операциями
abstract class CryptoDataSource {
  /// Генерирует и сохраняет ключ шифрования в безопасном хранилище
  Future<void> generateAndStoreKey();

  /// Проверяет наличие ключа шифрования
  Future<bool> hasKey();

  /// Получает ключ шифрования из безопасного хранилища
  Future<Uint8List> getEncryptionKey();

  /// Шифрует данные
  Future<Uint8List> encrypt(Uint8List data);

  /// Расшифровывает данные
  Future<Uint8List> decrypt(Uint8List encryptedData);

  /// Шифрует файл
  Future<void> encryptFile(String sourcePath, String destinationPath);

  /// Расшифровывает файл
  Future<void> decryptFile(String sourcePath, String destinationPath);

  /// Проверяет возможность биометрической аутентификации
  Future<bool> canAuthenticateWithBiometrics();

  /// Выполняет биометрическую аутентификацию
  Future<bool> authenticateWithBiometrics(String localizedReason);

  /// Защищает ключ шифрования паролем
  Future<void> protectKeyWithPassword(String password);

  /// Проверяет пароль
  Future<bool> verifyPassword(String password);
}
