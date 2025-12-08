import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';

class LocalDatabaseService {
  static const _databaseName = "InventoryManagement.db";
  static const _databaseVersion = 1;

  static const String tableInventory = "inventory";
  static const String tableProducts = "products";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // Create inventory table
    await db.execute('''
      CREATE TABLE $tableInventory (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        costPerUnit REAL NOT NULL,
        sellingPricePerUnit REAL NOT NULL,
        dateAdded INTEGER NOT NULL,
        category TEXT
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE $tableProducts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        sellingPrice REAL NOT NULL,
        dateCreated INTEGER NOT NULL,
        category TEXT
      )
    ''');

    // Create product components table
    await db.execute('''
      CREATE TABLE product_components (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        inventoryItemId TEXT NOT NULL,
        quantityNeeded REAL NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES $tableProducts(id),
        FOREIGN KEY (inventoryItemId) REFERENCES $tableProducts(id)
      )
    ''');
  }

  // Inventory Item methods
  Future<void> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    await db.insert(tableInventory, item.toMap());
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    await db.update(tableInventory, item.toMap(),
        where: "id = ?", whereArgs: [item.id]);
  }

  Future<void> deleteInventoryItem(String id) async {
    final db = await database;
    await db.delete(tableInventory, where: "id = ?", whereArgs: [id]);
  }

  Future<List<InventoryItem>> getAllInventoryItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableInventory);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return InventoryItem(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        quantity: (map['quantity'] is int) ? (map['quantity'] as int).toDouble() : map['quantity']?.toDouble() ?? 0.0,
        unit: map['unit'] as String,
        costPerUnit: (map['costPerUnit'] is int) ? (map['costPerUnit'] as int).toDouble() : map['costPerUnit']?.toDouble() ?? 0.0,
        sellingPricePerUnit: (map['sellingPricePerUnit'] is int) ? (map['sellingPricePerUnit'] as int).toDouble() : map['sellingPricePerUnit']?.toDouble() ?? 0.0,
        dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int),
        category: map['category'] as String,
      );
    });
  }

  Future<InventoryItem?> getInventoryItemById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableInventory,
      where: "id = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return InventoryItem(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        quantity: (map['quantity'] is int) ? (map['quantity'] as int).toDouble() : map['quantity']?.toDouble() ?? 0.0,
        unit: map['unit'] as String,
        costPerUnit: (map['costPerUnit'] is int) ? (map['costPerUnit'] as int).toDouble() : map['costPerUnit']?.toDouble() ?? 0.0,
        sellingPricePerUnit: (map['sellingPricePerUnit'] is int) ? (map['sellingPricePerUnit'] as int).toDouble() : map['sellingPricePerUnit']?.toDouble() ?? 0.0,
        dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int),
        category: map['category'] as String,
      );
    }
    return null;
  }

  // Product methods
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insert product (excluding components from product map)
      var productMap = product.toMap();
      // Remove components list from product map since they're stored separately
      productMap.remove('components');

      await txn.insert(tableProducts, productMap);

      // Insert components
      for (final component in product.components) {
        await txn.insert('product_components', {
          'productId': product.id,
          'inventoryItemId': component.inventoryItemId,
          'quantityNeeded': component.quantityNeeded,
          'unit': component.unit,
        });
      }
    });
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete existing components
      await txn.delete('product_components', where: "productId = ?", whereArgs: [product.id]);

      // Update product (excluding components from product map)
      var productMap = product.toMap();
      // Remove components list from product map since they're stored separately
      productMap.remove('components');

      await txn.update(tableProducts, productMap,
          where: "id = ?", whereArgs: [product.id]);

      // Insert new components
      for (final component in product.components) {
        await txn.insert('product_components', {
          'productId': product.id,
          'inventoryItemId': component.inventoryItemId,
          'quantityNeeded': component.quantityNeeded,
          'unit': component.unit,
        });
      }
    });
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete components first
      await txn.delete('product_components', where: "productId = ?", whereArgs: [id]);
      // Then delete product
      await txn.delete(tableProducts, where: "id = ?", whereArgs: [id]);
    });
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableProducts);

    List<Product> products = [];
    for (var map in maps) {
      // Get components for this product
      final List<Map<String, dynamic>> componentMaps = await db.query(
        'product_components',
        where: "productId = ?",
        whereArgs: [map['id']],
      );

      List<ProductComponent> components = componentMaps.map((comp) {
        return ProductComponent(
          inventoryItemId: comp['inventoryItemId'],
          quantityNeeded: comp['quantityNeeded'],
          unit: comp['unit'],
        );
      }).toList();

      products.add(Product(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        sellingPrice: (map['sellingPrice'] is int) ? (map['sellingPrice'] as int).toDouble() : map['sellingPrice']?.toDouble() ?? 0.0,
        components: components,
        dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
        category: map['category'] as String,
      ));
    }

    return products;
  }

  Future<Product?> getProductById(String id) async {
    final db = await database;
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

    List<ProductComponent> components = componentMaps.map((comp) {
      return ProductComponent(
        inventoryItemId: comp['inventoryItemId'] as String,
        quantityNeeded: (comp['quantityNeeded'] is int) ? (comp['quantityNeeded'] as int).toDouble() : comp['quantityNeeded']?.toDouble() ?? 0.0,
        unit: comp['unit'] as String,
      );
    }).toList();

    final map = maps.first;
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      sellingPrice: (map['sellingPrice'] is int) ? (map['sellingPrice'] as int).toDouble() : map['sellingPrice']?.toDouble() ?? 0.0,
      components: components,
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
      category: map['category'] as String,
    );
  }
}