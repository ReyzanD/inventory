import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/inventory_provider.dart';
import 'providers/riverpod_inventory_provider.dart';
import 'providers/settings_provider.dart';
import 'models/app_settings.dart';
import 'screens/main_dashboard_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'themes/app_theme.dart';
import 'services/logging_service.dart';
import 'services/service_locator.dart';
import 'services/connectivity_service.dart';
import 'services/settings_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging service
  LoggingService.init();

  // Initialize dependency injection
  setupDependencies();

  // Initialize connectivity service with error handling
  try {
    final connectivityService = locator<ConnectivityService>();
    await connectivityService.initialize();
    LoggingService.info('Connectivity service initialized successfully');
  } catch (e) {
    // If connectivity service fails to initialize, app can still run
    // The service will default to online mode
    LoggingService.warning('Connectivity service initialization failed: $e');
    LoggingService.info(
      'App will continue with default connectivity status (online)',
    );
  }

  // Initialize sqflite for desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Log database path for debugging
  String databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'InventoryManagement.db');
  LoggingService.info('DATABASE INFO - Databases path: $databasesPath');
  LoggingService.info('DATABASE INFO - Full database path: $path');

  // Pre-load settings to avoid accessibility bridge errors
  try {
    final settingsService = locator<SettingsService>();
    await settingsService.loadSettings();
    LoggingService.info('Settings pre-loaded successfully');
  } catch (e) {
    LoggingService.warning('Settings pre-load failed: $e');
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Use GlobalKey to maintain MaterialApp state across rebuilds
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey? _materialAppKey;
  Locale? _previousLocale;

  @override
  void initState() {
    super.initState();
    // Initialize material app key
    _materialAppKey = GlobalKey();
    // Initialize previous locale from current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(inventoryProvider.notifier).init();
        // Initialize previous locale
        final currentSettings = ref.read(settingsProvider);
        _previousLocale = _getLocale(currentSettings);
      }
    });
  }

  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Locale _getLocale(AppSettings settings) {
    return Locale(settings.languageCode, settings.countryCode);
  }

  @override
  Widget build(BuildContext context) {
    // Watch settingsProvider directly for reactivity
    // This will automatically rebuild when settings change
    final settings = ref.watch(settingsProvider);
    final locale = _getLocale(settings);
    final themeMode = _getThemeMode(settings.themeMode);

    // Track locale changes - if locale changed, we need to rebuild MaterialApp
    final localeChanged = _previousLocale != locale;
    if (localeChanged) {
      LoggingService.info('Locale changed from $_previousLocale to $locale');
      _previousLocale = locale;
      // Create new key when locale changes to force complete rebuild
      _materialAppKey = GlobalKey();
      LoggingService.info('MaterialApp key recreated for locale change');
    }

    // Keep Provider for backward compatibility during migration
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(
          create: (context) => locator<InventoryProvider>()..init(),
        ),
      ],
      child: MaterialApp(
        key: _materialAppKey,
        navigatorKey: _navigatorKey,
        title: 'Inventory Management System',
        theme: InventoryTheme.theme,
        darkTheme: InventoryTheme.darkTheme,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('id', 'ID'), Locale('en', 'US')],
        home: DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
