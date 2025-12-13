import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<InventoryItem> _inventoryItems = [];
  List<Product> _products = [];

  List<InventoryItem> get inventoryItems => _inventoryItems;
  List<Product> get products => _products;

  // Initialize data
  Future<void> init() async {
    await loadInventoryItems();
    await loadProducts();
  }

  // Inventory Items
  Future<void> loadInventoryItems() async {
    _inventoryItems = await _databaseService.getAllInventoryItems();
    notifyListeners();
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    await _databaseService.insertInventoryItem(item);
    await loadInventoryItems(); // Refresh the list
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _databaseService.updateInventoryItem(item);
    await loadInventoryItems(); // Refresh the list
  }

  Future<void> deleteInventoryItem(String id) async {
    await _databaseService.deleteInventoryItem(id);
    await loadInventoryItems(); // Refresh the list
  }

  // Products
  Future<void> loadProducts() async {
    _products = await _databaseService.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _databaseService.insertProduct(product);
    await loadProducts(); // Refresh the list
  }

  Future<void> updateProduct(Product product) async {
    await _databaseService.updateProduct(product);
    await loadProducts(); // Refresh the list
  }

  Future<void> deleteProduct(String id) async {
    await _databaseService.deleteProduct(id);
    await loadProducts(); // Refresh the list
  }

  // Find inventory item by ID
  InventoryItem? getInventoryItemById(String id) {
    return _inventoryItems.firstWhere((item) => item.id == id, orElse: () => null);
  }

  // Calculate COGS for a product
  double calculateProductCogs(String productId) {
    final product = _products.firstWhere((p) => p.id == productId, orElse: () => null);
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
    final product = _products.firstWhere((p) => p.id == productId, orElse: () => null);
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
    final product = _products.firstWhere((p) => p.id == productId, orElse: () => null);
    if (product == null) return;

    final deductions = product.deductInventoryQuantities();
    
    for (final entry in deductions.entries) {
      final itemId = entry.key;
      final reductionAmount = entry.value;
      
      final item = _inventoryItems.firstWhere((i) => i.id == itemId, orElse: () => null);
      if (item != null) {
        final updatedItem = InventoryItem(
          id: item.id,
          name: item.name,
          description: item.description,
          quantity: item.quantity - reductionAmount,
          unit: item.unit,
          costPerUnit: item.costPerUnit,
          sellingPricePerUnit: item.sellingPricePerUnit,
          dateAdded: item.dateAdded,
          category: item.category,
        );
        
        await updateInventoryItem(updatedItem);
      }
    }
  }
}