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

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 720;

    // If there is no data or the total is zero, show a friendly placeholder
    if (categoryValues.isEmpty ||
        categoryValues.values.fold<double>(0, (a, b) => a + b) <= 0) {
      return Center(
        child: Text(
          'No data available for chart',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
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

    // Calculate total once to avoid division by zero and NaN values
    final double total = categoryValues.values.fold<double>(0, (a, b) => a + b);

    categoryValues.forEach((category, value) {
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: value,
          title: '${((value / total) * 100).round()}%',
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

    return Padding(
      padding: EdgeInsets.all(isNarrow ? 8 : 0),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: isNarrow ? 32 : 40,
          sectionsSpace: 2,
          startDegreeOffset: 0,
          pieTouchData: PieTouchData(
            enabled:
                false, // Disable touch interactions to prevent mouse tracker errors
          ),
        ),
      ),
    );
  }
}
