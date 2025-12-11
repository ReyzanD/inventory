import '../models/inventory_item.dart';
import '../models/product.dart';
import '../utils/unit_converter.dart';
import '../utils/list_extensions.dart';
import '../constants.dart';

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
        .where(
          (item) => item.quantity < AppConstants.defaultLowStockItemsThreshold,
        )
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
    final inventoryMap = items.toMapById();

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

  // Use centralized unit conversion utility
  static double getConversionFactor(
    String inventoryUnit,
    String componentUnit,
  ) {
    return UnitConverter.getConversionFactor(inventoryUnit, componentUnit);
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
