import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../services/database_mappers.dart';

class ProductDatabaseService {
  static const String tableProducts = "products";

  final Database db;

  ProductDatabaseService(this.db);

  Future<void> insertProduct(Product product) async {
    await db.transaction((txn) async {
      // Insert product (excluding components from product map)
      var productMap = product.toMap();
      // Remove components list from product map since they're stored separately
      productMap.remove('components');

      await txn.insert(tableProducts, productMap);

      // Insert components
      for (final component in product.components) {
        await txn.insert(
          'product_components',
          DatabaseMappers.productComponentToMap(product.id, component),
        );
      }
    });
  }

  Future<void> updateProduct(Product product) async {
    await db.transaction((txn) async {
      // Delete existing components
      await txn.delete(
        'product_components',
        where: "productId = ?",
        whereArgs: [product.id],
      );

      // Update product (excluding components from product map)
      var productMap = product.toMap();
      // Remove components list from product map since they're stored separately
      productMap.remove('components');

      await txn.update(
        tableProducts,
        productMap,
        where: "id = ?",
        whereArgs: [product.id],
      );

      // Insert new components
      for (final component in product.components) {
        await txn.insert(
          'product_components',
          DatabaseMappers.productComponentToMap(product.id, component),
        );
      }
    });
  }

  Future<void> deleteProduct(String id) async {
    await db.transaction((txn) async {
      // Delete components first
      await txn.delete(
        'product_components',
        where: "productId = ?",
        whereArgs: [id],
      );
      // Then delete product
      await txn.delete(tableProducts, where: "id = ?", whereArgs: [id]);
    });
  }

  Future<List<Product>> getAllProducts() async {
    final List<Map<String, dynamic>> maps = await db.query(tableProducts);

    List<Product> products = [];
    for (var map in maps) {
      // Get components for this product
      final List<Map<String, dynamic>> componentMaps = await db.query(
        'product_components',
        where: "productId = ?",
        whereArgs: [map['id']],
      );

      products.add(DatabaseMappers.mapToProduct(map, componentMaps));
    }

    return products;
  }

  Future<Product?> getProductById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableProducts,
      where: "id = ?",
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    // Get components for this product
    final List<Map<String, dynamic>> componentMaps = await db.query(
      'product_components',
      where: "productId = ?",
      whereArgs: [id],
    );

    return DatabaseMappers.mapToProduct(maps.first, componentMaps);
  }
}
