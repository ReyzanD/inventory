import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/service_locator.dart';

/// Provider untuk SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return locator<SettingsService>();
});

/// FutureProvider untuk load initial settings
final initialSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final settingsService = locator<SettingsService>();
  return await settingsService.loadSettings();
});

/// Provider untuk AppSettings state
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  final settingsService = ref.watch(settingsServiceProvider);
  // Start with default settings, will be loaded asynchronously
  return SettingsNotifier(settingsService);
});

/// Notifier untuk mengelola state settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _settingsService;
  bool _isInitialized = false;
  DateTime? _lastUpdateTime;

  SettingsNotifier(this._settingsService) : super(AppSettings()) {
    // Load settings asynchronously after initialization to avoid blocking
    _loadSettings();
  }
  
  /// Helper untuk debounce state updates
  void _updateStateWithDebounce(AppSettings newSettings) {
    final now = DateTime.now();
    // For language changes, update immediately to ensure MaterialApp rebuilds
    final isLanguageChange = newSettings.languageCode != state.languageCode ||
        newSettings.countryCode != state.countryCode;
    
    if (isLanguageChange) {
      // Language changes need immediate update to trigger MaterialApp rebuild
      state = newSettings;
      _lastUpdateTime = now;
    } else if (_lastUpdateTime != null && 
        now.difference(_lastUpdateTime!).inMilliseconds < 100) {
      // Debounce: wait a bit before updating for other changes
      Future.delayed(Duration(milliseconds: 150), () {
        state = newSettings;
        _lastUpdateTime = DateTime.now();
      });
    } else {
      state = newSettings;
      _lastUpdateTime = now;
    }
  }

  /// Memuat settings dari storage
  Future<void> _loadSettings() async {
    if (_isInitialized) return;
    _isInitialized = true; // Set early to prevent multiple loads
    try {
      final settings = await _settingsService.loadSettings();
      // Update state after load completes
      state = settings;
    } catch (e) {
      // If error, keep current state
      // Logging will be handled by SettingsService
    }
  }

  /// Memuat ulang settings
  Future<void> reloadSettings() async {
    await _loadSettings();
  }

  /// Mengupdate language
  Future<bool> updateLanguage(String languageCode, String countryCode) async {
    final newSettings = state.copyWith(
      languageCode: languageCode,
      countryCode: countryCode,
    );
    final success = await _settingsService.saveSettings(newSettings);
    if (success) {
      // Update state with debounce to avoid rapid rebuilds
      _updateStateWithDebounce(newSettings);
    }
    return success;
  }

  /// Mengupdate theme mode
  Future<bool> updateThemeMode(String themeMode) async {
    final newSettings = state.copyWith(themeMode: themeMode);
    final success = await _settingsService.saveSettings(newSettings);
    if (success) {
      state = newSettings;
    }
    return success;
  }

  /// Mengupdate primary color
  Future<bool> updatePrimaryColor(int colorValue) async {
    final newSettings = state.copyWith(primaryColorValue: colorValue);
    final success = await _settingsService.saveSettings(newSettings);
    if (success) {
      state = newSettings;
    }
    return success;
  }

  /// Mengupdate notification settings
  Future<bool> updateNotificationSettings({
    bool? enableLowStock,
    bool? enableExpiry,
    bool? enableTransaction,
  }) async {
    final newSettings = state.copyWith(
      enableLowStockNotifications: enableLowStock,
      enableExpiryNotifications: enableExpiry,
      enableTransactionNotifications: enableTransaction,
    );
    final success = await _settingsService.saveSettings(newSettings);
    if (success) {
      state = newSettings;
    }
    return success;
  }

  /// Mengupdate inventory settings
  Future<bool> updateInventorySettings({
    double? defaultLowStockThreshold,
    int? defaultLowStockItemsThreshold,
  }) async {
    final newSettings = state.copyWith(
      defaultLowStockThreshold: defaultLowStockThreshold,
      defaultLowStockItemsThreshold: defaultLowStockItemsThreshold,
    );
    final success = await _settingsService.saveSettings(newSettings);
    if (success) {
      state = newSettings;
    }
    return success;
  }

  /// Mengupdate display settings
  Future<bool> updateDisplaySettings({
    String? dateFormat,
    String? currencySymbol,
    String? currencyLocale,
  }) async {
    final newSettings = state.copyWith(
      dateFormat: dateFormat,
      currencySymbol: currencySymbol,
      currencyLocale: currencyLocale,
    );
    final success = await _settingsService.saveSettings(newSettings);
    if (success) {
      state = newSettings;
    }
    return success;
  }

  /// Mengupdate other settings
  Future<bool> updateOtherSettings({
    bool? enableAutoBackup,
    int? autoBackupIntervalDays,
    bool? enableSoundEffects,
    bool? enableHapticFeedback,
  }) async {
    final newSettings = state.copyWith(
      enableAutoBackup: enableAutoBackup,
      autoBackupIntervalDays: autoBackupIntervalDays,
      enableSoundEffects: enableSoundEffects,
      enableHapticFeedback: enableHapticFeedback,
    );
    final success = await _settingsService.saveSettings(newSettings);
    if (success) {
      state = newSettings;
    }
    return success;
  }

  /// Menyimpan semua settings sekaligus
  Future<bool> saveAllSettings(AppSettings settings) async {
    final success = await _settingsService.saveSettings(settings);
    if (success) {
      // Check if language changed - if so, update immediately without debounce
      final isLanguageChange = settings.languageCode != state.languageCode ||
          settings.countryCode != state.countryCode;
      
      if (isLanguageChange) {
        // Language changes need immediate update to trigger MaterialApp rebuild
        state = settings;
      } else {
        // Other changes can use debounce
        _updateStateWithDebounce(settings);
      }
    }
    return success;
  }

  /// Reset settings ke default
  Future<bool> resetSettings() async {
    final success = await _settingsService.resetSettings();
    if (success) {
      state = AppSettings();
    }
    return success;
  }
}
