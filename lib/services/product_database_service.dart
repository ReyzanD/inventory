import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../services/database_mappers.dart';
import '../utils/database_mapper_helper.dart';

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
    // Optimize: Get all products first
    final List<Map<String, dynamic>> maps = await db.query(tableProducts);

    if (maps.isEmpty) return [];

    // Optimize: Get all components in one query instead of N queries (fix N+1 problem)
    final List<String> productIds = maps.map((m) => m['id'] as String).toList();
    final placeholders = productIds.map((_) => '?').join(',');

    final List<Map<String, dynamic>> allComponentMaps = await db.query(
      'product_components',
      where: "productId IN ($placeholders)",
      whereArgs: productIds,
    );

    // Group components by productId for O(1) lookup
    final Map<String, List<Map<String, dynamic>>> componentsByProductId = {};
    for (var componentMap in allComponentMaps) {
      final productId = componentMap['productId'] as String;
      componentsByProductId.putIfAbsent(productId, () => []).add(componentMap);
    }

    // Build products list with pre-fetched components
    return DatabaseMapperHelper.mapToProducts(maps, componentsByProductId);
  }

  /// Get products with pagination
  Future<List<Product>> getProductsPaginated({
    int limit = 50,
    int offset = 0,
    String? category,
    String? orderBy,
    bool ascending = false,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    // Get products with pagination
    final List<Map<String, dynamic>> maps = await db.query(
      tableProducts,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy ?? 'dateCreated ${ascending ? 'ASC' : 'DESC'}',
      limit: limit,
      offset: offset,
    );

    if (maps.isEmpty) return [];

    // Optimize: Get all components in one query
    final List<String> productIds = maps.map((m) => m['id'] as String).toList();
    final placeholders = productIds.map((_) => '?').join(',');

    final List<Map<String, dynamic>> allComponentMaps = await db.query(
      'product_components',
      where: "productId IN ($placeholders)",
      whereArgs: productIds,
    );

    // Group components by productId
    final Map<String, List<Map<String, dynamic>>> componentsByProductId = {};
    for (var componentMap in allComponentMaps) {
      final productId = componentMap['productId'] as String;
      componentsByProductId.putIfAbsent(productId, () => []).add(componentMap);
    }

    // Build products list
    return DatabaseMapperHelper.mapToProducts(maps, componentsByProductId);
  }

  /// Get products count
  Future<int> getProductsCount({String? category}) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableProducts WHERE $whereClause',
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return (result.first['count'] as int?) ?? 0;
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
