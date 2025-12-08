import 'package:sqflite/sqflite.dart';
import '../models/inventory_item.dart';
import '../services/database_mappers.dart';

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
    final List<Map<String, dynamic>> maps = await db.query(tableInventory);

    return List.generate(maps.length, (i) {
      return DatabaseMappers.mapToInventoryItem(maps[i]);
    });
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
