import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory_transaction.dart';
import '../services/audit_service.dart';
import '../utils/error_handler.dart';
import '../utils/filter_helper.dart';
import '../widgets/empty_state_widget.dart';
import '../l10n/app_localizations.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _searchQuery = '';
  TransactionType? _selectedFilter;
  final AuditService _auditService = AuditService();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.transactionHistory),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<InventoryTransaction>>(
        future: _auditService.auditTrail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading transactions',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    ErrorHandler.getUserFriendlyMessage(snapshot.error),
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Retry by rebuilding
                    },
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            );
          }

          // Get transactions and apply filters using helper utilities
          List<InventoryTransaction> transactions =
              FilterHelper.applyTransactionFilters(
                transactions: snapshot.data ?? [],
                searchQuery: _searchQuery,
                type: _selectedFilter,
              );

          // Sort by timestamp (most recent first)
          transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Column(
            children: [
              // Search and filter bar
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PopupMenuButton<TransactionType?>(
                            initialValue: _selectedFilter,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[100],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.filter_list, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedFilter == null
                                          ? localizations.allTransactions
                                          : _getTransactionTypeString(
                                              _selectedFilter!,
                                              localizations,
                                            ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: null,
                                child: Text(localizations.allTransactions),
                              ),
                              PopupMenuItem(
                                value: TransactionType.addition,
                                child: Text(localizations.additions),
                              ),
                              PopupMenuItem(
                                value: TransactionType.deduction,
                                child: Text(localizations.deductions),
                              ),
                              PopupMenuItem(
                                value: TransactionType.transfer,
                                child: Text(localizations.transfers),
                              ),
                            ],
                            onSelected: (TransactionType? type) {
                              setState(() {
                                _selectedFilter = type;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedFilter = null;
                            });
                          },
                          child: Text(localizations.clear),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Transactions list
              Expanded(
                child: transactions.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.history,
                        title: 'No transaction history found',
                        subtitle:
                            'All your inventory transactions will appear here',
                      )
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: transaction.getColor().withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  transaction.getIcon(),
                                  color: transaction.getColor(),
                                ),
                              ),
                              title: Text(
                                transaction.itemName,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    '${transaction.getTypeDisplay()} ${transaction.quantity} ${transaction.unit}',
                                    style: TextStyle(
                                      color: transaction.getColor(),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Reason: ${transaction.reason ?? 'N/A'} • ${DateFormat('MMM dd, yyyy HH:mm').format(transaction.timestamp)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getTransactionTypeString(
    TransactionType type,
    AppLocalizations localizations,
  ) {
    switch (type) {
      case TransactionType.addition:
        return localizations.additions;
      case TransactionType.deduction:
        return localizations.deductions;
      case TransactionType.transfer:
        return localizations.transfers;
    }
  }
}
