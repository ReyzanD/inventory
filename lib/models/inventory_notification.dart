import 'package:flutter/material.dart';
import '../utils/type_converter.dart';

enum NotificationType {
  lowStock,
  expiry,
  general
}

class InventoryNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? inventoryItemId; // Optional: link to specific inventory item

  InventoryNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.inventoryItemId,
  });

  // Create a low stock notification
  static InventoryNotification lowStock({
    required String id,
    required String itemName,
    required double currentQuantity,
    required String unit,
    double threshold = 5.0,
  }) {
    return InventoryNotification(
      id: id,
      title: 'Low Stock Alert',
      message: '$itemName has low stock: $currentQuantity $unit remaining (threshold: $threshold $unit)',
      type: NotificationType.lowStock,
      timestamp: DateTime.now(),
    );
  }

  // Create an expiry notification
  static InventoryNotification expiry({
    required String id,
    required String itemName,
    required DateTime expiryDate,
  }) {
    return InventoryNotification(
      id: id,
      title: 'Expiry Alert',
      message: '$itemName expires on ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
      type: NotificationType.expiry,
      timestamp: DateTime.now(),
    );
  }

  // Convert to map for storing in database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'inventoryItemId': inventoryItemId,
    };
  }

  // Create from map
  static InventoryNotification fromMap(Map<String, dynamic> map) {
    return InventoryNotification(
      id: TypeConverter.toStringValue(map['id']),
      title: TypeConverter.toStringValue(map['title']),
      message: TypeConverter.toStringValue(map['message']),
      type: NotificationType.values[TypeConverter.toInt(map['type'], 0)],
      timestamp: TypeConverter.toDateTime(map['timestamp']),
      isRead: TypeConverter.toBool(map['isRead'], false),
      inventoryItemId: TypeConverter.toStringValue(map['inventoryItemId']),
    );
  }

  // Get icon for notification type
  IconData getIcon() {
    switch (type) {
      case NotificationType.lowStock:
        return Icons.inventory_2;
      case NotificationType.expiry:
        return Icons.calendar_today;
      default:
        return Icons.notifications;
    }
  }

  // Get color for notification type
  Color getColor(BuildContext context) {
    switch (type) {
      case NotificationType.lowStock:
        return Colors.red;
      case NotificationType.expiry:
        return Colors.orange;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}