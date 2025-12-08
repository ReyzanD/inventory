import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_transaction.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          // For now, we'll simulate transaction history based on inventory changes
          // In a real app, you'd have a separate service to track all transactions
          
          // Create mock transaction history based on inventory items
          List<InventoryTransaction> mockTransactions = [];
          
          for (var item in provider.inventoryItems) {
            // Simulate some transactions - in reality these would come from a transaction log
            mockTransactions.add(
              InventoryTransaction(
                id: 'mock-${item.id}-1',
                inventoryItemId: item.id,
                itemName: item.name,
                type: TransactionType.addition,
                quantity: item.quantity, // Using current quantity as example
                unit: item.unit,
                reason: 'Initial inventory',
                timestamp: DateTime.now().subtract(Duration(hours: 1)),
                userId: 'current_user',
              ),
            );
          }
          
          // Sort by timestamp (most recent first)
          mockTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          if (mockTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No transaction history found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All your inventory transactions will appear here',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: mockTransactions.length,
            itemBuilder: (context, index) {
              final transaction = mockTransactions[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: transaction.getColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      transaction.getIcon(),
                      color: transaction.getColor(),
                    ),
                  ),
                  title: Text(
                    transaction.itemName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
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
          );
        },
      ),
    );
  }
}