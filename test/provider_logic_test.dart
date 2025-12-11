import 'package:flutter_test/flutter_test.dart';

import 'package:inventory/models/inventory_item.dart';
import 'package:inventory/models/product.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/services/inventory_service_interface.dart';

class _FakeInventoryService implements IInventoryService {
  final List<InventoryItem> items;
  final List<Product> products;

  _FakeInventoryService({required this.items, required this.products});

  @override
  Future<void> init() async {}

  @override
  Future<List<InventoryItem>> getAllInventoryItems() async => items;

  @override
  Future<List<Product>> getAllProducts() async => products;

  @override
  Future<InventoryItem?> getInventoryItemById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Product?> getProductById(String id) async {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  @override
  Future<void> addInventoryItem(InventoryItem item) async {}

  @override
  Future<void> addProduct(Product product) async {}

  @override
  Future<void> deleteInventoryItem(String id) async {}

  @override
  Future<void> deleteProduct(String id) async {}

  @override
  Future<void> updateInventoryItem(InventoryItem item) async {}

  @override
  Future<void> updateProduct(Product product) async {}
}

void main() {
  test('calculateProductCogs uses inventory cost', () async {
    final items = [
      InventoryItem(
        id: 'i1',
        name: 'Flour',
        description: 'All-purpose',
        quantity: 100,
        unit: 'kg',
        costPerUnit: 5,
        sellingPricePerUnit: 0,
        dateAdded: DateTime(2024, 1, 1),
        category: 'Ingredients',
      ),
    ];

    final products = [
      Product(
        id: 'p1',
        name: 'Bread',
        description: 'Loaf',
        sellingPrice: 20,
        components: [
          ProductComponent(
            inventoryItemId: 'i1',
            quantityNeeded: 2,
            unit: 'kg',
          ),
        ],
        dateCreated: DateTime(2024, 1, 2),
        category: 'Food',
      ),
    ];

    final provider = InventoryProvider.forTesting(
      _FakeInventoryService(items: items, products: products),
    );
    await provider.init();

    final cogs = provider.calculateProductCogs('p1');
    expect(cogs, 10); // 2 kg * 5
  });

  test('checkNotifications detects low stock and expiry', () async {
    final items = [
      InventoryItem(
        id: 'i1',
        name: 'Milk',
        description: 'Fresh milk',
        quantity: 3, // below threshold default 5
        unit: 'L',
        costPerUnit: 1,
        sellingPricePerUnit: 2,
        dateAdded: DateTime(2024, 1, 1),
        category: 'Dairy',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      ),
    ];

    final provider = InventoryProvider.forTesting(
      _FakeInventoryService(items: items, products: []),
    );
    await provider.init();

    expect(provider.notifications.isNotEmpty, isTrue);
    expect(
      provider.notifications.any((n) => n.title.contains('Low Stock')),
      isTrue,
    );
    expect(
      provider.notifications.any((n) => n.title.contains('Expiry')),
      isTrue,
    );
  });
}
