import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import 'inventory_database_service.dart';
import 'product_database_service.dart';

class LocalDatabaseService {
  static const _databaseName = "InventoryManagement.db";
  static const _databaseVersion = 1;

  static const String tableInventory = "inventory";
  static const String tableProducts = "products";

  Database? _database;
  late InventoryDatabaseService _inventoryService;
  late ProductDatabaseService _productService;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    _inventoryService = InventoryDatabaseService(_database!);
    _productService = ProductDatabaseService(_database!);
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
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
    await _inventoryService.insertInventoryItem(item);
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _inventoryService.updateInventoryItem(item);
  }

  Future<void> deleteInventoryItem(String id) async {
    await _inventoryService.deleteInventoryItem(id);
  }

  Future<List<InventoryItem>> getAllInventoryItems() async {
    return await _inventoryService.getAllInventoryItems();
  }

  Future<InventoryItem?> getInventoryItemById(String id) async {
    return await _inventoryService.getInventoryItemById(id);
  }

  // Product methods
  Future<void> insertProduct(Product product) async {
    await _productService.insertProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _productService.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
  }

  Future<List<Product>> getAllProducts() async {
    return await _productService.getAllProducts();
  }

  Future<Product?> getProductById(String id) async {
    return await _productService.getProductById(id);
  }
}
