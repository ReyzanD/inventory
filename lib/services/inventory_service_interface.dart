import '../models/inventory_item.dart';
import '../models/product.dart';

abstract class IInventoryService {
  Future<void> init();
  Future<List<InventoryItem>> getAllInventoryItems();
  Future<InventoryItem?> getInventoryItemById(String id);
  Future<void> addInventoryItem(InventoryItem item);
  Future<void> updateInventoryItem(InventoryItem item);
  Future<void> deleteInventoryItem(String id);
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(String id);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}