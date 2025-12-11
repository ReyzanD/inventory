import 'inventory_item.dart';
import '../utils/type_converter.dart';
import '../utils/unit_converter.dart';

// Represents a component used in a product
class ProductComponent {
  final String inventoryItemId; // reference to the inventory item
  final double quantityNeeded; // amount of that inventory item needed
  final String
  unit; // unit for this particular component (could be different from base inventory unit)

  ProductComponent({
    required this.inventoryItemId,
    required this.quantityNeeded,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'inventoryItemId': inventoryItemId,
      'quantityNeeded': quantityNeeded,
      'unit': unit,
    };
  }

  factory ProductComponent.fromMap(Map<String, dynamic> map) {
    return ProductComponent(
      inventoryItemId: TypeConverter.toStringValue(map['inventoryItemId']),
      quantityNeeded: TypeConverter.toDouble(map['quantityNeeded']),
      unit: TypeConverter.toStringValue(map['unit']),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double sellingPrice;
  final List<ProductComponent>
  components; // ingredients/components from inventory
  final DateTime dateCreated;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.sellingPrice,
    required this.components,
    required this.dateCreated,
    required this.category,
  });

  // Calculates the Cost of Goods Sold (COGS) for this product
  double calculateCogs(Map<String, InventoryItem> inventory) {
    double totalCogs = 0.0;

    for (final component in components) {
      final inventoryItem = inventory[component.inventoryItemId];
      if (inventoryItem != null) {
        // Need to handle unit conversions here
        double conversionFactor = _getConversionFactor(
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
  double _getConversionFactor(String inventoryUnit, String componentUnit) {
    // Import will be added at top of file
    return UnitConverter.getConversionFactor(inventoryUnit, componentUnit);
  }

  // Check if there's enough inventory to make this product
  bool hasEnoughInventory(Map<String, InventoryItem> inventory) {
    for (final component in components) {
      final inventoryItem = inventory[component.inventoryItemId];
      if (inventoryItem == null ||
          inventoryItem.quantity < component.quantityNeeded) {
        return false;
      }
    }
    return true;
  }

  // Deduct inventory quantities after selling a product
  Map<String, double> deductInventoryQuantities() {
    Map<String, double> deductions = {};
    for (final component in components) {
      deductions[component.inventoryItemId] =
          (deductions[component.inventoryItemId] ?? 0) +
          component.quantityNeeded;
    }
    return deductions;
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sellingPrice': sellingPrice,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'category': category,
      'components': components.map((comp) => comp.toMap()).toList(),
    };
  }

  // Create from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: TypeConverter.toStringValue(map['id']),
      name: TypeConverter.toStringValue(map['name']),
      description: TypeConverter.toStringValue(map['description']),
      sellingPrice: TypeConverter.toDouble(map['sellingPrice']),
      components:
          (map['components'] as List<dynamic>?)
              ?.map((comp) => ProductComponent.fromMap(comp))
              .toList() ??
          [],
      dateCreated: TypeConverter.toDateTime(map['dateCreated']),
      category: TypeConverter.toStringValue(map['category']),
    );
  }
}
