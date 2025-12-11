import '../models/inventory_item.dart';
import '../models/product.dart';

/// Generic sorting utility for inventory items and products
class SortHelper {
  /// Sort inventory items based on sort option
  static List<InventoryItem> sortInventoryItems(
    List<InventoryItem> items,
    String sortOption,
  ) {
    final sorted = List<InventoryItem>.from(items);

    switch (sortOption) {
      case 'Name A-Z':
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'Name Z-A':
        sorted.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case 'Quantity High-Low':
        sorted.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'Quantity Low-High':
        sorted.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'Date Added (Newest)':
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'Date Added (Oldest)':
        sorted.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case 'Price High-Low':
        sorted.sort(
          (a, b) => b.sellingPricePerUnit.compareTo(a.sellingPricePerUnit),
        );
        break;
      case 'Price Low-High':
        sorted.sort(
          (a, b) => a.sellingPricePerUnit.compareTo(b.sellingPricePerUnit),
        );
        break;
      default:
        // Default: Name A-Z
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return sorted;
  }

  /// Sort products based on sort option
  static List<Product> sortProducts(List<Product> products, String sortOption) {
    final sorted = List<Product>.from(products);

    switch (sortOption) {
      case 'Name A-Z':
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'Name Z-A':
        sorted.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case 'Price High-Low':
        sorted.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'Price Low-High':
        sorted.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case 'Date Added (Newest)':
        sorted.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        break;
      case 'Date Added (Oldest)':
        sorted.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      default:
        // Default: Name A-Z
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return sorted;
  }
}
