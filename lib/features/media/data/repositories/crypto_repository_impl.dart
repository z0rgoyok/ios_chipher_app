import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:ios_chipher_app/core/errors/failures.dart';
import 'package:ios_chipher_app/core/utils/logger.dart';
import 'package:ios_chipher_app/core/utils/result.dart';
import 'package:ios_chipher_app/features/media/domain/repositories/crypto_repository.dart';

/// Реализация репозитория для криптографических операций
class CryptoRepositoryImpl implements CryptoRepository {
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _passwordHashKey = 'password_hash';
  static const String _ivKey = 'encryption_iv';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Создает IV (вектор инициализации) для шифрования
  Future<String> _createAndStoreIV() async {
    final iv = encrypt.IV.fromSecureRandom(16).base64;
    await _secureStorage.write(key: _ivKey, value: iv);
    return iv;
  }

  /// Получает сохраненный IV или создает новый, если он не существует
  Future<String> _getOrCreateIV() async {
    final iv = await _secureStorage.read(key: _ivKey);
    if (iv == null) {
      return _createAndStoreIV();
    }
    return iv;
  }

  @override
  Future<Result<void>> generateAndStoreEncryptionKey() async {
    try {
      // Проверяем, существует ли уже ключ
      final existingKey = await _secureStorage.read(key: _encryptionKeyKey);
      if (existingKey != null) {
        return Result.success(null);
      }

      // Генерируем новый случайный ключ (32 байта для AES-256)
      final key = encrypt.Key.fromSecureRandom(32).base64;

      // Сохраняем ключ в безопасном хранилище
      await _secureStorage.write(key: _encryptionKeyKey, value: key);

      // Создаем и сохраняем IV
      await _createAndStoreIV();

      AppLogger.i('Ключ шифрования успешно создан и сохранен');
      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при генерации ключа шифрования', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось создать ключ шифрования',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> hasEncryptionKey() async {
    try {
      final key = await _secureStorage.read(key: _encryptionKeyKey);
      return Result.success(key != null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при проверке наличия ключа шифрования', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось проверить наличие ключа шифрования',
          stackTrace: stack,
        ),
      );
    }
  }

  /// Получает сохраненный ключ шифрования
  Future<Result<String>> _getEncryptionKey() async {
    try {
      final key = await _secureStorage.read(key: _encryptionKeyKey);
      if (key == null) {
        return Result.failure(
          CryptographyFailure(message: 'Ключ шифрования не найден'),
        );
      }
      return Result.success(key);
    } catch (e, stack) {
      AppLogger.e('Ошибка при получении ключа шифрования', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось получить ключ шифрования',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<Uint8List>> encryptData(Uint8List data) async {
    try {
      final keyResult = await _getEncryptionKey();
      if (keyResult.isFailure) {
        return Result.failure(keyResult.failure);
      }

      final ivStr = await _getOrCreateIV();

      final key = encrypt.Key.fromBase64(keyResult.value);
      final iv = encrypt.IV.fromBase64(ivStr);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      // Шифрование данных
      final encrypted = encrypter.encryptBytes(data, iv: iv);

      return Result.success(Uint8List.fromList(encrypted.bytes));
    } catch (e, stack) {
      AppLogger.e('Ошибка при шифровании данных', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось зашифровать данные',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<Uint8List>> decryptData(Uint8List encryptedData) async {
    try {
      final keyResult = await _getEncryptionKey();
      if (keyResult.isFailure) {
        return Result.failure(keyResult.failure);
      }

      final ivStr = await _secureStorage.read(key: _ivKey);
      if (ivStr == null) {
        return Result.failure(CryptographyFailure(message: 'IV не найден'));
      }

      final key = encrypt.Key.fromBase64(keyResult.value);
      final iv = encrypt.IV.fromBase64(ivStr);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      // Расшифровка данных
      final encrypted = encrypt.Encrypted(encryptedData);
      final decryptedData = encrypter.decryptBytes(encrypted, iv: iv);

      return Result.success(Uint8List.fromList(decryptedData));
    } catch (e, stack) {
      AppLogger.e('Ошибка при расшифровке данных', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось расшифровать данные',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> encryptFile(
    String inputFilePath,
    String outputFilePath,
  ) async {
    try {
      final inputFile = File(inputFilePath);
      if (!await inputFile.exists()) {
        return Result.failure(
          CryptographyFailure(message: 'Исходный файл не найден'),
        );
      }

      final data = await inputFile.readAsBytes();
      final encryptResult = await encryptData(data);

      if (encryptResult.isFailure) {
        return Result.failure(encryptResult.failure);
      }

      final outputFile = File(outputFilePath);
      await outputFile.writeAsBytes(encryptResult.value);

      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при шифровании файла', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось зашифровать файл',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> decryptFile(
    String encryptedFilePath,
    String outputFilePath,
  ) async {
    try {
      final encryptedFile = File(encryptedFilePath);
      if (!await encryptedFile.exists()) {
        return Result.failure(
          CryptographyFailure(message: 'Зашифрованный файл не найден'),
        );
      }

      final encryptedData = await encryptedFile.readAsBytes();
      final decryptResult = await decryptData(encryptedData);

      if (decryptResult.isFailure) {
        return Result.failure(decryptResult.failure);
      }

      final outputFile = File(outputFilePath);
      await outputFile.writeAsBytes(decryptResult.value);

      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при расшифровке файла', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось расшифровать файл',
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
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        return Result.failure(
          CryptographyFailure(
            message: 'Биометрическая аутентификация не поддерживается',
          ),
        );
      }

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
        CryptographyFailure(
          message: 'Ошибка при биометрической аутентификации',
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
        CryptographyFailure(
          message: 'Непредвиденная ошибка при биометрической аутентификации',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<void>> protectKeyWithPassword(String password) async {
    try {
      // Создаем хеш пароля
      final passwordBytes = utf8.encode(password);
      final hash = sha256.convert(passwordBytes).toString();

      // Сохраняем хеш в безопасном хранилище
      await _secureStorage.write(key: _passwordHashKey, value: hash);

      return Result.success(null);
    } catch (e, stack) {
      AppLogger.e('Ошибка при защите ключа паролем', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось защитить ключ паролем',
          stackTrace: stack,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> verifyPassword(String password) async {
    try {
      final storedHash = await _secureStorage.read(key: _passwordHashKey);
      if (storedHash == null) {
        return Result.failure(
          CryptographyFailure(message: 'Пароль не установлен'),
        );
      }

      // Проверяем, совпадает ли хеш введенного пароля с сохраненным
      final inputPasswordBytes = utf8.encode(password);
      final inputPasswordHash = sha256.convert(inputPasswordBytes).toString();

      return Result.success(storedHash == inputPasswordHash);
    } catch (e, stack) {
      AppLogger.e('Ошибка при проверке пароля', e, stack);
      return Result.failure(
        CryptographyFailure(
          message: 'Не удалось проверить пароль',
          stackTrace: stack,
        ),
      );
    }
  }
}
