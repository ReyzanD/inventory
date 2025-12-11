import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/inventory_service_interface.dart';
import '../services/inventory_service.dart';
import '../services/audit_service.dart';
import '../services/logging_service.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/inventory_notification.dart';
import '../models/inventory_transaction.dart';
import '../utils/unit_converter.dart';
import '../utils/list_extensions.dart';
import '../utils/inventory_reduction_helper.dart';
import '../constants.dart';
import 'dart:core';

final inventoryServiceProvider = Provider<IInventoryService>((ref) {
  return InventoryService();
});

final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService();
});

final loggingServiceProvider = Provider<LoggingService>((ref) {
  return LoggingService();
});

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
      final inventoryService = ref.watch(inventoryServiceProvider);
      final auditService = ref.watch(auditServiceProvider);
      return InventoryNotifier(inventoryService, auditService);
    });

class InventoryState {
  final List<InventoryItem> inventoryItems;
  final List<Product> products;
  final bool isLoadingInventory;
  final bool isLoadingProducts;
  final bool isLoadingNotifications;
  final String? errorMessage;

  InventoryState({
    this.inventoryItems = const [],
    this.products = const [],
    this.isLoadingInventory = false,
    this.isLoadingProducts = false,
    this.isLoadingNotifications = false,
    this.errorMessage,
  });

