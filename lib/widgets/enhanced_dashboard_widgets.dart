import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/inventory_item.dart';

class EnhancedStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? backgroundColor;
  final Color? textColor;

  const EnhancedStatsCard({
    required this.title,
    required this.value,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnhancedStatsRow extends StatelessWidget {
  final int totalItems;
  final double totalValue;
  final int totalProducts;
  final int lowStockItems;

  const EnhancedStatsRow({
    required this.totalItems,
    required this.totalValue,
    required this.totalProducts,
    required this.lowStockItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EnhancedStatsCard(
            title: 'Total Items',
            value: totalItems.toString(),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: EnhancedStatsCard(
            title: 'Total Value',
            value: 'Rp${totalValue.toStringAsFixed(0)}',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: EnhancedStatsCard(
            title: 'Total Products',
            value: totalProducts.toString(),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: EnhancedStatsCard(
            title: 'Low Stock',
            value: lowStockItems.toString(),
            backgroundColor: lowStockItems > 0 ? Colors.red[50] : null,
            textColor: lowStockItems > 0 ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}

class EnhancedInventoryLevelsChart extends StatelessWidget {
  final List<InventoryItem> items;

  const EnhancedInventoryLevelsChart({required this.items});

  @override
  Widget build(BuildContext context) {
    // Take top 10 items with highest quantity for bar chart
    final sortedItems = [...items]
      ..sort((a, b) => b.quantity.compareTo(a.quantity))
      ..removeRange(10, items.length > 10 ? items.length - 10 : 0);

    List<BarChartGroupData> groups = [];
    List<String> xAxisLabels = [];

    for (int i = 0; i < sortedItems.length; i++) {
      final item = sortedItems[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.quantity,
              color: _getQuantityColor(item.quantity),
              width: 10,
            ),
          ],
        ),
      );
      xAxisLabels.add(item.name);
    }

    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < xAxisLabels.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        xAxisLabels[index],
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
        maxY: sortedItems.isNotEmpty ? (sortedItems.first.quantity * 1.2) : 10,
      ),
    );
  }

  Color _getQuantityColor(double quantity) {
    if (quantity < 10) return Colors.red;
    if (quantity < 50) return Colors.orange;
    return Colors.green;
  }
}

class EnhancedLowStockList extends StatelessWidget {
  final List<InventoryItem> items;

  const EnhancedLowStockList({required this.items});

  @override
  Widget build(BuildContext context) {
    final lowStockItems = items.where((item) => item.quantity < 10).toList();

    if (lowStockItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 40, color: Colors.green),
            SizedBox(height: 8),
            Text(
              'All items in good stock!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: lowStockItems.length > 5 ? 5 : lowStockItems.length,
        itemBuilder: (context, index) {
          final item = lowStockItems[index];
          return ListTile(
            dense: true,
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text(
              item.name,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${item.quantity.toStringAsFixed(2)} ${item.unit}',
              style: TextStyle(fontSize: 10),
            ),
            trailing: Text(
              '< 10',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          );
        },
      ),
    );
  }
}
