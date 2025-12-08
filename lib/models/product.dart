import 'inventory_item.dart';

// Represents a component used in a product
class ProductComponent {
  final String inventoryItemId; // reference to the inventory item
  final double quantityNeeded; // amount of that inventory item needed
  final String unit; // unit for this particular component (could be different from base inventory unit)

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
      inventoryItemId: map['inventoryItemId'] ?? '',
      quantityNeeded: (map['quantityNeeded'] is int) ? (map['quantityNeeded'] as int).toDouble() : map['quantityNeeded']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double sellingPrice;
  final List<ProductComponent> components; // ingredients/components from inventory
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
        double conversionFactor = _getConversionFactor(inventoryItem.unit, component.unit);
        double costForThisComponent = (component.quantityNeeded / conversionFactor) * inventoryItem.costPerUnit;
        totalCogs += costForThisComponent;
      }
    }
    
    return totalCogs;
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

  // Check if there's enough inventory to make this product
  bool hasEnoughInventory(Map<String, InventoryItem> inventory) {
    for (final component in components) {
      final inventoryItem = inventory[component.inventoryItemId];
      if (inventoryItem == null || inventoryItem.quantity < component.quantityNeeded) {
        return false;
      }
    }
    return true;
  }

  // Deduct inventory quantities after selling a product
  Map<String, double> deductInventoryQuantities() {
    Map<String, double> deductions = {};
    for (final component in components) {
      deductions[component.inventoryItemId] = (deductions[component.inventoryItemId] ?? 0) + component.quantityNeeded;
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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sellingPrice: (map['sellingPrice'] is int) ? (map['sellingPrice'] as int).toDouble() : map['sellingPrice']?.toDouble() ?? 0.0,
      components: (map['components'] as List<dynamic>?)
              ?.map((comp) => ProductComponent.fromMap(comp))
              .toList() ??
          [],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] ?? DateTime.now().millisecondsSinceEpoch),
      category: map['category'] ?? '',
    );
  }
}