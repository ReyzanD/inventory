import '../models/inventory_item.dart';
import '../models/product.dart';
import 'local_database_service.dart';
import 'inventory_service_interface.dart';

class InventoryService implements IInventoryService {
  final LocalDatabaseService _localService = LocalDatabaseService();

  @override
  // Initialize services
  Future<void> init() async {
    // Initialize local database
    await _localService.database;
  }

  // Inventory Items - Local database only
  Future<void> addInventoryItem(InventoryItem item) async {
    await _localService.insertInventoryItem(item);
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _localService.updateInventoryItem(item);
  }

  Future<void> deleteInventoryItem(String id) async {
    await _localService.deleteInventoryItem(id);
  }

  Future<List<InventoryItem>> getAllInventoryItems() async {
    return await _localService.getAllInventoryItems();
  }

  Future<InventoryItem?> getInventoryItemById(String id) async {
    return await _localService.getInventoryItemById(id);
  }

  // Products - Local database only
  Future<void> addProduct(Product product) async {
    await _localService.insertProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _localService.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _localService.deleteProduct(id);
  }

  Future<List<Product>> getAllProducts() async {
    return await _localService.getAllProducts();
  }

  Future<Product?> getProductById(String id) async {
    return await _localService.getProductById(id);
  }
}