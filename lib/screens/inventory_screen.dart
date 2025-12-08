import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'add_inventory_item_screen.dart';
import '../widgets/currency_widgets.dart';
import '../widgets/inventory_item_card.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddInventoryItemScreen()),
          ).then((_) {
            Provider.of<InventoryProvider>(context, listen: false).loadInventoryItems();
          });
        },
        child: Icon(Icons.add),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.inventoryItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No inventory items found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first item',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.inventoryItems.length,
            itemBuilder: (context, index) {
              final item = provider.inventoryItems[index];
              return InventoryItemCard(
                name: item.name,
                description: item.description,
                quantity: item.quantity,
                unit: item.unit,
                costPerUnit: item.costPerUnit,
                sellingPricePerUnit: item.sellingPricePerUnit,
                category: item.category,
                dateAdded: item.dateAdded,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddInventoryItemScreen(inventoryItem: item)),
                  ).then((_) {
                    Provider.of<InventoryProvider>(context, listen: false).loadInventoryItems();
                  });
                },
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Item'),
                        content: Text('Are you sure you want to delete ${item.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteInventoryItem(item.id);
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}