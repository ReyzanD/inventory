import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import 'add_product_screen.dart';
import '../widgets/currency_widgets.dart';
import '../widgets/product_card.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          ).then((_) {
            Provider.of<InventoryProvider>(context, listen: false).loadProducts();
          });
        },
        child: Icon(Icons.add),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.production_quantity_limits,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first product',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              final cogs = provider.calculateProductCogs(product.id);
              final profit = product.sellingPrice - cogs;

              // Create a list of component descriptions
              List<String> componentsList = product.components.map((component) {
                final inventoryItem = provider.getInventoryItemById(component.inventoryItemId);
                return '${inventoryItem?.name ?? 'Unknown Item'}: ${component.quantityNeeded.toStringAsFixed(2)} ${component.unit}';
              }).toList();

              return ProductCard(
                name: product.name,
                sellingPrice: product.sellingPrice,
                cogs: cogs,
                profit: profit,
                componentsCount: product.components.length,
                category: product.category,
                componentsList: componentsList,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen(product: product)),
                  ).then((_) {
                    Provider.of<InventoryProvider>(context, listen: false).loadProducts();
                  });
                },
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Product'),
                        content: Text('Are you sure you want to delete ${product.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteProduct(product.id);
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onExpansionChanged: () {
                  // Optional: Handle expansion changes if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}