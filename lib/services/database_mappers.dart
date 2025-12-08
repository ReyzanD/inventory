import '../models/inventory_item.dart';
import '../models/product.dart';

class DatabaseMappers {
  static InventoryItem mapToInventoryItem(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      quantity: (map['quantity'] is int)
          ? (map['quantity'] as int).toDouble()
          : map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] as String,
      costPerUnit: (map['costPerUnit'] is int)
          ? (map['costPerUnit'] as int).toDouble()
          : map['costPerUnit']?.toDouble() ?? 0.0,
      sellingPricePerUnit: (map['sellingPricePerUnit'] is int)
          ? (map['sellingPricePerUnit'] as int).toDouble()
          : map['sellingPricePerUnit']?.toDouble() ?? 0.0,
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int),
      category: map['category'] as String,
    );
  }

  static Product mapToProduct(
    Map<String, dynamic> map,
    List<Map<String, dynamic>> componentMaps,
  ) {
    List<ProductComponent> components = componentMaps.map((comp) {
      return ProductComponent(
        inventoryItemId: comp['inventoryItemId'] as String,
        quantityNeeded: (comp['quantityNeeded'] is int)
            ? (comp['quantityNeeded'] as int).toDouble()
            : comp['quantityNeeded']?.toDouble() ?? 0.0,
        unit: comp['unit'] as String,
      );
    }).toList();

    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      sellingPrice: (map['sellingPrice'] is int)
          ? (map['sellingPrice'] as int).toDouble()
          : map['sellingPrice']?.toDouble() ?? 0.0,
      components: components,
      dateCreated: DateTime.fromMillisecondsSinceEpoch(
        map['dateCreated'] as int,
      ),
      category: map['category'] as String,
    );
  }

  static Map<String, dynamic> productComponentToMap(
    String productId,
    ProductComponent component,
  ) {
    return {
      'productId': productId,
      'inventoryItemId': component.inventoryItemId,
      'quantityNeeded': component.quantityNeeded,
      'unit': component.unit,
    };
  }

  static double safeDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
}
