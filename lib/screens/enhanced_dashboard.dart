import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/enhanced_dashboard_widgets.dart';
import '../widgets/dashboard_chart.dart';
import '../services/analytics_service.dart';
import 'pdf_report_generator.dart';

class EnhancedDashboard extends StatefulWidget {
  const EnhancedDashboard({super.key});

  @override
  _EnhancedDashboardState createState() => _EnhancedDashboardState();
}

class _EnhancedDashboardState extends State<EnhancedDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              // Generate and download PDF report
              final provider = Provider.of<InventoryProvider>(
                context,
                listen: false,
              );
              generatePdfReport(
                inventoryItems: provider.inventoryItems,
                products: provider.products,
              );
            },
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          // Calculate analytics data using service
          final analyticsData = AnalyticsService.calculateDashboardData(
            inventoryItems: provider.inventoryItems,
            products: provider.products,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats Cards
                  EnhancedStatsRow(
                    totalItems: analyticsData['totalInventoryItems'],
                    totalValue: analyticsData['totalInventoryValue'],
                    totalProducts: analyticsData['totalProducts'],
                    lowStockItems: analyticsData['lowStockItems'],
                  ),

                  SizedBox(height: 16),

                  // Charts Row
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Inventory Distribution by Category',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                AspectRatio(
                                  aspectRatio: 1.23,
                                  child: DashboardCategoryChart(
                                    items: provider.inventoryItems,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Inventory Levels',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                AspectRatio(
                                  aspectRatio: 1.5,
                                  child: EnhancedInventoryLevelsChart(
                                    items: provider.inventoryItems,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Low Stock Alert',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                EnhancedLowStockList(
                                  items: provider.inventoryItems,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
