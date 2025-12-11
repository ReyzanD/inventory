import '../utils/type_converter.dart';

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final double quantity; // in base unit (grams, liters, etc.)
  final String unit; // unit of measure (kg, g, liters, pieces, etc.)
  final double costPerUnit; // cost per unit for COGS calculation
  final double sellingPricePerUnit; // price per unit if sold individually
  final DateTime dateAdded;
  final String category;
  final double lowStockThreshold; // configurable low stock threshold
  final DateTime? expiryDate; // optional expiry date for perishable items

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.costPerUnit,
    required this.sellingPricePerUnit,
    required this.dateAdded,
    required this.category,
    this.lowStockThreshold = 5.0, // Default threshold to 5
    this.expiryDate,
  });

  // Calculate total cost for the current inventory
  double get totalCost => quantity * costPerUnit;

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'costPerUnit': costPerUnit,
      'sellingPricePerUnit': sellingPricePerUnit,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'category': category,
      'lowStockThreshold': lowStockThreshold,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
    };
  }

  // Create from Map
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: TypeConverter.toStringValue(map['id']),
      name: TypeConverter.toStringValue(map['name']),
      description: TypeConverter.toStringValue(map['description']),
      quantity: TypeConverter.toDouble(map['quantity']),
      unit: TypeConverter.toStringValue(map['unit']),
      costPerUnit: TypeConverter.toDouble(map['costPerUnit']),
      sellingPricePerUnit: TypeConverter.toDouble(map['sellingPricePerUnit']),
      dateAdded: TypeConverter.toDateTime(map['dateAdded']),
      category: TypeConverter.toStringValue(map['category']),
      lowStockThreshold: TypeConverter.toDouble(map['lowStockThreshold'], 5.0),
      expiryDate: map['expiryDate'] != null ? DateTime.fromMillisecondsSinceEpoch(TypeConverter.toInt(map['expiryDate'])) : null,
    );
  }
}