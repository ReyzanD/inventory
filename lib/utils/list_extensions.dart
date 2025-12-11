import '../models/inventory_item.dart';
import '../models/product.dart';

/// Extension methods for List operations
extension InventoryItemListExtension on List<InventoryItem> {
  /// Extract unique categories from inventory items
  List<String> extractUniqueCategories() {
    return map((item) => item.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  /// Convert list to map by ID for O(1) lookup
  Map<String, InventoryItem> toMapById() {
    return {for (var item in this) item.id: item};
  }
}

extension ProductListExtension on List<Product> {
  /// Extract unique categories from products
  List<String> extractUniqueCategories() {
    return map((product) => product.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  /// Convert list to map by ID for O(1) lookup
  Map<String, Product> toMapById() {
    return {for (var product in this) product.id: product};
  }
}

