import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/type_converter.dart';

enum TransactionType {
  addition,
  deduction,
  transfer,
}

class InventoryTransaction {
  final String id;
  final String inventoryItemId;
  final String itemName;
  final TransactionType type;
  final double quantity;
  final String unit;
  final String? reason; // Reason for the transaction
  final DateTime timestamp;
  final String? userId; // ID of user who performed the transaction

  InventoryTransaction({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.unit,
    this.reason,
    required this.timestamp,
    this.userId,
  });

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inventoryItemId': inventoryItemId,
      'itemName': itemName,
      'type': type.index,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Create from map
  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: TypeConverter.toStringValue(map['id']),
      inventoryItemId: TypeConverter.toStringValue(map['inventoryItemId']),
      itemName: TypeConverter.toStringValue(map['itemName']),
      type: TransactionType.values[TypeConverter.toInt(map['type'], 0)],
      quantity: TypeConverter.toDouble(map['quantity']),
      unit: TypeConverter.toStringValue(map['unit']),
      reason: TypeConverter.toStringValue(map['reason']),
      timestamp: TypeConverter.toDateTime(map['timestamp']),
      userId: TypeConverter.toStringValue(map['userId']),
    );
  }

  // Get icon for transaction type
  IconData getIcon() {
    switch (type) {
      case TransactionType.addition:
        return Icons.add;
      case TransactionType.deduction:
        return Icons.remove;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  // Get color for transaction type
  Color getColor() {
    switch (type) {
      case TransactionType.addition:
        return Colors.green;
      case TransactionType.deduction:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  // Get display text for transaction type
  String getTypeDisplay() {
    switch (type) {
      case TransactionType.addition:
        return 'Added';
      case TransactionType.deduction:
        return 'Removed';
      case TransactionType.transfer:
        return 'Transferred';
    }
  }
}