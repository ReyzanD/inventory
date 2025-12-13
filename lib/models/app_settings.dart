/// Model untuk menyimpan pengaturan aplikasi
class AppSettings {
  // Language settings
  final String languageCode; // 'id' untuk Indonesia, 'en' untuk Inggris
  final String countryCode; // 'ID' atau 'US'

  // Theme settings
  final String themeMode; // 'light', 'dark', atau 'system'
  final int primaryColorValue; // Nilai warna primary dalam integer

  // Notification settings
  final bool enableLowStockNotifications;
  final bool enableExpiryNotifications;
  final bool enableTransactionNotifications;

  // Inventory settings
  final double defaultLowStockThreshold;
  final int defaultLowStockItemsThreshold;

  // Display settings
  final String dateFormat; // Format tanggal
  final String currencySymbol; // Simbol mata uang
  final String currencyLocale; // Locale untuk mata uang

  // Other settings
  final bool enableAutoBackup;
  final int autoBackupIntervalDays;
  final bool enableSoundEffects;
  final bool enableHapticFeedback;

  AppSettings({
    this.languageCode = 'id',
    this.countryCode = 'ID',
    this.themeMode = 'system',
    this.primaryColorValue = 0xFF2196F3,
    this.enableLowStockNotifications = true,
    this.enableExpiryNotifications = true,
    this.enableTransactionNotifications = true,
    this.defaultLowStockThreshold = 5.0,
    this.defaultLowStockItemsThreshold = 10,
    this.dateFormat = 'MMM dd, yyyy',
    this.currencySymbol = 'Rp ',
    this.currencyLocale = 'id_ID',
    this.enableAutoBackup = false,
    this.autoBackupIntervalDays = 7,
    this.enableSoundEffects = true,
    this.enableHapticFeedback = true,
  });

  /// Membuat copy dari settings dengan beberapa nilai yang diubah
  AppSettings copyWith({
    String? languageCode,
    String? countryCode,
    String? themeMode,
    int? primaryColorValue,
    bool? enableLowStockNotifications,
    bool? enableExpiryNotifications,
    bool? enableTransactionNotifications,
    double? defaultLowStockThreshold,
    int? defaultLowStockItemsThreshold,
    String? dateFormat,
    String? currencySymbol,
    String? currencyLocale,
    bool? enableAutoBackup,
    int? autoBackupIntervalDays,
    bool? enableSoundEffects,
    bool? enableHapticFeedback,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      themeMode: themeMode ?? this.themeMode,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      enableLowStockNotifications:
          enableLowStockNotifications ?? this.enableLowStockNotifications,
      enableExpiryNotifications:
          enableExpiryNotifications ?? this.enableExpiryNotifications,
      enableTransactionNotifications: enableTransactionNotifications ??
          this.enableTransactionNotifications,
      defaultLowStockThreshold:
          defaultLowStockThreshold ?? this.defaultLowStockThreshold,
      defaultLowStockItemsThreshold:
          defaultLowStockItemsThreshold ?? this.defaultLowStockItemsThreshold,
      dateFormat: dateFormat ?? this.dateFormat,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyLocale: currencyLocale ?? this.currencyLocale,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      autoBackupIntervalDays:
          autoBackupIntervalDays ?? this.autoBackupIntervalDays,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    );
  }

  /// Mengkonversi settings ke Map untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'languageCode': languageCode,
      'countryCode': countryCode,
      'themeMode': themeMode,
      'primaryColorValue': primaryColorValue,
      'enableLowStockNotifications': enableLowStockNotifications,
      'enableExpiryNotifications': enableExpiryNotifications,
      'enableTransactionNotifications': enableTransactionNotifications,
      'defaultLowStockThreshold': defaultLowStockThreshold,
      'defaultLowStockItemsThreshold': defaultLowStockItemsThreshold,
      'dateFormat': dateFormat,
      'currencySymbol': currencySymbol,
      'currencyLocale': currencyLocale,
      'enableAutoBackup': enableAutoBackup,
      'autoBackupIntervalDays': autoBackupIntervalDays,
      'enableSoundEffects': enableSoundEffects,
      'enableHapticFeedback': enableHapticFeedback,
    };
  }

  /// Membuat settings dari Map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      languageCode: map['languageCode'] ?? 'id',
      countryCode: map['countryCode'] ?? 'ID',
      themeMode: map['themeMode'] ?? 'system',
      primaryColorValue: map['primaryColorValue'] ?? 0xFF2196F3,
      enableLowStockNotifications:
          map['enableLowStockNotifications'] ?? true,
      enableExpiryNotifications: map['enableExpiryNotifications'] ?? true,
      enableTransactionNotifications:
          map['enableTransactionNotifications'] ?? true,
      defaultLowStockThreshold:
          (map['defaultLowStockThreshold'] ?? 5.0).toDouble(),
      defaultLowStockItemsThreshold:
          map['defaultLowStockItemsThreshold'] ?? 10,
      dateFormat: map['dateFormat'] ?? 'MMM dd, yyyy',
      currencySymbol: map['currencySymbol'] ?? 'Rp ',
      currencyLocale: map['currencyLocale'] ?? 'id_ID',
      enableAutoBackup: map['enableAutoBackup'] ?? false,
      autoBackupIntervalDays: map['autoBackupIntervalDays'] ?? 7,
      enableSoundEffects: map['enableSoundEffects'] ?? true,
      enableHapticFeedback: map['enableHapticFeedback'] ?? true,
    );
  }

  /// Mendapatkan Locale dari languageCode dan countryCode
  String get localeString => '${languageCode}_$countryCode';
}

