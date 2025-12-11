import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/inventory_transaction.dart';
import '../services/audit_service.dart';
import '../utils/unit_converter.dart';
import '../constants.dart';

/// Helper utility for reducing inventory when products are sold
/// Extracted from long methods in providers
class InventoryReductionHelper {
  /// Calculate the amount to reduce from inventory for a component
  static double calculateReductionAmount(
    InventoryItem item,
    ProductComponent component,
  ) {
    final conversionFactor = UnitConverter.getConversionFactor(
      item.unit,
      component.unit,
    );
    return component.quantityNeeded / conversionFactor;
  }

  /// Create updated inventory item with reduced quantity
  static InventoryItem createReducedItem(
    InventoryItem item,
    double amountToReduce,
  ) {
    return InventoryItem(
      id: item.id,
      name: item.name,
      description: item.description,
      quantity: item.quantity - amountToReduce,
      unit: item.unit,
      costPerUnit: item.costPerUnit,
      sellingPricePerUnit: item.sellingPricePerUnit,
      dateAdded: item.dateAdded,
      category: item.category,
      lowStockThreshold: item.lowStockThreshold,
      expiryDate: item.expiryDate,
    );
  }

  /// Log transaction for inventory reduction
  static Future<void> logReductionTransaction({
    required AuditService auditService,
    required InventoryItem item,
    required double amountToReduce,
    required String productName,
  }) async {
    await auditService.logTransaction(
      inventoryItemId: item.id,
      itemName: item.name,
      type: TransactionType.deduction,
      quantity: amountToReduce,
      unit: item.unit,
      reason: 'Used in product: $productName',
      userId: AppConstants.defaultUserId,
    );
  }

  /// Process component reduction for a single component
  static Future<InventoryItem?> processComponentReduction({
    required InventoryItem item,
    required ProductComponent component,
    required String productName,
    required AuditService auditService,
  }) async {
    try {
      final amountToReduce = calculateReductionAmount(item, component);
      final updatedItem = createReducedItem(item, amountToReduce);

      await logReductionTransaction(
        auditService: auditService,
        item: item,
        amountToReduce: amountToReduce,
        productName: productName,
      );

      return updatedItem;
    } catch (e) {
      // Item processing failed, return null to skip
      return null;
    }
  }
}
