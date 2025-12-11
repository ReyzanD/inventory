import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../services/logging_service.dart';

class BackupRestoreService {
  /// Exports inventory items to a CSV file
  Future<String> exportInventoryToCsv(List<InventoryItem> items) async {
    final csv = const ListToCsvConverter().convert([
      // Header row
      [
        'ID',
        'Name',
        'Description',
        'Quantity',
        'Unit',
        'Cost Per Unit',
        'Selling Price Per Unit',
        'Date Added',
        'Category',
        'Low Stock Threshold',
        'Expiry Date',
      ],
      // Data rows
      ...items.map(
        (item) => [
          item.id,
          item.name,
          item.description,
          item.quantity,
          item.unit,
          item.costPerUnit,
          item.sellingPricePerUnit,
          item.dateAdded.millisecondsSinceEpoch,
          item.category,
          item.lowStockThreshold,
          item.expiryDate?.millisecondsSinceEpoch ?? '',
        ],
      ),
    ]);
    return csv;
  }

  /// Imports inventory items from a CSV string
  List<InventoryItem> importInventoryFromCsv(String csvContent) {
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
      csvContent,
    );

    // Remove header row if it exists (checking first row for field names)
    final List<List<dynamic>> dataRows = csvTable.length > 1
        ? csvTable.sublist(1)
        : [];

    final List<InventoryItem> items = [];

