import 'package:inventory/models/inventory_item.dart';
import 'package:inventory/models/product.dart';
import 'package:rxdart/rxdart.dart';

enum SortOrder { ascending, descending }

enum SortField { name, quantity, dateAdded, category }

class SearchFilterService {
  // Debounce time for search input
  static const Duration debounceDuration = Duration(milliseconds: 300);

  // For debouncing search input
  final BehaviorSubject<String> _searchSubject = BehaviorSubject.seeded('');

  Stream<String> get searchStream => _searchSubject.stream;

  void setSearchQuery(String query) {
    _searchSubject.add(query.toLowerCase().trim());
  }

  // Filter and sort inventory items
  List<InventoryItem> filterAndSortInventoryItems({
    required List<InventoryItem> items,
    String? searchQuery,
    String? categoryFilter,
    SortField sortField = SortField.name,
    SortOrder sortOrder = SortOrder.ascending,
  }) {
    var filteredItems = List<InventoryItem>.from(items);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final lowerQuery = searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(lowerQuery) ||
            item.description.toLowerCase().contains(lowerQuery) ||
            item.category.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Apply category filter
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.category.toLowerCase().contains(
          categoryFilter.toLowerCase(),
        );
      }).toList();
    }

    // Apply sorting
    filteredItems.sort((a, b) {
      int compare;
      switch (sortField) {
        case SortField.name:
          compare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortField.quantity:
          compare = a.quantity.compareTo(b.quantity);
          break;
        case SortField.dateAdded:
          compare = a.dateAdded.compareTo(b.dateAdded);
          break;
        case SortField.category:
          compare = a.category.toLowerCase().compareTo(
            b.category.toLowerCase(),
          );
          break;
      }

      return sortOrder == SortOrder.ascending ? compare : -compare;
    });

    return filteredItems;
  }

  // Filter and sort products
  List<Product> filterAndSortProducts({
    required List<Product> products,
    String? searchQuery,
    String? categoryFilter,
    SortField sortField = SortField.name,
    SortOrder sortOrder = SortOrder.ascending,
  }) {
    var filteredProducts = List<Product>.from(products);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      filteredProducts = filteredProducts.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
            product.description.toLowerCase().contains(lowerQuery) ||
            product.category.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Apply category filter
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      final lowerCategory = categoryFilter.toLowerCase();
      filteredProducts = filteredProducts.where((product) {
        return product.category.toLowerCase().contains(lowerCategory);
      }).toList();
    }

    // Apply sorting
    filteredProducts.sort((a, b) {
      int compare;
      switch (sortField) {
        case SortField.name:
          compare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortField.dateAdded:
          compare = a.dateCreated.compareTo(b.dateCreated);
          break;
        case SortField.category:
          compare = a.category.toLowerCase().compareTo(
            b.category.toLowerCase(),
          );
          break;
        case SortField.quantity: // Treat quantity as selling price for products
          compare = a.sellingPrice.compareTo(b.sellingPrice);
          break;
      }

      return sortOrder == SortOrder.ascending ? compare : -compare;
    });

    return filteredProducts;
  }

  void dispose() {
    _searchSubject.close();
  }
}
