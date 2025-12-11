import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../widgets/currency_widgets.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final IconData icon;
  final Color color;
  final bool isCurrency;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (value is double || value is int)
              isCurrency
                  ? RupiahText(
                      amount: value.toDouble(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
            else
              Text(
                value.toString(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}

class DashboardStatsRow extends StatelessWidget {
  final int inventoryItems;
  final int products;
  final double totalValue;
  final int lowStockItems;

  const DashboardStatsRow({
    super.key,
    required this.inventoryItems,
    required this.products,
    required this.totalValue,
    required this.lowStockItems,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 720;

    final cards = [
      DashboardStatCard(
        title: 'Inventory Items',
        value: inventoryItems,
        icon: Icons.inventory,
        color: Colors.blue,
      ),
      DashboardStatCard(
        title: 'Products',
        value: products,
        icon: Icons.production_quantity_limits,
        color: Colors.green,
      ),
      DashboardStatCard(
        title: 'Total Value',
        value: totalValue,
        icon: Icons.attach_money,
        color: Colors.purple,
        isCurrency: true,
      ),
      DashboardStatCard(
        title: 'Low Stock',
        value: lowStockItems,
        icon: Icons.warning,
        color: Colors.orange,
      ),
    ];

    if (isNarrow) {
      return Column(
        children: [
          ...cards.map(
            (c) =>
                Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        SizedBox(width: 12),
        Expanded(child: cards[1]),
        SizedBox(width: 12),
        Expanded(child: cards[2]),
        SizedBox(width: 12),
        Expanded(child: cards[3]),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class DashboardInventoryStatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final dynamic value;
  final Color color;

  const DashboardInventoryStatusItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          if (value is double || value is int)
            RupiahText(
              amount: value.toDouble(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            )
          else
            Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
        ],
      ),
    );
  }
}

class DashboardFinancialSummaryItem extends StatelessWidget {
  final String title;
  final dynamic value;
  final Color color;

  const DashboardFinancialSummaryItem({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          if (value is double || value is int)
            RupiahText(
              amount: value.toDouble(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            )
          else
            Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
        ],
      ),
    );
  }
}

class DashboardTopInventoryItems extends StatelessWidget {
  final List<InventoryItem> items;

  const DashboardTopInventoryItems({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Sort by quantity in descending order
    final sortedItems = [...items]
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

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
}

class DashboardTopProducts extends StatelessWidget {
  final List<Product> products;
  final List<InventoryItem> inventoryItems;

  const DashboardTopProducts({
    super.key,
    required this.products,
    required this.inventoryItems,
  });

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
        double conversionFactor = _getConversionFactor(
          inventoryItem.unit,
          component.unit,
        );
        double costForThisComponent =
            (component.quantityNeeded / conversionFactor) *
            inventoryItem.costPerUnit;
        totalCogs += costForThisComponent;
      }
    }

    return totalCogs;
  }

  // Simple conversion factor - could be expanded to handle more complex conversions
  double _getConversionFactor(String inventoryUnit, String componentUnit) {
    // Standard conversions
    if (inventoryUnit == 'kg' && componentUnit == 'g')
      return 1000.0; // 1kg = 1000g
    if (inventoryUnit == 'g' && componentUnit == 'kg')
      return 0.001; // 1g = 0.001kg
    if (inventoryUnit == 'kg' && componentUnit == 'mg')
      return 1000000.0; // 1kg = 1000000mg
    if (inventoryUnit == 'g' && componentUnit == 'mg')
      return 1000.0; // 1g = 1000mg
    if (inventoryUnit == 'L' && componentUnit == 'ml')
      return 1000.0; // 1L = 1000ml
    if (inventoryUnit == 'ml' && componentUnit == 'L')
      return 0.001; // 1ml = 0.001L

    // Same units
    if (inventoryUnit == componentUnit) return 1.0;

    // Default: assume same units if not specified
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
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
}
