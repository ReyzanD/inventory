import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryItem> _inventoryItems = [];
  List<Product> _products = [];

  List<InventoryItem> get inventoryItems => _inventoryItems;
  List<Product> get products => _products;

  // Initialize data
  Future<void> init() async {
    await _inventoryService.init();
    await loadInventoryItems();
    await loadProducts();
  }

  // Inventory Items
  Future<void> loadInventoryItems() async {
    _inventoryItems = await _inventoryService.getAllInventoryItems();
    notifyListeners();
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    await _inventoryService.addInventoryItem(item);
    await loadInventoryItems(); // Refresh the list
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _inventoryService.updateInventoryItem(item);
    await loadInventoryItems(); // Refresh the list
  }

  Future<void> deleteInventoryItem(String id) async {
    await _inventoryService.deleteInventoryItem(id);
    await loadInventoryItems(); // Refresh the list
  }

  // Products
  Future<void> loadProducts() async {
    _products = await _inventoryService.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _inventoryService.addProduct(product);
    await loadProducts(); // Refresh the list
  }

  Future<void> updateProduct(Product product) async {
    await _inventoryService.updateProduct(product);
    await loadProducts(); // Refresh the list
  }

  Future<void> deleteProduct(String id) async {
    await _inventoryService.deleteProduct(id);
    await loadProducts(); // Refresh the list
  }

  // Find inventory item by ID
  InventoryItem? getInventoryItemById(String id) {
    try {
      return _inventoryItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate COGS for a product
  double calculateProductCogs(String productId) {
    final product = _products.firstWhere((p) => p.id == productId);
    if (product == null) return 0.0;

    // Create a map of inventory items for quick lookup
    Map<String, InventoryItem> inventoryMap = {};
    for (final item in _inventoryItems) {
      inventoryMap[item.id] = item;
    }

    return product.calculateCogs(inventoryMap);
  }

  // Check if there's enough inventory for a product
  bool hasEnoughInventoryForProduct(String productId) {
    final product = _products.firstWhere((p) => p.id == productId);
    if (product == null) return false;

    // Create a map of inventory items for quick lookup
    Map<String, InventoryItem> inventoryMap = {};
    for (final item in _inventoryItems) {
      inventoryMap[item.id] = item;
    }

    return product.hasEnoughInventory(inventoryMap);
  }

  // Reduce inventory after selling a product
  Future<void> reduceInventoryForSoldProduct(String productId) async {
    final product = _products.firstWhere((p) => p.id == productId);
    if (product == null) return;

    // For each component in the product, reduce the quantity from the inventory
    for (final component in product.components) {
      try {
        final item = _inventoryItems.firstWhere((i) => i.id == component.inventoryItemId);
        if (item != null) {
          // Handle unit conversion properly
          // Calculate how much of the inventory item's unit is needed
          double conversionFactor = _getConversionFactor(item.unit, component.unit);
          double amountToReduce = (component.quantityNeeded / conversionFactor);

          final updatedItem = InventoryItem(
            id: item.id,
            name: item.name,
            description: item.description,
            quantity: item.quantity - amountToReduce,
            unit: item.unit,
            costPerUnit: item.costPerUnit,
            sellingPricePerUnit: item.sellingPricePerUnit,
            dateAdded: item.dateAdded,
            category: item.category,
          );

          await updateInventoryItem(updatedItem);
        }
      } catch (e) {
        // Item not found, continue
        continue;
      }
    }
  }

  // Simple conversion factor - could be expanded to handle more complex conversions
  double _getConversionFactor(String inventoryUnit, String componentUnit) {
    // Standard conversions
    if (inventoryUnit == 'kg' && componentUnit == 'g') return 1000.0; // 1kg = 1000g
    if (inventoryUnit == 'g' && componentUnit == 'kg') return 0.001; // 1g = 0.001kg
    if (inventoryUnit == 'kg' && componentUnit == 'mg') return 1000000.0; // 1kg = 1000000mg
    if (inventoryUnit == 'g' && componentUnit == 'mg') return 1000.0; // 1g = 1000mg
    if (inventoryUnit == 'L' && componentUnit == 'ml') return 1000.0; // 1L = 1000ml
    if (inventoryUnit == 'ml' && componentUnit == 'L') return 0.001; // 1ml = 0.001L

    // Same units
    if (inventoryUnit == componentUnit) return 1.0;

    // Default: assume same units if not specified
    return 1.0;
  }
}