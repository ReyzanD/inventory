import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'product_screen.dart';
import 'pos_screen.dart';
import 'dashboard_screen.dart';
import 'notification_screen.dart';
import 'barcode_scanner_screen.dart';
import 'transaction_history_screen.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/side_menu_bar.dart';
import '../widgets/breadcrumb.dart';

class ResponsiveDashboardScreen extends StatefulWidget {
  @override
  _ResponsiveDashboardScreenState createState() => _ResponsiveDashboardScreenState();
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
  ];

  final List<String> _screenTitles = [
    'Dashboard',
    'Inventory',
    'Products',
    'POS',
    'Scan Item',
    'Transaction History',
    'Notifications',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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

  Widget _buildTabletLayout() {
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
                  BreadcrumbItem(title: 'Home'),
                  BreadcrumbItem(title: _screenTitles[_selectedIndex]),
                ],
              ),
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
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
                  BreadcrumbItem(title: 'Home'),
                  BreadcrumbItem(title: _screenTitles[_selectedIndex]),
                ],
              ),
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          ),
        ),
      ],
    );
  }
}