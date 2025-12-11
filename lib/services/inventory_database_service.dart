import 'package:sqflite/sqflite.dart';
import '../models/inventory_item.dart';
import '../services/database_mappers.dart';
import '../utils/database_mapper_helper.dart';

class InventoryDatabaseService {
  static const String tableInventory = "inventory";

  final Database db;

  InventoryDatabaseService(this.db);

  Future<void> insertInventoryItem(InventoryItem item) async {
    await db.insert(tableInventory, item.toMap());
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await db.update(
      tableInventory,
      item.toMap(),
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  Future<void> deleteInventoryItem(String id) async {
    await db.delete(tableInventory, where: "id = ?", whereArgs: [id]);
  }

  Future<List<InventoryItem>> getAllInventoryItems() async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableInventory,
      orderBy: 'dateAdded DESC', // Default ordering for consistency
    );

    return DatabaseMapperHelper.mapToInventoryItems(maps);
  }

  /// Get inventory items with pagination
  Future<List<InventoryItem>> getInventoryItemsPaginated({
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

    final List<Map<String, dynamic>> maps = await db.query(
      tableInventory,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy ?? 'dateAdded ${ascending ? 'ASC' : 'DESC'}',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return DatabaseMappers.mapToInventoryItem(maps[i]);
    });
  }

  /// Get inventory items count
  Future<int> getInventoryItemsCount({String? category}) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableInventory WHERE $whereClause',
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return (result.first['count'] as int?) ?? 0;
  }

  Future<InventoryItem?> getInventoryItemById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableInventory,
      where: "id = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DatabaseMappers.mapToInventoryItem(maps.first);
    }
    return null;
  }
}
