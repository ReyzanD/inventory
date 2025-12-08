import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/inventory_item.dart';

class DashboardCategoryChart extends StatelessWidget {
  final List<InventoryItem> items;

  const DashboardCategoryChart({required this.items});

  @override
  Widget build(BuildContext context) {
    // Group items by category and calculate total value per category
    Map<String, double> categoryValues = {};

    for (final item in items) {
      categoryValues[item.category] =
          (categoryValues[item.category] ?? 0) + item.totalCost;
    }

    // Prepare data for pie chart
    List<PieChartSectionData> sections = [];
    int index = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    categoryValues.forEach((category, value) {
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: value,
          title:
              '${(value / categoryValues.values.fold(0, (a, b) => a + b) * 100).round()}%',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        startDegreeOffset: 0,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle chart touch
          },
        ),
      ),
    );
  }
}
