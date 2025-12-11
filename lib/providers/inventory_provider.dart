import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/inventory_notification.dart';
import '../models/inventory_transaction.dart';
import '../services/inventory_service.dart';
import '../services/logging_service.dart';
import '../services/audit_service.dart';
import '../services/inventory_service_interface.dart';
import '../utils/list_extensions.dart';
import '../utils/inventory_reduction_helper.dart';
import '../constants.dart';

class InventoryProvider extends ChangeNotifier {
  final IInventoryService _inventoryService;
  final AuditService _auditService = AuditService();

  // Public constructor for normal use
  InventoryProvider() : _inventoryService = InventoryService();

  // Named constructor for testing purposes to inject mock services
  InventoryProvider.forTesting(IInventoryService inventoryService)
    : _inventoryService = inventoryService;
  List<InventoryItem> _inventoryItems = [];
  List<Product> _products = [];

  List<InventoryItem> get inventoryItems => _inventoryItems;
  List<Product> get products => _products;
  List<InventoryNotification> _notifications = [];
  List<InventoryNotification> get notifications => _notifications;

  // Loading states
  bool _isLoadingInventory = false;
  String? _inventoryError;
  bool _isLoadingProducts = false;
  String? _productsError;
  bool _isLoadingNotifications = false;

  bool get isLoadingInventory => _isLoadingInventory;
  String? get inventoryError => _inventoryError;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;
  bool get isLoadingNotifications => _isLoadingNotifications;

  // Initialize data
  Future<void> init() async {
    await _inventoryService.init();
    await loadInventoryItems();
    await loadProducts();
    await checkNotifications();
  }

  // Track operations that are in progress to avoid conflicts with mouse tracker
  bool _isLoadingInventoryOperation = false;
  bool _isLoadingProductsOperation = false;
  bool _isLoadingNotificationsOperation = false;

  // Debouncing variables to prevent multiple rapid notifications
  Timer? _inventoryNotificationTimer;
  Timer? _productsNotificationTimer;
  Timer? _notificationsNotificationTimer;

  // Safe notification method to debounce UI updates and prevent mouse tracking conflicts
  void _safeNotifyListeners(String operation) {
    switch (operation) {
      case 'inventory':
        _inventoryNotificationTimer?.cancel();
        _inventoryNotificationTimer = Timer(Duration(milliseconds: 50), () {
          // Only notify if provider is still active (not disposed)
          // ChangeNotifier doesn't have isDisposed, so just call notifyListeners safely
          try {
            notifyListeners();
          } catch (e) {
            // If there's an error during notification (like during disposal), catch it silently
          }
          _inventoryNotificationTimer = null;
        });
        break;
      case 'products':
        _productsNotificationTimer?.cancel();
        _productsNotificationTimer = Timer(Duration(milliseconds: 50), () {
          // Only notify if provider is still active (not disposed)
          // ChangeNotifier doesn't have isDisposed, so just call notifyListeners safely
          try {
            notifyListeners();
          } catch (e) {
            // If there's an error during notification (like during disposal), catch it silently
          }
          _productsNotificationTimer = null;
        });
        break;
      case 'notifications':
        _notificationsNotificationTimer?.cancel();
        _notificationsNotificationTimer = Timer(Duration(milliseconds: 50), () {
          // Only notify if provider is still active (not disposed)
          // ChangeNotifier doesn't have isDisposed, so just call notifyListeners safely
          try {
            notifyListeners();
          } catch (e) {
            // If there's an error during notification (like during disposal), catch it silently
          }
          _notificationsNotificationTimer = null;
        });
        break;
    }
  }

  // Check for notifications (low stock, expiry, etc.)
  Future<void> checkNotifications() async {
    if (_isLoadingNotificationsOperation)
      return; // Prevent concurrent operations
    _isLoadingNotificationsOperation = true;

    _isLoadingNotifications = true;
    _safeNotifyListeners('notifications');
    try {
      // Check for low stock items
      final lowStockNotifications = _checkLowStockItems();

      // Check for expiry items
      final expiryNotifications = _checkExpiryItems();

      // Combine all notifications
      _notifications = [...lowStockNotifications, ...expiryNotifications];
    } catch (e) {
      LoggingService.severe('Error checking notifications: $e');
    } finally {
      _isLoadingNotifications = false;
      // Use safe notification to avoid conflicts with mouse updates
      _safeNotifyListeners('notifications');
      _isLoadingNotificationsOperation = false;
    }
  }

