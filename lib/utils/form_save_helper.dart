import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../utils/validation_utils.dart';
import '../utils/error_handler.dart';
import 'package:uuid/uuid.dart';

/// Helper utility for saving form data with consistent error handling
/// Extracted from long methods in add screens
class FormSaveHelper {
  /// Save inventory item with retry logic
  static Future<bool> saveInventoryItem({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required InventoryItem? existingItem,
    required String name,
    required String description,
    required String quantity,
    required String unit,
    required String costPerUnit,
    required String sellingPrice,
    required String category,
    required String lowStockThreshold,
    required DateTime? expiryDate,
    required Future<void> Function(InventoryItem) saveFunction,
    String successMessage = 'Inventory item saved successfully',
  }) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      final item = existingItem != null
          ? InventoryItem(
              id: existingItem.id,
              name: ValidationUtils.sanitizeString(name),
              description: ValidationUtils.sanitizeString(description),
              quantity: double.parse(quantity),
              unit: unit,
              costPerUnit: double.parse(costPerUnit),
              sellingPricePerUnit: double.parse(sellingPrice),
              dateAdded: existingItem.dateAdded,
              category: category,
              lowStockThreshold: double.parse(lowStockThreshold),
              expiryDate: expiryDate,
            )
          : InventoryItem(
              id: Uuid().v4(),
              name: ValidationUtils.sanitizeString(name),
              description: ValidationUtils.sanitizeString(description),
              quantity: double.parse(quantity),
              unit: unit,
              costPerUnit: double.parse(costPerUnit),
              sellingPricePerUnit: double.parse(sellingPrice),
              dateAdded: DateTime.now(),
              category: category,
              lowStockThreshold: double.parse(lowStockThreshold),
              expiryDate: expiryDate,
            );

      await saveFunction(item);

      ErrorHandler.showSuccessSnackBar(context, successMessage);
      return true;
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        customMessage: 'Failed to save inventory item',
        onRetry: () async {
          // Retry using the same helper
          await saveInventoryItem(
            context: context,
            formKey: formKey,
            existingItem: existingItem,
            name: name,
            description: description,
            quantity: quantity,
            unit: unit,
            costPerUnit: costPerUnit,
            sellingPrice: sellingPrice,
            category: category,
            lowStockThreshold: lowStockThreshold,
            expiryDate: expiryDate,
            saveFunction: saveFunction,
            successMessage: successMessage,
          );
        },
      );
      return false;
    }
  }

  /// Save product with retry logic
  static Future<bool> saveProduct({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required Product? existingProduct,
    required String name,
    required String description,
    required String sellingPrice,
    required String category,
    required List<ProductComponent> components,
    required Future<void> Function(Product) saveFunction,
    String successMessage = 'Product saved successfully',
  }) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      final product = existingProduct != null
          ? Product(
              id: existingProduct.id,
              name: ValidationUtils.sanitizeString(name),
              description: ValidationUtils.sanitizeString(description),
              sellingPrice: double.parse(sellingPrice),
              components: components,
              dateCreated: existingProduct.dateCreated,
              category: category,
            )
          : Product(
              id: Uuid().v4(),
              name: ValidationUtils.sanitizeString(name),
              description: ValidationUtils.sanitizeString(description),
              sellingPrice: double.parse(sellingPrice),
              components: components,
              dateCreated: DateTime.now(),
              category: category,
            );

      await saveFunction(product);

      ErrorHandler.showSuccessSnackBar(context, successMessage);
      return true;
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        customMessage: 'Failed to save product',
        onRetry: () async {
          // Retry using the same helper
          await saveProduct(
            context: context,
            formKey: formKey,
            existingProduct: existingProduct,
            name: name,
            description: description,
            sellingPrice: sellingPrice,
            category: category,
            components: components,
            saveFunction: saveFunction,
            successMessage: successMessage,
          );
        },
      );
      return false;
    }
  }
}