  InventoryState copyWith({
    List<InventoryItem>? inventoryItems,
    List<Product>? products,
    bool? isLoadingInventory,
    bool? isLoadingProducts,
    bool? isLoadingNotifications,
    String? errorMessage,
  }) {
    return InventoryState(
      inventoryItems: inventoryItems ?? this.inventoryItems,
      products: products ?? this.products,
      isLoadingInventory: isLoadingInventory ?? this.isLoadingInventory,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingNotifications:
          isLoadingNotifications ?? this.isLoadingNotifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final IInventoryService _inventoryService;
  final AuditService _auditService;

  InventoryNotifier(this._inventoryService, this._auditService)
    : super(InventoryState());

  Future<void> init() async {
    await loadInventoryItems();
    await loadProducts();
    await checkNotifications();
  }

  Future<void> loadInventoryItems() async {
    state = state.copyWith(isLoadingInventory: true);
    try {
      final items = await _inventoryService.getAllInventoryItems();
      state = state.copyWith(inventoryItems: items, isLoadingInventory: false);
    } catch (e) {
      LoggingService.severe('Error loading inventory items: $e');
      state = state.copyWith(
        isLoadingInventory: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoadingProducts: true);
    try {
      final products = await _inventoryService.getAllProducts();
      state = state.copyWith(products: products, isLoadingProducts: false);
    } catch (e) {
      LoggingService.severe('Error loading products: $e');
      state = state.copyWith(
        isLoadingProducts: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    try {
      await _inventoryService.addInventoryItem(item);

      // Log transaction for audit trail
      _auditService.logTransaction(
        inventoryItemId: item.id,
        itemName: item.name,
        type: TransactionType.addition,
        quantity: item.quantity,
        unit: item.unit,
        reason: 'Item added to inventory',
        userId: AppConstants.defaultUserId,
      );

      await loadInventoryItems(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error adding inventory item: $e');
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    try {
      final originalItem = state.inventoryItems.firstWhere(
        (i) => i.id == item.id,
        orElse: () => item,
      );
      final quantityDifference = item.quantity - originalItem.quantity;

      await _inventoryService.updateInventoryItem(item);

      // Log transaction for audit trail
      if (quantityDifference != 0) {
        final transactionType = quantityDifference > 0
            ? TransactionType.addition
            : TransactionType.deduction;
        _auditService.logTransaction(
          inventoryItemId: item.id,
          itemName: item.name,
          type: transactionType,
          quantity: quantityDifference.abs(),
          unit: item.unit,
          reason: 'Item updated',
          userId: AppConstants.defaultUserId,
        );
      }

      await loadInventoryItems(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error updating inventory item: $e');
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      final item = state.inventoryItems.firstWhere(
        (i) => i.id == id,
        orElse: () => InventoryItem(
          id: id,
          name: 'Unknown',
          description: '',
          quantity: 0,
          unit: '',
          costPerUnit: 0,
          sellingPricePerUnit: 0,
          dateAdded: DateTime.now(),
          category: '',
        ),
      );

      await _inventoryService.deleteInventoryItem(id);

      // Log transaction for audit trail (log as deduction of all remaining quantity)
      if (item.quantity > 0) {
        _auditService.logTransaction(
          inventoryItemId: item.id,
          itemName: item.name,
          type: TransactionType.deduction,
          quantity: item.quantity,
          unit: item.unit,
          reason: 'Item deleted from inventory',
          userId: AppConstants.defaultUserId,
        );
      }

      await loadInventoryItems(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error deleting inventory item: $e');
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _inventoryService.addProduct(product);
      await loadProducts(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error adding product: $e');
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _inventoryService.updateProduct(product);
      await loadProducts(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error updating product: $e');
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _inventoryService.deleteProduct(id);
      await loadProducts(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error deleting product: $e');
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> checkNotifications() async {
    state = state.copyWith(isLoadingNotifications: true);
    try {
      // Check for low stock items
      final lowStockNotifications = _checkLowStockItems();
      state = state.copyWith(isLoadingNotifications: false);
    } catch (e) {
      LoggingService.severe('Error checking notifications: $e');
      state = state.copyWith(
        isLoadingNotifications: false,
        errorMessage: e.toString(),
      );
    }
  }

  List<InventoryNotification> _checkLowStockItems() {
    List<InventoryNotification> notifications = [];

    for (final item in state.inventoryItems) {
      // Use item-specific low stock threshold
      if (item.quantity <= item.lowStockThreshold) {
        final notification = InventoryNotification.lowStock(
          id: 'low_stock_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
          itemName: item.name,
          currentQuantity: item.quantity,
          unit: item.unit,
          threshold: item.lowStockThreshold,
        );
        notifications.add(notification);
      }
    }

    return notifications;
  }

  // Calculate COGS for a product
  double calculateProductCogs(String productId) {
    try {
      final product = state.products.firstWhere((p) => p.id == productId);
      if (product == null) return 0.0;

      // Create a map of inventory items for quick lookup
      final inventoryMap = state.inventoryItems.toMapById();

      return product.calculateCogs(inventoryMap);
    } catch (e) {
      // Product not found
      return 0.0;
    }
  }

  // Check if there's enough inventory for a product
  bool hasEnoughInventoryForProduct(String productId) {
    try {
      final product = state.products.firstWhere((p) => p.id == productId);
      if (product == null) return false;

      // Create a map of inventory items for quick lookup
      final inventoryMap = state.inventoryItems.toMapById();

      return product.hasEnoughInventory(inventoryMap);
    } catch (e) {
      // Product not found
      return false;
    }
  }

  // Reduce inventory after selling a product
  Future<void> reduceInventoryForSoldProduct(String productId) async {
    try {
      final product = state.products.firstWhere((p) => p.id == productId);
      if (product == null) return;

      // Process each component reduction
      for (final component in product.components) {
        try {
          final item = state.inventoryItems.firstWhere(
            (i) => i.id == component.inventoryItemId,
          );

          final updatedItem =
              await InventoryReductionHelper.processComponentReduction(
                item: item,
                component: component,
                productName: product.name,
                auditService: _auditService,
              );

          if (updatedItem != null) {
            await updateInventoryItem(updatedItem);
          }
        } catch (e) {
          // Item not found, continue to next component
          continue;
        }
      }
    } catch (e) {
      // Product not found, do nothing
      return;
    }
  }

  // Removed _getConversionFactor - using InventoryReductionHelper instead

  InventoryItem? getInventoryItemById(String id) {
    try {
      return state.inventoryItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
