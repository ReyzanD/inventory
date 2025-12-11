import 'package:logging/logging.dart';
import '../models/inventory_transaction.dart';
import 'local_database_service.dart';

class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  final _logger = Logger('AuditService');
  final LocalDatabaseService _databaseService = LocalDatabaseService();
  bool _initialized = false;

  /// Initialize the audit service and load existing transactions
  Future<void> initialize() async {
    if (_initialized) return;
    await _databaseService.database; // Ensure database is initialized
    _initialized = true;
    _logger.info('AuditService initialized with database persistence');
  }

  /// Get all transactions from database
  Future<List<InventoryTransaction>> get auditTrail async {
    await initialize();
    final service = await _databaseService.transactionService;
    return await service.getAllTransactions();
  }

  /// Log a transaction to the database
  Future<void> logTransaction({
    required String inventoryItemId,
    required String itemName,
    required TransactionType type,
    required double quantity,
    required String unit,
    String? reason,
    String? userId,
  }) async {
    await initialize();

    final transaction = InventoryTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      inventoryItemId: inventoryItemId,
      itemName: itemName,
      type: type,
      quantity: quantity,
      unit: unit,
      reason: reason,
      timestamp: DateTime.now(),
      userId: userId,
    );

    try {
      final service = await _databaseService.transactionService;
      await service.insertTransaction(transaction);
      _logger.info(
        'Audit log: ${transaction.getTypeDisplay()} ${transaction.quantity} ${transaction.unit} of ${transaction.itemName}',
      );
    } catch (e) {
      _logger.severe('Error logging transaction: $e');
      rethrow;
    }
  }

  /// Clear all transactions from database
  Future<void> clearAuditTrail() async {
    await initialize();
    final service = await _databaseService.transactionService;
    await service.clearAllTransactions();
    _logger.info('Audit trail cleared');
  }

  /// Get transactions by item ID
  Future<List<InventoryTransaction>> getTransactionsByItemId(
    String itemId,
  ) async {
    await initialize();
    final service = await _databaseService.transactionService;
    return await service.getTransactionsByItemId(itemId);
  }

  /// Get transactions by type
  Future<List<InventoryTransaction>> getTransactionsByType(
    TransactionType type,
  ) async {
    await initialize();
    final service = await _databaseService.transactionService;
    return await service.getTransactionsByType(type);
  }

  /// Get transactions by date range
  Future<List<InventoryTransaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    await initialize();
    final service = await _databaseService.transactionService;
    return await service.getTransactionsByDateRange(start, end);
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
    await initialize();
    final service = await _databaseService.transactionService;
    return await service.getTransactionsPaginated(
      limit: limit,
      offset: offset,
      itemId: itemId,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get transaction count
  Future<int> getTransactionCount({
    String? itemId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await initialize();
    final service = await _databaseService.transactionService;
    return await service.getTransactionCount(
      itemId: itemId,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
