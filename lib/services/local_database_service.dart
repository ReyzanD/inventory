import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import 'inventory_database_service.dart';
import 'product_database_service.dart';
import 'transaction_database_service.dart';

class LocalDatabaseService {
  static const _databaseName = "InventoryManagement.db";
  static const _databaseVersion = 4;

  static const String tableInventory = "inventory";
  static const String tableProducts = "products";
  static const String tableTransactions = "inventory_transactions";

  Database? _database;
  late InventoryDatabaseService _inventoryService;
  late ProductDatabaseService _productService;
  late TransactionDatabaseService _transactionService;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    _inventoryService = InventoryDatabaseService(_database!);
    _productService = ProductDatabaseService(_database!);
    _transactionService = TransactionDatabaseService(_database!);
    return _database!;
  }

  Future<TransactionDatabaseService> get transactionService async {
    await database; // Ensure database and services are initialized
    return _transactionService;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        category TEXT,
        lowStockThreshold REAL NOT NULL DEFAULT 5,
        expiryDate INTEGER
      )
    ''');

    // Create indexes for inventory table to optimize queries
    await db.execute('''
      CREATE INDEX idx_inventory_category ON $tableInventory(category)
    ''');
    await db.execute('''
      CREATE INDEX idx_inventory_dateAdded ON $tableInventory(dateAdded)
    ''');
    await db.execute('''
      CREATE INDEX idx_inventory_name ON $tableInventory(name)
    ''');
    await db.execute('''
      CREATE INDEX idx_inventory_quantity ON $tableInventory(quantity)
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

    // Create indexes for products table to optimize queries
    await db.execute('''
      CREATE INDEX idx_products_category ON $tableProducts(category)
    ''');
    await db.execute('''
      CREATE INDEX idx_products_dateCreated ON $tableProducts(dateCreated)
    ''');
    await db.execute('''
      CREATE INDEX idx_products_name ON $tableProducts(name)
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
        FOREIGN KEY (inventoryItemId) REFERENCES $tableInventory(id)
      )
    ''');

    // Create indexes for product_components table
    await db.execute('''
      CREATE INDEX idx_components_productId ON product_components(productId)
    ''');
    await db.execute('''
      CREATE INDEX idx_components_inventoryItemId ON product_components(inventoryItemId)
    ''');

    // Create inventory transactions table for audit trail
    await db.execute('''
      CREATE TABLE $tableTransactions (
        id TEXT PRIMARY KEY,
        inventoryItemId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        type INTEGER NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        reason TEXT,
        timestamp INTEGER NOT NULL,
        userId TEXT,
        FOREIGN KEY (inventoryItemId) REFERENCES $tableInventory(id)
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_transactions_itemId ON $tableTransactions(inventoryItemId)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_timestamp ON $tableTransactions(timestamp)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_type ON $tableTransactions(type)
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableInventory ADD COLUMN LowStockThreshold REAL NOT NULL DEFAULT 5',
      );
      await db.execute(
        'ALTER TABLE $tableInventory ADD COLUMN expiryDate INTEGER',
      );
    }
    if (oldVersion < 3) {
      // Create inventory transactions table for audit trail
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTransactions (
          id TEXT PRIMARY KEY,
          inventoryItemId TEXT NOT NULL,
          itemName TEXT NOT NULL,
          type INTEGER NOT NULL,
          quantity REAL NOT NULL,
          unit TEXT NOT NULL,
          reason TEXT,
          timestamp INTEGER NOT NULL,
          userId TEXT,
          FOREIGN KEY (inventoryItemId) REFERENCES $tableInventory(id)
        )
      ''');

      // Create indexes for faster queries
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_transactions_itemId ON $tableTransactions(inventoryItemId)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_transactions_timestamp ON $tableTransactions(timestamp)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_transactions_type ON $tableTransactions(type)
      ''');
    }
    if (oldVersion < 4) {
      // Add indexes for inventory table
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_category ON $tableInventory(category)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_dateAdded ON $tableInventory(dateAdded)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_name ON $tableInventory(name)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_inventory_quantity ON $tableInventory(quantity)
      ''');

      // Add indexes for products table
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_products_category ON $tableProducts(category)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_products_dateCreated ON $tableProducts(dateCreated)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_products_name ON $tableProducts(name)
      ''');

      // Add indexes for product_components table
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_components_productId ON product_components(productId)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_components_inventoryItemId ON product_components(inventoryItemId)
      ''');
    }
  }

  // Inventory Item methods
  Future<void> insertInventoryItem(InventoryItem item) async {
    await database; // Ensure database and services are initialized
    await _inventoryService.insertInventoryItem(item);
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await database; // Ensure database and services are initialized
    await _inventoryService.updateInventoryItem(item);
  }

  Future<void> deleteInventoryItem(String id) async {
    await database; // Ensure database and services are initialized
    await _inventoryService.deleteInventoryItem(id);
  }

  Future<List<InventoryItem>> getAllInventoryItems() async {
    await database; // Ensure database and services are initialized
    return await _inventoryService.getAllInventoryItems();
  }

  Future<InventoryItem?> getInventoryItemById(String id) async {
    await database; // Ensure database and services are initialized
    return await _inventoryService.getInventoryItemById(id);
  }

  // Product methods
  Future<void> insertProduct(Product product) async {
    await database; // Ensure database and services are initialized
    await _productService.insertProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await database; // Ensure database and services are initialized
    await _productService.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await database; // Ensure database and services are initialized
    await _productService.deleteProduct(id);
  }

  Future<List<Product>> getAllProducts() async {
    await database; // Ensure database and services are initialized
    return await _productService.getAllProducts();
  }

  Future<Product?> getProductById(String id) async {
    await database; // Ensure database and services are initialized
    return await _productService.getProductById(id);
  }
}