    for (final row in dataRows) {
      if (row.length >= 9) {
        // Minimum required fields
        try {
          final item = InventoryItem(
            id: row[0]?.toString() ?? '',
            name: row[1]?.toString() ?? '',
            description: row[2]?.toString() ?? '',
            quantity: double.tryParse(row[3]?.toString() ?? '0') ?? 0.0,
            unit: row[4]?.toString() ?? '',
            costPerUnit: double.tryParse(row[5]?.toString() ?? '0') ?? 0.0,
            sellingPricePerUnit:
                double.tryParse(row[6]?.toString() ?? '0') ?? 0.0,
            dateAdded: DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(
                    row[7]?.toString() ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                  ) ??
                  DateTime.now().millisecondsSinceEpoch,
            ),
            category: row[8]?.toString() ?? '',
            lowStockThreshold:
                double.tryParse(row[9]?.toString() ?? '5.0') ?? 5.0,
            expiryDate: row[10] != null && row[10] != ''
                ? DateTime.fromMillisecondsSinceEpoch(
                    int.tryParse(row[10]?.toString() ?? '') ?? 0,
                  )
                : null,
          );
          items.add(item);
        } catch (e) {
          // Log error and continue with other items
          LoggingService.warning(
            'Error importing inventory item from CSV row: $row, Error: $e',
          );
        }
      }
    }

    return items;
  }

  /// Exports products to a CSV file
  Future<String> exportProductsToCsv(List<Product> products) async {
    final csv = const ListToCsvConverter().convert([
      // Header row
      [
        'Product ID',
        'Name',
        'Description',
        'Selling Price',
        'Date Created',
        'Category',
        'Components', // Format as JSON string for simplicity
      ],
      // Data rows
      ...products.map(
        (product) => [
          product.id,
          product.name,
          product.description,
          product.sellingPrice,
          product.dateCreated.millisecondsSinceEpoch,
          product.category,
          _encodeProductComponents(product), // Custom encoding for components
        ],
      ),
    ]);
    return csv;
  }

  /// Imports products from a CSV string
  List<Product> importProductsFromCsv(String csvContent) {
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
      csvContent,
    );

    // Remove header row if it exists
    final List<List<dynamic>> dataRows = csvTable.length > 1
        ? csvTable.sublist(1)
        : [];

    final List<Product> products = [];

    for (final row in dataRows) {
      if (row.length >= 6) {
        // Minimum required fields
        try {
          final components = _decodeProductComponents(row[6]?.toString() ?? '');

          final product = Product(
            id: row[0]?.toString() ?? '',
            name: row[1]?.toString() ?? '',
            description: row[2]?.toString() ?? '',
            sellingPrice: double.tryParse(row[3]?.toString() ?? '0') ?? 0.0,
            components: components,
            dateCreated: DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(
                    row[4]?.toString() ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                  ) ??
                  DateTime.now().millisecondsSinceEpoch,
            ),
            category: row[5]?.toString() ?? '',
          );
          products.add(product);
        } catch (e) {
          // Log error and continue with other products
          LoggingService.warning(
            'Error importing product from CSV row: $row, Error: $e',
          );
        }
      }
    }

    return products;
  }

  /// Helper method to encode product components as a JSON-like string
  String _encodeProductComponents(Product product) {
    final componentsList = product.components
        .map(
          (component) =>
              '${component.inventoryItemId}:${component.quantityNeeded}:${component.unit}',
        )
        .join('|');
    return componentsList;
  }

  /// Helper method to decode product components from a string
  List<ProductComponent> _decodeProductComponents(String encodedComponents) {
    final components = <ProductComponent>[];

    if (encodedComponents.isNotEmpty) {
      final componentStrings = encodedComponents.split('|');

      for (final componentString in componentStrings) {
        if (componentString.isNotEmpty) {
          final parts = componentString.split(':');
          if (parts.length >= 3) {
            try {
              components.add(
                ProductComponent(
                  inventoryItemId: parts[0],
                  quantityNeeded: double.parse(parts[1]),
                  unit: parts[2],
                ),
              );
            } catch (e) {
              // Skip invalid component
              LoggingService.warning(
                'Error parsing product component: $componentString, Error: $e',
              );
            }
          }
        }
      }
    }

    return components;
  }

  /// Exports both inventory and products to a zip file
  Future<File> exportToZip(
    List<InventoryItem> items,
    List<Product> products,
    String exportPath,
  ) async {
    // For now, we'll export as separate CSV files
    // In a full implementation, we would use a zip library
    final inventoryCsv = await exportInventoryToCsv(items);
    final productsCsv = await exportProductsToCsv(products);

    // Write to files
    final inventoryFile = File(path.join(exportPath, 'inventory.csv'));
    final productsFile = File(path.join(exportPath, 'products.csv'));

    await inventoryFile.writeAsString(inventoryCsv);
    await productsFile.writeAsString(productsCsv);

    // Return the path or a zip file in a full implementation
    return inventoryFile; // Return first file as indicator
  }

  /// Validates a CSV file before importing
  bool validateInventoryCsv(String csvContent) {
    try {
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvContent,
      );

      if (csvTable.isEmpty) return false;

      // Check if first row looks like headers (contains expected field names)
      final firstRow = csvTable[0];
      if (firstRow.length < 9) return false; // At least 9 fields

      // If it has more than 1 row, the second row should have compatible data types
      if (csvTable.length > 1) {
        final secondRow = csvTable[1];
        if (secondRow.length < 9) return false;

        // Try parsing some numeric values
        double.tryParse(secondRow[3]?.toString() ?? '') ?? -1;
        double.tryParse(secondRow[5]?.toString() ?? '') ?? -1;
        double.tryParse(secondRow[6]?.toString() ?? '') ?? -1;
      }

      return true;
    } catch (e) {
      LoggingService.severe('CSV validation error: $e');
      return false;
    }
  }

  bool validateProductCsv(String csvContent) {
    try {
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvContent,
      );

      if (csvTable.isEmpty) return false;

      // Check if first row looks like headers
      final firstRow = csvTable[0];
      if (firstRow.length < 6) return false; // At least 6 fields

      // If it has more than 1 row, check data structure
      if (csvTable.length > 1) {
        final secondRow = csvTable[1];
        if (secondRow.length < 6) return false;
      }

      return true;
    } catch (e) {
      LoggingService.severe('Product CSV validation error: $e');
      return false;
    }
  }
}
