import 'package:flutter/material.dart';
import 'package:inventory/constants.dart';
import 'package:provider/provider.dart';
import 'providers/inventory_provider.dart';
import 'screens/main_dashboard_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Print database path for debugging
  String databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'InventoryManagement.db');
  print('=== DATABASE DEBUG INFO ===');
  print('Databases path: $databasesPath');
  print('Full database path: $path');
  print('===========================');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => InventoryProvider()..init(),
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