  // Check for expiry items
  List<InventoryNotification> _checkExpiryItems() {
    List<InventoryNotification> notifications = [];
    final now = DateTime.now();
    const warningDays = 7; // Alert 7 days before expiry

    for (final item in _inventoryItems) {
      if (item.expiryDate != null) {
        final daysToExpiry = item.expiryDate!.difference(now).inDays;

        // Alert if item expires within the warning period
        if (daysToExpiry >= 0 && daysToExpiry <= warningDays) {
          final notification = InventoryNotification.expiry(
            id: 'expiry_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
            itemName: item.name,
            expiryDate: item.expiryDate!,
          );
          notifications.add(notification);
        } else if (item.expiryDate!.isBefore(now)) {
          // Alert if item is already expired
          final notification = InventoryNotification.expiry(
            id: 'expired_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
            itemName: item.name,
            expiryDate: item.expiryDate!,
          );
          notifications.add(notification);
        }
      }
    }

    return notifications;
  }

  // Check for low stock items
  List<InventoryNotification> _checkLowStockItems() {
    List<InventoryNotification> notifications = [];

    for (final item in _inventoryItems) {
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

  // Track an inventory transaction
  Future<void> addTransaction({
    required String inventoryItemId,
    required String itemName,
    required TransactionType type,
    required double quantity,
    required String unit,
    String? reason,
    String? userId,
  }) async {
    // Use AuditService to log the transaction
    await _auditService.logTransaction(
      inventoryItemId: inventoryItemId,
      itemName: itemName,
      type: type,
      quantity: quantity,
      unit: unit,
      reason: reason ?? 'Transaction logged',
      userId: userId ?? AppConstants.defaultUserId,
    );
    LoggingService.info(
      'Transaction: $type $quantity $unit of $itemName (ID: $inventoryItemId)',
    );
  }

  // Inventory Items
  Future<void> loadInventoryItems() async {
    if (_isLoadingInventoryOperation) return; // Prevent concurrent operations
    _isLoadingInventoryOperation = true;

    _isLoadingInventory = true;
    _inventoryError = null;
    _safeNotifyListeners('inventory');
    try {
      _inventoryItems = await _inventoryService.getAllInventoryItems();
      await checkNotifications(); // Check notifications after loading inventory
    } catch (e) {
      _inventoryError = e.toString();
      LoggingService.severe('Error loading inventory items: $e');
      rethrow;
    } finally {
      _isLoadingInventory = false;
      _safeNotifyListeners('inventory');
      _isLoadingInventoryOperation = false;
    }
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    try {
      await _inventoryService.addInventoryItem(item);
      await loadInventoryItems(); // Refresh the list

      // Log transaction for audit trail
      await _auditService.logTransaction(
        inventoryItemId: item.id,
        itemName: item.name,
        type: TransactionType.addition,
        quantity: item.quantity,
        unit: item.unit,
        reason: 'Item added to inventory',
        userId: AppConstants
            .defaultUserId, // In a real app, this would be the actual user ID
      );
    } catch (e) {
      LoggingService.severe('Error adding inventory item: $e');
      rethrow; // Re-throw to be handled by UI layer
    }
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    try {
      // Get the original item to determine the quantity change
      final originalItem = _inventoryItems.firstWhere(
        (i) => i.id == item.id,
        orElse: () => item,
      );
      final quantityDifference = item.quantity - originalItem.quantity;

      await _inventoryService.updateInventoryItem(item);
      await loadInventoryItems(); // Refresh the list

      // Log transaction for audit trail
      if (quantityDifference != 0) {
        final transactionType = quantityDifference > 0
            ? TransactionType.addition
            : TransactionType.deduction;
        await _auditService.logTransaction(
          inventoryItemId: item.id,
          itemName: item.name,
          type: transactionType,
          quantity: quantityDifference.abs(),
          unit: item.unit,
          reason: 'Item updated',
          userId: AppConstants
              .defaultUserId, // In a real app, this would be the actual user ID
        );
      }
    } catch (e) {
      LoggingService.severe('Error updating inventory item: $e');
      rethrow; // Re-throw to be handled by UI layer
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      final item = _inventoryItems.firstWhere(
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
      await loadInventoryItems(); // Refresh the list

      // Log transaction for audit trail (log as deduction of all remaining quantity)
      if (item.quantity > 0) {
        await _auditService.logTransaction(
          inventoryItemId: item.id,
          itemName: item.name,
          type: TransactionType.deduction,
          quantity: item.quantity,
          unit: item.unit,
          reason: 'Item deleted from inventory',
          userId: AppConstants
              .defaultUserId, // In a real app, this would be the actual user ID
        );
      }
    } catch (e) {
      LoggingService.severe('Error deleting inventory item: $e');
      rethrow; // Re-throw to be handled by UI layer
    }
  }

  // Products
  Future<void> loadProducts() async {
    if (_isLoadingProductsOperation) return; // Prevent concurrent operations
    _isLoadingProductsOperation = true;

    _isLoadingProducts = true;
    _productsError = null;
    _safeNotifyListeners('products');
    try {
      _products = await _inventoryService.getAllProducts();
    } catch (e) {
      _productsError = e.toString();
      LoggingService.severe('Error loading products: $e');
      rethrow;
    } finally {
      _isLoadingProducts = false;
      _safeNotifyListeners('products');
      _isLoadingProductsOperation = false;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _inventoryService.addProduct(product);
      await loadProducts(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _inventoryService.updateProduct(product);
      await loadProducts(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _inventoryService.deleteProduct(id);
      await loadProducts(); // Refresh the list
    } catch (e) {
      LoggingService.severe('Error deleting product: $e');
      rethrow;
    }
  }

  // Find inventory item by ID
  InventoryItem? getInventoryItemById(String id) {
    try {
      return _inventoryItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate COGS for a product
  double calculateProductCogs(String productId) {
    try {
      final product = _products.firstWhere((p) => p.id == productId);

      // Create a map of inventory items for quick lookup
      final inventoryMap = _inventoryItems.toMapById();

      return product.calculateCogs(inventoryMap);
    } catch (e) {
      // Product not found
      return 0.0;
    }
  }

  // Check if there's enough inventory for a product
  bool hasEnoughInventoryForProduct(String productId) {
    try {
      final product = _products.firstWhere((p) => p.id == productId);

      // Create a map of inventory items for quick lookup
      final inventoryMap = _inventoryItems.toMapById();

      return product.hasEnoughInventory(inventoryMap);
    } catch (e) {
      // Product not found
      return false;
    }
  }

  // Reduce inventory after selling a product
  Future<void> reduceInventoryForSoldProduct(String productId) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);

      // Process each component reduction
      for (final component in product.components) {
        try {
          final item = _inventoryItems.firstWhere(
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

  @override
  void dispose() {
    // Cancel all timers to prevent notifications after disposal
    _inventoryNotificationTimer?.cancel();
    _productsNotificationTimer?.cancel();
    _notificationsNotificationTimer?.cancel();
    super.dispose();
  }

  // Removed _getConversionFactor - using InventoryReductionHelper instead

  // Methods for backup/restore functionality
  List<InventoryItem> getExportableInventoryItems() {
    return List.from(_inventoryItems);
  }

  List<Product> getExportableProducts() {
    return List.from(_products);
  }

  Future<void> importInventoryItems(List<InventoryItem> items) async {
    for (final item in items) {
      try {
        // Check if item already exists (by ID)
        final existingItem = _inventoryItems.firstWhere(
          (i) => i.id == item.id,
          orElse: () => item, // If not found, return the imported item
        );

        if (existingItem.id == item.id) {
          // Item exists, update it
          await _inventoryService.updateInventoryItem(item);
        } else {
          // Item doesn't exist, add it
          await _inventoryService.addInventoryItem(item);
        }
      } catch (e) {
        // If firstWhere doesn't find an item, it throws an error
        // This means item doesn't exist, so we add it
        await _inventoryService.addInventoryItem(item);
      }
    }
    // Refresh the list after import
    await loadInventoryItems();
  }

  Future<void> importProducts(List<Product> products) async {
    for (final product in products) {
      try {
        // Check if product already exists (by ID)
        final existingProduct = _products.firstWhere(
          (p) => p.id == product.id,
          orElse: () => product, // If not found, return the imported product
        );

        if (existingProduct.id == product.id) {
          // Product exists, update it
          await _inventoryService.updateProduct(product);
        } else {
          // Product doesn't exist, add it
          await _inventoryService.addProduct(product);
        }
      } catch (e) {
        // If firstWhere doesn't find a product, it throws an error
        // This means product doesn't exist, so we add it
        await _inventoryService.addProduct(product);
      }
    }
    // Refresh the list after import
    await loadProducts();
  }
}
