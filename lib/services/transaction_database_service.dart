import 'package:sqflite/sqflite.dart';
import '../models/inventory_transaction.dart';
import '../utils/type_converter.dart';
import '../utils/database_mapper_helper.dart';
import 'local_database_service.dart';

class TransactionDatabaseService {
  final Database _database;

  TransactionDatabaseService(this._database);

  /// Insert a new transaction
  Future<void> insertTransaction(InventoryTransaction transaction) async {
    await _database.insert(
      LocalDatabaseService.tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all transactions
  Future<List<InventoryTransaction>> getAllTransactions() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      LocalDatabaseService.tableTransactions,
      orderBy: 'timestamp DESC',
    );

    return DatabaseMapperHelper.mapToTransactions(maps);
  }

  /// Get transactions by item ID
  Future<List<InventoryTransaction>> getTransactionsByItemId(
    String itemId,
  ) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      LocalDatabaseService.tableTransactions,
      where: 'inventoryItemId = ?',
      whereArgs: [itemId],
      orderBy: 'timestamp DESC',
    );

    return DatabaseMapperHelper.mapToTransactions(maps);
  }

  /// Get transactions by type
  Future<List<InventoryTransaction>> getTransactionsByType(
    TransactionType type,
  ) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      LocalDatabaseService.tableTransactions,
      where: 'type = ?',
      whereArgs: [type.index],
      orderBy: 'timestamp DESC',
    );

    return DatabaseMapperHelper.mapToTransactions(maps);
  }

  /// Get transactions by date range
  Future<List<InventoryTransaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      LocalDatabaseService.tableTransactions,
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );

    return DatabaseMapperHelper.mapToTransactions(maps);
  }

  /// Get transactions with pagination
  Future<List<InventoryTransaction>> getTransactionsPaginated({
    int limit = 50,
    int offset = 0,
    String? itemId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (itemId != null) {
      whereClause += ' AND inventoryItemId = ?';
      whereArgs.add(itemId);
    }

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.index);
    }

    if (startDate != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final List<Map<String, dynamic>> maps = await _database.query(
      LocalDatabaseService.tableTransactions,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return DatabaseMapperHelper.mapToTransactions(maps);
  }

  /// Get transaction count
  Future<int> getTransactionCount({
    String? itemId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (itemId != null) {
      whereClause += ' AND inventoryItemId = ?';
      whereArgs.add(itemId);
    }

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.index);
    }

    if (startDate != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND timestamp <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM ${LocalDatabaseService.tableTransactions} WHERE $whereClause',
      whereArgs.isNotEmpty ? whereArgs : null,
    );

    return TypeConverter.toInt(result.first['count'], 0);
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _database.delete(
      LocalDatabaseService.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all transactions
  Future<void> clearAllTransactions() async {
    await _database.delete(LocalDatabaseService.tableTransactions);
  }
}
