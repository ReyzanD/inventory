import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/models/inventory_item.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/utils/filter_helper.dart';

void main() {
  group('FilterHelper', () {
    final testItems = [
      InventoryItem(
        id: '1',
        name: 'Apple',
        description: 'Red apple',
        quantity: 10.0,
        unit: 'kg',
        costPerUnit: 5.0,
        sellingPricePerUnit: 8.0,
        dateAdded: DateTime(2024, 1, 1),
        category: 'Fruits',
      ),
      InventoryItem(
        id: '2',
        name: 'Banana',
        description: 'Yellow banana',
        quantity: 5.0,
        unit: 'kg',
        costPerUnit: 3.0,
        sellingPricePerUnit: 6.0,
        dateAdded: DateTime(2024, 1, 15),
        category: 'Fruits',
      ),
      InventoryItem(
        id: '3',
        name: 'Milk',
        description: 'Fresh milk',
        quantity: 20.0,
        unit: 'L',
        costPerUnit: 2.0,
        sellingPricePerUnit: 4.0,
        dateAdded: DateTime(2024, 2, 1),
        category: 'Dairy',
      ),
    ];

    final testProducts = [
      Product(
        id: '1',
        name: 'Apple Juice',
        description: 'Fresh apple juice',
        sellingPrice: 10.0,
        components: [],
        dateCreated: DateTime(2024, 1, 1),
        category: 'Beverages',
      ),
      Product(
        id: '2',
        name: 'Banana Smoothie',
        description: 'Creamy banana smoothie',
        sellingPrice: 12.0,
        components: [],
        dateCreated: DateTime(2024, 1, 15),
        category: 'Beverages',
      ),
    ];

    group('applyInventoryFilters', () {
      test('filters by search query', () {
        final filtered = FilterHelper.applyInventoryFilters(
          items: testItems,
          searchQuery: 'Apple',
        );
        expect(filtered.length, 1);
        expect(filtered.first.name, 'Apple');
      });

      test('filters by category', () {
        final filtered = FilterHelper.applyInventoryFilters(
          items: testItems,
          category: 'Fruits',
        );
        expect(filtered.length, 2);
        expect(filtered.every((item) => item.category == 'Fruits'), true);
      });

      test('filters by stock range', () {
        final filtered = FilterHelper.applyInventoryFilters(
          items: testItems,
          minStock: 8.0,
          maxStock: 12.0,
        );
        expect(filtered.length, 1);
        expect(filtered.first.name, 'Apple'); // Apple has quantity 10.0
      });

      test('filters by date range', () {
        final filtered = FilterHelper.applyInventoryFilters(
          items: testItems,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
        );
        expect(filtered.length, 2); // Apple (Jan 1) and Banana (Jan 15)
      });

      test('applies multiple filters', () {
        final filtered = FilterHelper.applyInventoryFilters(
          items: testItems,
          searchQuery: 'a',
          category: 'Fruits',
          minStock: 5.0,
          maxStock: 15.0,
        );
        expect(filtered.length, 2); // Apple and Banana both match
      });

      test('returns all items when no filters applied', () {
        final filtered = FilterHelper.applyInventoryFilters(
          items: testItems,
        );
        expect(filtered.length, 3);
      });
    });

    group('applyProductFilters', () {
      test('filters by search query', () {
        final filtered = FilterHelper.applyProductFilters(
          products: testProducts,
          searchQuery: 'Apple',
        );
        expect(filtered.length, 1);
        expect(filtered.first.name, 'Apple Juice');
      });

      test('filters by category', () {
        final filtered = FilterHelper.applyProductFilters(
          products: testProducts,
          category: 'Beverages',
        );
        expect(filtered.length, 2);
      });

      test('returns all products when no filters applied', () {
        final filtered = FilterHelper.applyProductFilters(
          products: testProducts,
        );
        expect(filtered.length, 2);
      });
    });
  });
}

