import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/services/inventory_service_interface.dart';
import 'package:inventory/models/inventory_item.dart';
import 'package:inventory/models/product.dart';

class _FakeInventoryService implements IInventoryService {
  final List<InventoryItem> _items;
  final List<Product> _products;

  _FakeInventoryService({List<InventoryItem>? items, List<Product>? products})
    : _items = items ?? const [],
      _products = products ?? const [];

  @override
  Future<void> init() async {}

  @override
  Future<void> addInventoryItem(InventoryItem item) async {
    _items.add(item);
  }

  @override
  Future<void> addProduct(Product product) async {
    _products.add(product);
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<InventoryItem>> getAllInventoryItems() async => List.of(_items);

  @override
  Future<List<Product>> getAllProducts() async => List.of(_products);

  @override
  Future<InventoryItem?> getInventoryItemById(String id) async => null;

  @override
  Future<Product?> getProductById(String id) async => null;

  @override
  Future<void> updateInventoryItem(InventoryItem item) async {}

  @override
  Future<void> updateProduct(Product product) async {}
}

class _SmokeScreen extends StatelessWidget {
  const _SmokeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Smoke')),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          final items = provider.inventoryItems;
          final products = provider.products;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Inventory count: ${items.length}'),
              Text('Product count: ${products.length}'),
              const SizedBox(height: 12),
              ...items.map(
                (e) => ListTile(
                  title: Text(e.name),
                  subtitle: Text('${e.quantity} ${e.unit}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void main() {
  testWidgets('App smoke test with injected provider and fake data', (
    tester,
  ) async {
    final fakeService = _FakeInventoryService(
      items: [
        InventoryItem(
          id: '1',
          name: 'Sample Item',
          description: 'Desc',
          quantity: 5,
          unit: 'kg',
          costPerUnit: 10,
          sellingPricePerUnit: 12,
          dateAdded: DateTime(2024, 1, 1),
          category: 'General',
        ),
      ],
      products: [
        Product(
          id: 'p1',
          name: 'Sample Product',
          description: 'Desc',
          sellingPrice: 50,
          components: const [],
          dateCreated: DateTime(2024, 1, 2),
          category: 'General',
        ),
      ],
    );

    final provider = InventoryProvider.forTesting(fakeService);
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<InventoryProvider>.value(
        value: provider,
        child: const MaterialApp(home: _SmokeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Inventory count: 1'), findsOneWidget);
    expect(find.text('Product count: 1'), findsOneWidget);
    expect(find.text('Sample Item'), findsOneWidget);
    expect(find.textContaining('kg'), findsOneWidget);
  });
}
