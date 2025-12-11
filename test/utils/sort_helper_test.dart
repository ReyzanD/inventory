import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/models/inventory_item.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/utils/sort_helper.dart';

void main() {
  group('SortHelper', () {
    final testItems = [
      InventoryItem(
        id: '1',
        name: 'Zebra',
        description: 'Zebra item',
        quantity: 5.0,
        unit: 'kg',
        costPerUnit: 10.0,
        sellingPricePerUnit: 15.0,
        dateAdded: DateTime(2024, 1, 1),
        category: 'A',
      ),
      InventoryItem(
        id: '2',
        name: 'Apple',
        description: 'Apple item',
        quantity: 10.0,
        unit: 'kg',
        costPerUnit: 5.0,
        sellingPricePerUnit: 8.0,
        dateAdded: DateTime(2024, 1, 15),
        category: 'B',
      ),
      InventoryItem(
        id: '3',
        name: 'Banana',
        description: 'Banana item',
        quantity: 15.0,
        unit: 'kg',
        costPerUnit: 3.0,
        sellingPricePerUnit: 6.0,
        dateAdded: DateTime(2024, 2, 1),
        category: 'C',
      ),
    ];

    final testProducts = [
      Product(
        id: '1',
        name: 'Zebra Product',
        description: 'Zebra product',
        sellingPrice: 20.0,
        components: [],
        dateCreated: DateTime(2024, 1, 1),
        category: 'A',
      ),
      Product(
        id: '2',
        name: 'Apple Product',
        description: 'Apple product',
        sellingPrice: 10.0,
        components: [],
        dateCreated: DateTime(2024, 1, 15),
        category: 'B',
      ),
      Product(
        id: '3',
        name: 'Banana Product',
        description: 'Banana product',
        sellingPrice: 15.0,
        components: [],
        dateCreated: DateTime(2024, 2, 1),
        category: 'C',
      ),
    ];

    group('sortInventoryItems', () {
      test('sorts by Name A-Z', () {
        final sorted = SortHelper.sortInventoryItems(testItems, 'Name A-Z');
        expect(sorted[0].name, 'Apple');
        expect(sorted[1].name, 'Banana');
        expect(sorted[2].name, 'Zebra');
      });

      test('sorts by Name Z-A', () {
        final sorted = SortHelper.sortInventoryItems(testItems, 'Name Z-A');
        expect(sorted[0].name, 'Zebra');
        expect(sorted[1].name, 'Banana');
        expect(sorted[2].name, 'Apple');
      });

      test('sorts by Quantity High-Low', () {
        final sorted = SortHelper.sortInventoryItems(testItems, 'Quantity High-Low');
        expect(sorted[0].quantity, 15.0);
        expect(sorted[1].quantity, 10.0);
        expect(sorted[2].quantity, 5.0);
      });

      test('sorts by Quantity Low-High', () {
        final sorted = SortHelper.sortInventoryItems(testItems, 'Quantity Low-High');
        expect(sorted[0].quantity, 5.0);
        expect(sorted[1].quantity, 10.0);
        expect(sorted[2].quantity, 15.0);
      });

      test('sorts by Date Added (Newest)', () {
        final sorted = SortHelper.sortInventoryItems(testItems, 'Date Added (Newest)');
        expect(sorted[0].dateAdded, DateTime(2024, 2, 1));
        expect(sorted[1].dateAdded, DateTime(2024, 1, 15));
        expect(sorted[2].dateAdded, DateTime(2024, 1, 1));
      });

      test('sorts by Date Added (Oldest)', () {
        final sorted = SortHelper.sortInventoryItems(testItems, 'Date Added (Oldest)');
        expect(sorted[0].dateAdded, DateTime(2024, 1, 1));
        expect(sorted[1].dateAdded, DateTime(2024, 1, 15));
        expect(sorted[2].dateAdded, DateTime(2024, 2, 1));
      });

      test('defaults to Name A-Z for unknown sort option', () {
        final sorted = SortHelper.sortInventoryItems(testItems, 'Unknown');
        expect(sorted[0].name, 'Apple');
      });
    });

    group('sortProducts', () {
      test('sorts by Name A-Z', () {
        final sorted = SortHelper.sortProducts(testProducts, 'Name A-Z');
        expect(sorted[0].name, 'Apple Product');
        expect(sorted[1].name, 'Banana Product');
        expect(sorted[2].name, 'Zebra Product');
      });

      test('sorts by Name Z-A', () {
        final sorted = SortHelper.sortProducts(testProducts, 'Name Z-A');
        expect(sorted[0].name, 'Zebra Product');
        expect(sorted[1].name, 'Banana Product');
        expect(sorted[2].name, 'Apple Product');
      });

      test('sorts by Price High-Low', () {
        final sorted = SortHelper.sortProducts(testProducts, 'Price High-Low');
        expect(sorted[0].sellingPrice, 20.0);
        expect(sorted[1].sellingPrice, 15.0);
        expect(sorted[2].sellingPrice, 10.0);
      });

      test('sorts by Price Low-High', () {
        final sorted = SortHelper.sortProducts(testProducts, 'Price Low-High');
        expect(sorted[0].sellingPrice, 10.0);
        expect(sorted[1].sellingPrice, 15.0);
        expect(sorted[2].sellingPrice, 20.0);
      });

      test('defaults to Name A-Z for unknown sort option', () {
        final sorted = SortHelper.sortProducts(testProducts, 'Unknown');
        expect(sorted[0].name, 'Apple Product');
      });
    });
  });
}

