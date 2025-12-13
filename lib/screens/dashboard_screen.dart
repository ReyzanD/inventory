import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_chart.dart';
import '../services/analytics_service.dart';
import 'pdf_report_generator.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

class AnalyticsDashboard extends StatefulWidget {
  @override
  _AnalyticsDashboardState createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        // Calculate analytics data using service
        final analyticsData = AnalyticsService.calculateDashboardData(
          inventoryItems: provider.inventoryItems,
          products: provider.products,
        );

        final localizations = AppLocalizations.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ]
                      : [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.9),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: AppBar(
                title: Text(localizations!.dashboard),
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                    tooltip: localizations.settings,
                  ),
                  IconButton(
                    icon: Icon(Icons.picture_as_pdf),
                    onPressed: () {
                      // Generate and download PDF report
                      generatePdfReport(
                        inventoryItems: provider.inventoryItems,
                        products: provider.products,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withOpacity(0.95),
                      ],
                    ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    DashboardStatsRow(
                      inventoryItems: analyticsData['totalInventoryItems'],
                      products: analyticsData['totalProducts'],
                      totalValue: analyticsData['totalInventoryValue'],
                      lowStockItems: analyticsData['lowStockItems'],
                    ),

                    SizedBox(height: 8),

                    // Inventory Distribution Chart
                    DashboardCard(
                      title: localizations.inventoryDistributionByCategory,
                      accentColor: Colors.blue,
                      child: SizedBox(
                        height: 250,
                        child: DashboardCategoryChart(
                          items: provider.inventoryItems,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Inventory Status Card
                    DashboardCard(
                      title: localizations.inventoryStatus,
                      accentColor: Colors.green,
                      child: Column(
                        children: [
                          DashboardInventoryStatusItem(
                            icon: Icons.inventory,
                            title: localizations.totalItems,
                            value: analyticsData['totalInventoryItems']
                                .toString(),
                            color: Colors.blue,
                          ),
                          Divider(),
                          DashboardInventoryStatusItem(
                            icon: Icons.production_quantity_limits,
                            title: localizations.totalProducts,
                            value: analyticsData['totalProducts'].toString(),
                            color: Colors.green,
                          ),
                          Divider(),
                          DashboardInventoryStatusItem(
                            icon: Icons.warning,
                            title: localizations.lowStockItems,
                            value: analyticsData['lowStockItems'].toString(),
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Financial Summary Card
                    DashboardCard(
                      title: localizations.financialSummary,
                      accentColor: Colors.purple,
                      child: Column(
                        children: [
                          DashboardFinancialSummaryItem(
                            title: localizations.totalInventoryCost,
                            value: analyticsData['totalInventoryValue'],
                            color: Colors.blue,
                          ),
                          Divider(),
                          DashboardFinancialSummaryItem(
                            title: localizations.potentialRevenue,
                            value: analyticsData['totalSellingPrice'],
                            color: Colors.green,
                          ),
                          Divider(),
                          DashboardFinancialSummaryItem(
                            title: localizations.potentialProfit,
                            value:
                                (analyticsData['totalSellingPrice'] -
                                analyticsData['totalInventoryValue']),
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Top Inventory Items Card
                    DashboardCard(
                      title: localizations.topInventoryItems,
                      accentColor: Colors.orange,
                      child: DashboardTopInventoryItems(
                        items: provider.inventoryItems,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Top Products Card
                    DashboardCard(
                      title: localizations.topProducts,
                      accentColor: Colors.teal,
                      child: DashboardTopProducts(
                        products: provider.products,
                        inventoryItems: provider.inventoryItems,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
