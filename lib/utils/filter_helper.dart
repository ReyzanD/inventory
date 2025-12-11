import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/inventory_transaction.dart';

/// Generic filtering utility for inventory items, products, and transactions
class FilterHelper {
  /// Filter inventory items by search query
  static List<InventoryItem> filterInventoryBySearch(
    List<InventoryItem> items,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return items;

    final lowerQuery = searchQuery.toLowerCase();
    return items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.description.toLowerCase().contains(lowerQuery) ||
          item.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter inventory items by category
  static List<InventoryItem> filterInventoryByCategory(
    List<InventoryItem> items,
    String category,
  ) {
    if (category.isEmpty || category == 'All') return items;

    final lowerCategory = category.toLowerCase();
    return items.where((item) {
      return item.category.toLowerCase().contains(lowerCategory);
    }).toList();
  }

  /// Filter inventory items by stock range
  static List<InventoryItem> filterInventoryByStockRange(
    List<InventoryItem> items,
    double minStock,
    double maxStock,
  ) {
    return items.where((item) {
      return item.quantity >= minStock && item.quantity <= maxStock;
    }).toList();
  }

  /// Filter inventory items by date range
  static List<InventoryItem> filterInventoryByDateRange(
    List<InventoryItem> items,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null || endDate == null) return items;

    return items.where((item) {
      return item.dateAdded.isAfter(startDate.subtract(Duration(days: 1))) &&
          item.dateAdded.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  /// Filter products by search query
  static List<Product> filterProductsBySearch(
    List<Product> products,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return products;

    final lowerQuery = searchQuery.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter products by category
  static List<Product> filterProductsByCategory(
    List<Product> products,
    String category,
  ) {
    if (category.isEmpty || category == 'All') return products;

    final lowerCategory = category.toLowerCase();
    return products.where((product) {
      return product.category.toLowerCase().contains(lowerCategory);
    }).toList();
  }

  /// Filter transactions by search query
  static List<InventoryTransaction> filterTransactionsBySearch(
    List<InventoryTransaction> transactions,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return transactions;

    final lowerQuery = searchQuery.toLowerCase();
    return transactions.where((transaction) {
      return transaction.itemName.toLowerCase().contains(lowerQuery) ||
          (transaction.reason?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter transactions by type
  static List<InventoryTransaction> filterTransactionsByType(
    List<InventoryTransaction> transactions,
    TransactionType? type,
  ) {
    if (type == null) return transactions;

    return transactions.where((transaction) {
      return transaction.type == type;
    }).toList();
  }

  /// Apply all inventory filters
  static List<InventoryItem> applyInventoryFilters({
    required List<InventoryItem> items,
    String searchQuery = '',
    String category = '',
    double? minStock,
    double? maxStock,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<InventoryItem> filtered = items;

    filtered = filterInventoryBySearch(filtered, searchQuery);
    filtered = filterInventoryByCategory(filtered, category);
    
    if (minStock != null && maxStock != null) {
      filtered = filterInventoryByStockRange(filtered, minStock, maxStock);
    }
    
    if (startDate != null && endDate != null) {
      filtered = filterInventoryByDateRange(filtered, startDate, endDate);
    }

    return filtered;
  }

  /// Apply all product filters
  static List<Product> applyProductFilters({
    required List<Product> products,
    String searchQuery = '',
    String category = '',
  }) {
    List<Product> filtered = products;

    filtered = filterProductsBySearch(filtered, searchQuery);
    filtered = filterProductsByCategory(filtered, category);

    return filtered;
  }

  /// Apply all transaction filters
  static List<InventoryTransaction> applyTransactionFilters({
    required List<InventoryTransaction> transactions,
    String searchQuery = '',
    TransactionType? type,
  }) {
    List<InventoryTransaction> filtered = transactions;

    filtered = filterTransactionsBySearch(filtered, searchQuery);
    filtered = filterTransactionsByType(filtered, type);

    return filtered;
  }
}

