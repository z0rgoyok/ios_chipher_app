/// Константы приложения
class AppConstants {
  AppConstants._();

  // Общие
  static const String appName = 'Secure Media Vault';
  static const String appVersion = '1.0.0';

  // Безопасность
  static const int aesKeySize = 256;
  static const String secureKeyAlias = 'secure_media_vault_key';
  static const int autoLockTimeoutSeconds = 30;

  // Пути хранения
  static const String encryptedMediaFolderName = 'encrypted_media';
  static const String databaseName = 'secure_media_vault.db';
  static const int databaseVersion = 1;

  // Таймауты и буферы
  static const int thumbnailCacheMaxSize =
      100; // макс. количество кэшированных миниатюр
  static const int maxDecryptBufferSizeMb =
      50; // макс. размер буфера для дешифрования в МБ
}
