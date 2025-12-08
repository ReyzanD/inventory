import '../models/inventory_item.dart';
import '../models/product.dart';

class AnalyticsService {
  static Map<String, dynamic> calculateDashboardData({
    required List<InventoryItem> inventoryItems,
    required List<Product> products,
  }) {
    final totalInventoryValue = inventoryItems.fold(
      0.0,
      (sum, item) => sum + item.totalCost,
    );
    final totalSellingPrice = inventoryItems.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.sellingPricePerUnit),
    );
    final totalProducts = products.length;
    final totalInventoryItems = inventoryItems.length;
    final lowStockItems = inventoryItems
        .where((item) => item.quantity < 10)
        .length;

    return {
      'totalInventoryValue': totalInventoryValue,
      'totalSellingPrice': totalSellingPrice,
      'totalProducts': totalProducts,
      'totalInventoryItems': totalInventoryItems,
      'lowStockItems': lowStockItems,
    };
  }

  static double calculateProductCogs(
    Product product,
    List<InventoryItem> items,
  ) {
    double totalCogs = 0.0;

    // Create a map of inventory items for quick lookup
    Map<String, InventoryItem> inventoryMap = {};
    for (final item in items) {
      inventoryMap[item.id] = item;
    }

    for (final component in product.components) {
      final inventoryItem = inventoryMap[component.inventoryItemId];
      if (inventoryItem != null) {
        // Need to handle unit conversions here
        double conversionFactor = getConversionFactor(
          inventoryItem.unit,
          component.unit,
        );
        double costForThisComponent =
            (component.quantityNeeded / conversionFactor) *
            inventoryItem.costPerUnit;
        totalCogs += costForThisComponent;
      }
    }

    return totalCogs;
  }

  static double getConversionFactor(
    String inventoryUnit,
    String componentUnit,
  ) {
    // Standard conversions
    if (inventoryUnit == 'kg' && componentUnit == 'g')
      return 1000.0; // 1kg = 1000g
    if (inventoryUnit == 'g' && componentUnit == 'kg')
      return 0.001; // 1g = 0.001kg
    if (inventoryUnit == 'kg' && componentUnit == 'mg')
      return 1000000.0; // 1kg = 1000000mg
    if (inventoryUnit == 'g' && componentUnit == 'mg')
      return 1000.0; // 1g = 1000mg
    if (inventoryUnit == 'L' && componentUnit == 'ml')
      return 1000.0; // 1L = 1000ml
    if (inventoryUnit == 'ml' && componentUnit == 'L')
      return 0.001; // 1ml = 0.001L

    // Same units
    if (inventoryUnit == componentUnit) return 1.0;

    // Default: assume same units if not specified
    return 1.0;
  }

  static Map<String, double> getCategoryValues(List<InventoryItem> items) {
    Map<String, double> categoryValues = {};

    for (final item in items) {
      categoryValues[item.category] =
          (categoryValues[item.category] ?? 0) + item.totalCost;
    }

    return categoryValues;
  }

  static List<InventoryItem> getTopInventoryItems(
    List<InventoryItem> items,
    int limit,
  ) {
    final sortedItems = [...items]
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    return sortedItems.take(limit).toList();
  }

  static List<Product> getTopProducts(List<Product> products, int limit) {
    return products.take(limit).toList();
  }
}
