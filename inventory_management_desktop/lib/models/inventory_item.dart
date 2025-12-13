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
    };
  }

  // Create from Map
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      unit: map['unit'],
      costPerUnit: map['costPerUnit'],
      sellingPricePerUnit: map['sellingPricePerUnit'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      category: map['category'],
    );
  }
}