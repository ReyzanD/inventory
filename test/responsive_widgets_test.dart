import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inventory/widgets/dashboard_widgets.dart';

void main() {
  group('DashboardStatsRow responsiveness', () {
    testWidgets('stacks cards on narrow screens', (tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue = const Size(600, 800);
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardStatsRow(
              inventoryItems: 10,
              products: 5,
              totalValue: 1000,
              lowStockItems: 2,
            ),
          ),
        ),
      );

      expect(find.byType(DashboardStatCard), findsNWidgets(4));
      // On narrow screens, the widget should be a Column (not a Row) at the top level
      // Look specifically for the Column that has Padding widgets as direct children
      // This identifies the main Column layout vs internal Columns in cards
      expect(find.byType(Column), findsWidgets); // Finds multiple columns (internal + main)

      // Find the Column that contains Padding widgets (the main layout for narrow screens)
      final mainNarrowLayoutColumn = find.ancestor(
        of: find.byType(Padding).first,
        matching: find.byType(Column),
      );

      expect(mainNarrowLayoutColumn, findsOneWidget);
    });

    testWidgets('lays out in a row on wide screens', (tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardStatsRow(
              inventoryItems: 10,
              products: 5,
              totalValue: 1000,
              lowStockItems: 2,
            ),
          ),
        ),
      );

      expect(find.byType(DashboardStatCard), findsNWidgets(4));
      // On wide screens, the main layout should be a Row containing Expanded widgets
      // Look specifically for the Row that has Expanded widgets as direct children
      final mainWideLayoutRow = find.ancestor(
        of: find.byType(Expanded).first,
        matching: find.byType(Row),
      );

      expect(mainWideLayoutRow, findsOneWidget);
    });
  });
}
