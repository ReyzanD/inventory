import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'providers/inventory_provider.dart';
import 'providers/riverpod_inventory_provider.dart';
import 'screens/main_dashboard_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'themes/app_theme.dart';
import 'services/logging_service.dart';
import 'services/service_locator.dart';
import 'services/connectivity_service.dart';

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

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Riverpod inventory provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep Provider for backward compatibility during migration
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(
          create: (context) => locator<InventoryProvider>()..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Inventory Management System',
        theme: InventoryTheme.theme,
        home: DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
