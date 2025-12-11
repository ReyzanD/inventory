import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

/// Extension methods for easier Provider access
extension InventoryProviderExtension on BuildContext {
  /// Get InventoryProvider without listening to changes
  InventoryProvider get inventoryProvider =>
      Provider.of<InventoryProvider>(this, listen: false);

  /// Watch InventoryProvider for changes
  InventoryProvider watchInventoryProvider() =>
      Provider.of<InventoryProvider>(this, listen: true);

  /// Read InventoryProvider without listening
  InventoryProvider readInventoryProvider() =>
      Provider.of<InventoryProvider>(this, listen: false);
}
