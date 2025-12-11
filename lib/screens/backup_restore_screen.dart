import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventory/services/backup_restore_service.dart';
import 'package:inventory/providers/inventory_provider.dart';
import '../utils/error_handler.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final BackupRestoreService _backupService = BackupRestoreService();
  bool _isExporting = false;
  bool _isImporting = false;
  String _statusMessage = '';
  Color _statusColor = Colors.grey;

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Exporting data...';
      _statusColor = Colors.blue;
    });

    try {
      final provider = context.read<InventoryProvider>();

      // Get current data using export methods
      final items = provider.getExportableInventoryItems();
      final products = provider.getExportableProducts();

      // Create CSV content
      final inventoryCsv = await _backupService.exportInventoryToCsv(items);
      final productsCsv = await _backupService.exportProductsToCsv(products);

      // In a real app, you would save these to files and possibly zip them
      // For now, let's just show a simple dialog with the CSV content
      await _showExportResult(inventoryCsv, productsCsv);

      setState(() {
        _statusMessage = 'Export completed successfully!';
        _statusColor = Colors.green;
      });
    } catch (e) {
      final errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      setState(() {
        _statusMessage = 'Export failed: $errorMessage';
        _statusColor = Colors.red;
      });
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        customMessage: 'Failed to export data',
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _showExportResult(
    String inventoryCsv,
    String productsCsv,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Data'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              children: [
                const Text('Inventory Data:'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      inventoryCsv,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Products Data:'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      productsCsv,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Please select a CSV file to import...';
      _statusColor = Colors.blue;
    });

    try {
      // In a real implementation, you would open a file picker dialog
      // For now, simulate with sample CSV data
      final sampleInventoryCsv =
          '''ID,Name,Description,Quantity,Unit,Cost Per Unit,Selling Price Per Unit,Date Added,Category,Low Stock Threshold,Expiry Date
1,Sample Item,Test item,10.0,pcs,2.0,3.0,1697000000000,Test Category,5.0,
2,Another Item,Another test,5.0,kg,1.5,2.5,1697000000000,Test Category,3.0,''';

      final sampleProductsCsv =
          '''Product ID,Name,Description,Selling Price,Date Created,Category,Components
1,Sample Product,Test product,15.0,1697000000000,Test Category,1:2.0:kg''';

      // Validate CSV
      if (!_backupService.validateInventoryCsv(sampleInventoryCsv)) {
        throw Exception('Invalid inventory CSV format');
      }

      if (!_backupService.validateProductCsv(sampleProductsCsv)) {
        throw Exception('Invalid products CSV format');
      }

      // Parse CSV
      final importedItems = _backupService.importInventoryFromCsv(
        sampleInventoryCsv,
      );
      final importedProducts = _backupService.importProductsFromCsv(
        sampleProductsCsv,
      );

      // Add to provider (this would need update methods in the provider)
      // For now, just showing the imported data
      final provider = context.read<InventoryProvider>();

      // Import items and products using the new provider methods
      await provider.importInventoryItems(importedItems);
      await provider.importProducts(importedProducts);

      setState(() {
        _statusMessage =
            'Import completed successfully! Added ${importedItems.length} items and ${importedProducts.length} products.';
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Import failed: $e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Export your inventory and product data to CSV files for safekeeping or transfer to another system.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportData,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      label: const Text('Export Data'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restore Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Import data from CSV files to restore your inventory and products.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isImporting ? null : _importData,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: const Text('Import Data'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(color: _statusColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
