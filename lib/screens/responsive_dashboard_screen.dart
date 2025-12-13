import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'product_screen.dart';
import 'pos_screen.dart';
import 'dashboard_screen.dart';
import 'notification_screen.dart';
import 'barcode_scanner_screen.dart';
import 'transaction_history_screen.dart';
import 'settings_screen.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/side_menu_bar.dart';
import '../widgets/breadcrumb.dart';
import '../l10n/app_localizations.dart';

class ResponsiveDashboardScreen extends StatefulWidget {
  @override
  _ResponsiveDashboardScreenState createState() =>
      _ResponsiveDashboardScreenState();
}

class _ResponsiveDashboardScreenState extends State<ResponsiveDashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<Widget> _screens = [
    AnalyticsDashboard(),
    InventoryScreen(),
    ProductScreen(),
    POSScreen(),
    BarcodeScannerScreen(),
    TransactionHistoryScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];

  List<String> _getScreenTitles(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return [
      localizations!.dashboard,
      localizations.inventory,
      localizations.products,
      localizations.pos,
      localizations.scanItem,
      localizations.transactionHistory,
      localizations.notifications,
      localizations.settings,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenTitles = _getScreenTitles(context);
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(screenTitles),
        tablet: _buildTabletLayout(screenTitles),
        desktop: _buildDesktopLayout(screenTitles),
      ),
    );
  }

  Widget _buildMobileLayout(List<String> screenTitles) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedIndex == 7)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // Settings screen will handle its own save
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: SideMenuBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pop(context);
          },
          isCollapsed: true,
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildTabletLayout(List<String> screenTitles) {
    final localizations = AppLocalizations.of(context);
    return Row(
      children: [
        SideMenuBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        Expanded(
          child: Column(
            children: [
              Breadcrumb(
                items: [
                  BreadcrumbItem(title: localizations!.home),
                  BreadcrumbItem(title: screenTitles[_selectedIndex]),
                ],
              ),
              Expanded(child: _screens[_selectedIndex]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(List<String> screenTitles) {
    final localizations = AppLocalizations.of(context);
    return Row(
      children: [
        SideMenuBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          isCollapsed: _isSidebarCollapsed,
        ),
        Expanded(
          child: Column(
            children: [
              Breadcrumb(
                items: [
                  BreadcrumbItem(title: localizations!.home),
                  BreadcrumbItem(title: screenTitles[_selectedIndex]),
                ],
              ),
              Expanded(child: _screens[_selectedIndex]),
            ],
          ),
        ),
      ],
    );
  }
}
