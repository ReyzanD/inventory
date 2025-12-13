import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import 'logging_service.dart';

/// Service untuk mengelola pengaturan aplikasi menggunakan SharedPreferences
class SettingsService {
  static const String _keyLanguageCode = 'languageCode';
  static const String _keyCountryCode = 'countryCode';
  static const String _keyThemeMode = 'themeMode';
  static const String _keyPrimaryColorValue = 'primaryColorValue';
  static const String _keyEnableLowStockNotifications =
      'enableLowStockNotifications';
  static const String _keyEnableExpiryNotifications =
      'enableExpiryNotifications';
  static const String _keyEnableTransactionNotifications =
      'enableTransactionNotifications';
  static const String _keyDefaultLowStockThreshold = 'defaultLowStockThreshold';
  static const String _keyDefaultLowStockItemsThreshold =
      'defaultLowStockItemsThreshold';
  static const String _keyDateFormat = 'dateFormat';
  static const String _keyCurrencySymbol = 'currencySymbol';
  static const String _keyCurrencyLocale = 'currencyLocale';
  static const String _keyEnableAutoBackup = 'enableAutoBackup';
  static const String _keyAutoBackupIntervalDays = 'autoBackupIntervalDays';
  static const String _keyEnableSoundEffects = 'enableSoundEffects';
  static const String _keyEnableHapticFeedback = 'enableHapticFeedback';

  /// Memuat settings dari SharedPreferences
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = AppSettings(
        languageCode: prefs.getString(_keyLanguageCode) ?? 'id',
        countryCode: prefs.getString(_keyCountryCode) ?? 'ID',
        themeMode: prefs.getString(_keyThemeMode) ?? 'system',
        primaryColorValue: prefs.getInt(_keyPrimaryColorValue) ?? 0xFF2196F3,
        enableLowStockNotifications:
            prefs.getBool(_keyEnableLowStockNotifications) ?? true,
        enableExpiryNotifications:
            prefs.getBool(_keyEnableExpiryNotifications) ?? true,
        enableTransactionNotifications:
            prefs.getBool(_keyEnableTransactionNotifications) ?? true,
        defaultLowStockThreshold:
            prefs.getDouble(_keyDefaultLowStockThreshold) ?? 5.0,
        defaultLowStockItemsThreshold:
            prefs.getInt(_keyDefaultLowStockItemsThreshold) ?? 10,
        dateFormat: prefs.getString(_keyDateFormat) ?? 'MMM dd, yyyy',
        currencySymbol: prefs.getString(_keyCurrencySymbol) ?? 'Rp ',
        currencyLocale: prefs.getString(_keyCurrencyLocale) ?? 'id_ID',
        enableAutoBackup: prefs.getBool(_keyEnableAutoBackup) ?? false,
        autoBackupIntervalDays: prefs.getInt(_keyAutoBackupIntervalDays) ?? 7,
        enableSoundEffects: prefs.getBool(_keyEnableSoundEffects) ?? true,
        enableHapticFeedback: prefs.getBool(_keyEnableHapticFeedback) ?? true,
      );

      LoggingService.info('Settings loaded successfully');
      return settings;
    } catch (e) {
      LoggingService.severe('Error loading settings: $e');
      // Return default settings jika terjadi error
      return AppSettings();
    }
  }

  /// Menyimpan settings ke SharedPreferences
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = settings.toMap();

      await prefs.setString(_keyLanguageCode, map['languageCode'] as String);
      await prefs.setString(_keyCountryCode, map['countryCode'] as String);
      await prefs.setString(_keyThemeMode, map['themeMode'] as String);
      await prefs.setInt(
        _keyPrimaryColorValue,
        map['primaryColorValue'] as int,
      );
      await prefs.setBool(
        _keyEnableLowStockNotifications,
        map['enableLowStockNotifications'] as bool,
      );
      await prefs.setBool(
        _keyEnableExpiryNotifications,
        map['enableExpiryNotifications'] as bool,
      );
      await prefs.setBool(
        _keyEnableTransactionNotifications,
        map['enableTransactionNotifications'] as bool,
      );
      await prefs.setDouble(
        _keyDefaultLowStockThreshold,
        map['defaultLowStockThreshold'] as double,
      );
      await prefs.setInt(
        _keyDefaultLowStockItemsThreshold,
        map['defaultLowStockItemsThreshold'] as int,
      );
      await prefs.setString(_keyDateFormat, map['dateFormat'] as String);
      await prefs.setString(
        _keyCurrencySymbol,
        map['currencySymbol'] as String,
      );
      await prefs.setString(
        _keyCurrencyLocale,
        map['currencyLocale'] as String,
      );
      await prefs.setBool(
        _keyEnableAutoBackup,
        map['enableAutoBackup'] as bool,
      );
      await prefs.setInt(
        _keyAutoBackupIntervalDays,
        map['autoBackupIntervalDays'] as int,
      );
      await prefs.setBool(
        _keyEnableSoundEffects,
        map['enableSoundEffects'] as bool,
      );
      await prefs.setBool(
        _keyEnableHapticFeedback,
        map['enableHapticFeedback'] as bool,
      );

      LoggingService.info('Settings saved successfully');
      return true;
    } catch (e) {
      LoggingService.severe('Error saving settings: $e');
      return false;
    }
  }

  /// Menyimpan satu nilai setting
  Future<bool> saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else {
        LoggingService.warning('Unsupported value type for key: $key');
        return false;
      }
      return true;
    } catch (e) {
      LoggingService.severe('Error saving setting $key: $e');
      return false;
    }
  }

  /// Menghapus semua settings (reset ke default)
  Future<bool> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      LoggingService.info('Settings reset successfully');
      return true;
    } catch (e) {
      LoggingService.severe('Error resetting settings: $e');
      return false;
    }
  }
}
