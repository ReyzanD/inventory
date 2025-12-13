import 'package:get_it/get_it.dart';
import '../services/inventory_service.dart';
import '../services/audit_service.dart';
import '../services/logging_service.dart';
import '../services/connectivity_service.dart';
import '../services/settings_service.dart';
import '../providers/inventory_provider.dart';

// Service locator instance
GetIt locator = GetIt.instance;

// Register all dependencies
void setupDependencies() {
  // Services
  locator.registerSingleton<InventoryService>(InventoryService());
  locator.registerSingleton<AuditService>(AuditService());
  locator.registerSingleton<LoggingService>(LoggingService());
  // Don't call initialize() here - it will be called in main.dart
  // This prevents double initialization and allows proper error handling
  locator.registerSingleton<ConnectivityService>(ConnectivityService());
  locator.registerSingleton<SettingsService>(SettingsService());

  // Providers
  locator.registerFactory<InventoryProvider>(() => InventoryProvider());
}
