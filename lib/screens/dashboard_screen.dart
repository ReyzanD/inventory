import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_chart.dart';
import '../services/analytics_service.dart';
import 'pdf_report_generator.dart';

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

        return Scaffold(
          appBar: AppBar(
            title: Text('Dashboard'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
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
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
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

                  SizedBox(height: 24),

                  // Inventory Distribution Chart
                  DashboardCard(
                    title: 'Inventory Distribution by Category',
                    child: Container(
                      height: 250,
                      child: DashboardCategoryChart(
                        items: provider.inventoryItems,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Inventory Status Card
                  DashboardCard(
                    title: 'Inventory Status',
                    child: Column(
                      children: [
                        DashboardInventoryStatusItem(
                          icon: Icons.inventory,
                          title: 'Total Items',
                          value: analyticsData['totalInventoryItems']
                              .toString(),
                          color: Colors.blue,
                        ),
                        Divider(),
                        DashboardInventoryStatusItem(
                          icon: Icons.production_quantity_limits,
                          title: 'Total Products',
                          value: analyticsData['totalProducts'].toString(),
                          color: Colors.green,
                        ),
                        Divider(),
                        DashboardInventoryStatusItem(
                          icon: Icons.warning,
                          title: 'Low Stock Items',
                          value: analyticsData['lowStockItems'].toString(),
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Financial Summary Card
                  DashboardCard(
                    title: 'Financial Summary',
                    child: Column(
                      children: [
                        DashboardFinancialSummaryItem(
                          title: 'Total Inventory Cost',
                          value: analyticsData['totalInventoryValue'],
                          color: Colors.blue,
                        ),
                        Divider(),
                        DashboardFinancialSummaryItem(
                          title: 'Potential Revenue',
                          value: analyticsData['totalSellingPrice'],
                          color: Colors.green,
                        ),
                        Divider(),
                        DashboardFinancialSummaryItem(
                          title: 'Potential Profit',
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
                    title: 'Top Inventory Items',
                    child: DashboardTopInventoryItems(
                      items: provider.inventoryItems,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Top Products Card
                  DashboardCard(
                    title: 'Top Products',
                    child: DashboardTopProducts(
                      products: provider.products,
                      inventoryItems: provider.inventoryItems,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
