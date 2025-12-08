import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../models/inventory_item.dart';
import '../widgets/currency_widgets.dart';

class AnalyticsDashboard extends StatefulWidget {
  @override
  _AnalyticsDashboardState createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          // Calculate analytics data
          final totalInventoryValue = provider.inventoryItems.fold(0.0, (sum, item) => sum + item.totalCost);
          final totalSellingPrice = provider.inventoryItems.fold(0.0, (sum, item) => sum + (item.quantity * item.sellingPricePerUnit));
          final totalProducts = provider.products.length;
          final totalInventoryItems = provider.inventoryItems.length;
          final lowStockItems = provider.inventoryItems.where((item) => item.quantity < 10).length;
          
          // Calculate today's transactions (this would need to be implemented with actual transaction data)
          // For now, we'll just show placeholder values
          
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  _buildStatsRow(
                    inventoryItems: totalInventoryItems,
                    products: totalProducts,
                    totalValue: totalInventoryValue,
                    lowStockItems: lowStockItems,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Inventory Status Card
                  _buildCard(
                    title: 'Inventory Status',
                    child: Column(
                      children: [
                        _buildInventoryStatusItem(
                          icon: Icons.inventory,
                          title: 'Total Items',
                          value: totalInventoryItems.toString(),
                          color: Colors.blue,
                        ),
                        Divider(),
                        _buildInventoryStatusItem(
                          icon: Icons.production_quantity_limits,
                          title: 'Total Products',
                          value: totalProducts,
                          color: Colors.green,
                        ),
                        Divider(),
                        _buildInventoryStatusItem(
                          icon: Icons.warning,
                          title: 'Low Stock Items',
                          value: lowStockItems,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Financial Summary Card
                  _buildCard(
                    title: 'Financial Summary',
                    child: Column(
                      children: [
                        _buildFinancialSummaryItem(
                          title: 'Total Inventory Cost',
                          value: totalInventoryValue,
                          color: Colors.blue,
                        ),
                        Divider(),
                        _buildFinancialSummaryItem(
                          title: 'Potential Revenue',
                          value: totalSellingPrice,
                          color: Colors.green,
                        ),
                        Divider(),
                        _buildFinancialSummaryItem(
                          title: 'Potential Profit',
                          value: (totalSellingPrice - totalInventoryValue),
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Top Inventory Items Card
                  _buildCard(
                    title: 'Top Inventory Items',
                    child: _buildTopInventoryItems(provider.inventoryItems),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Top Products Card
                  _buildCard(
                    title: 'Top Products',
                    child: _buildTopProducts(provider.products, provider.inventoryItems),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow({
    required int inventoryItems,
    required int products,
    required double totalValue,
    required int lowStockItems,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Inventory Items',
            value: inventoryItems,
            icon: Icons.inventory,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Products',
            value: products,
            icon: Icons.production_quantity_limits,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Value',
            value: totalValue,
            icon: Icons.attach_money,
            color: Colors.purple,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Low Stock',
            value: lowStockItems,
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required dynamic value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (value is double || value is int)
              RupiahText(
                amount: value.toDouble(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStatusItem({
    required IconData icon,
    required String title,
    required dynamic value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
          if (value is double || value is int)
            RupiahText(
              amount: value.toDouble(),
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          else
            Text(
              value.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryItem({
    required String title,
    required dynamic value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
          if (value is double || value is int)
            RupiahText(
              amount: value.toDouble(),
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          else
            Text(
              value.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildTopInventoryItems(List<InventoryItem> items) {
    // Sort by quantity in descending order
    final sortedItems = [...items]..sort((a, b) => b.quantity.compareTo(a.quantity));
    
    return Column(
      children: sortedItems.take(5).map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item.name,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(
                  '${item.quantity.toStringAsFixed(2)} ${item.unit}',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  '\$${item.totalCost.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopProducts(List<Product> products, List<InventoryItem> inventoryItems) {
    // Just show top 5 products
    return Column(
      children: products.take(5).map((product) {
        final cogs = _calculateProductCogs(product, inventoryItems);
        final profit = product.sellingPrice - cogs;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(
                  '\$${product.sellingPrice.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  '\$${profit.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: profit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // Helper function to calculate COGS for a product based on inventory
  double _calculateProductCogs(Product product, List<InventoryItem> items) {
    double totalCogs = 0.0;

    // Create a map of inventory items for quick lookup
    Map<String, InventoryItem> inventoryMap = {};
    for (final item in items) {
      inventoryMap[item.id] = item;
    }

    for (final component in product.components) {
      final inventoryItem = inventoryMap[component.inventoryItemId];
      if (inventoryItem != null) {
        // Need to handle unit conversions here
        double conversionFactor = _getConversionFactor(inventoryItem.unit, component.unit);
        double costForThisComponent = (component.quantityNeeded / conversionFactor) * inventoryItem.costPerUnit;
        totalCogs += costForThisComponent;
      }
    }

    return totalCogs;
  }

  // Simple conversion factor - could be expanded to handle more complex conversions
  double _getConversionFactor(String inventoryUnit, String componentUnit) {
    // Standard conversions
    if (inventoryUnit == 'kg' && componentUnit == 'g') return 1000.0; // 1kg = 1000g
    if (inventoryUnit == 'g' && componentUnit == 'kg') return 0.001; // 1g = 0.001kg
    if (inventoryUnit == 'kg' && componentUnit == 'mg') return 1000000.0; // 1kg = 1000000mg
    if (inventoryUnit == 'g' && componentUnit == 'mg') return 1000.0; // 1g = 1000mg
    if (inventoryUnit == 'L' && componentUnit == 'ml') return 1000.0; // 1L = 1000ml
    if (inventoryUnit == 'ml' && componentUnit == 'L') return 0.001; // 1ml = 0.001L

    // Same units
    if (inventoryUnit == componentUnit) return 1.0;

    // Default: assume same units if not specified
    return 1.0;
  }
}