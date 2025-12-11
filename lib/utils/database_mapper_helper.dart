import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/inventory_transaction.dart';
import '../services/database_mappers.dart';

/// Helper utility for mapping database query results to model objects
/// Reduces code duplication in database services
class DatabaseMapperHelper {
  /// Map list of database maps to InventoryItem list
  static List<InventoryItem> mapToInventoryItems(
    List<Map<String, dynamic>> maps,
  ) {
    return List.generate(maps.length, (i) {
      return DatabaseMappers.mapToInventoryItem(maps[i]);
    });
  }

  /// Map list of database maps to Product list
  static List<Product> mapToProducts(
    List<Map<String, dynamic>> productMaps,
    Map<String, List<Map<String, dynamic>>> componentsByProductId,
  ) {
    return List.generate(productMaps.length, (i) {
      final productId = productMaps[i]['id'] as String;
      final componentMaps = componentsByProductId[productId] ?? [];
      return DatabaseMappers.mapToProduct(productMaps[i], componentMaps);
    });
  }

  /// Map list of database maps to InventoryTransaction list
  static List<InventoryTransaction> mapToTransactions(
    List<Map<String, dynamic>> maps,
  ) {
    return List.generate(maps.length, (i) {
      return InventoryTransaction.fromMap(maps[i]);
    });
  }
}
