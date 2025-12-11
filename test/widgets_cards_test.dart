import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inventory/widgets/inventory_item_card.dart';
import 'package:inventory/widgets/product_card.dart';

void main() {
  testWidgets('InventoryItemCard displays quantity and prices plainly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryItemCard(
            name: 'Sugar',
            description: 'White sugar',
            quantity: 12.5,
            unit: 'kg',
            costPerUnit: 10,
            sellingPricePerUnit: 12,
            category: 'Food',
            dateAdded: DateTime(2024, 1, 1),
            onEdit: _noop,
            onDelete: _noop,
          ),
        ),
      ),
    );

    expect(find.textContaining('12.50 kg'), findsOneWidget);
    expect(find.textContaining('Cost'), findsOneWidget);
    expect(find.textContaining('Sell'), findsOneWidget);
  });

  testWidgets('ProductCard shows selling price and component count', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            name: 'Lemonade',
            sellingPrice: 20,
            cogs: 12,
            profit: 8,
            componentsCount: 2,
            category: 'Drinks',
            componentsList: const ['Water', 'Lemon'],
            onEdit: _noop,
            onDelete: _noop,
            onExpansionChanged: _noop,
          ),
        ),
      ),
    );

    expect(find.text('Lemonade'), findsOneWidget);
    expect(find.textContaining('components'), findsOneWidget);
    expect(
      find.textContaining('20'),
      findsWidgets,
    ); // selling price rendered with currency
  });
}

void _noop() {}
