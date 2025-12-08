import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'add_inventory_item_screen.dart';
import '../widgets/currency_widgets.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/search_and_filter_bar.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';
  double _minStock = 0.0;
  double _maxStock = 10000.0;
  DateTime? _startDate;
  DateTime? _endDate;

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
          // Get unique categories for the filter dropdown
          final categories = provider.inventoryItems
              .map((item) => item.category)
              .toSet()
              .toList();

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

          // Filtered items based on search and filter criteria
          List<InventoryItem> filteredItems = provider.inventoryItems;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            filteredItems = filteredItems.where((item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.category.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }

          // Apply category filter
          if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
            filteredItems = filteredItems.where((item) =>
                item.category.toLowerCase().contains(_selectedCategory.toLowerCase())
            ).toList();
          }

          // Apply stock range filter
          filteredItems = filteredItems.where((item) =>
              item.quantity >= _minStock && item.quantity <= _maxStock
          ).toList();

          // Apply date range filter
          if (_startDate != null && _endDate != null) {
            filteredItems = filteredItems.where((item) =>
                item.dateAdded.isAfter(_startDate!.subtract(Duration(days: 1))) &&
                item.dateAdded.isBefore(_endDate!.add(Duration(days: 1)))
            ).toList();
          }

          return Column(
            children: [
              // Search and filter bar
              SearchAndFilterBar(
                hintText: 'Search inventory items...',
                categories: categories,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                onStockRangeChanged: (min, max) {
                  setState(() {
                    _minStock = min;
                    _maxStock = max;
                  });
                },
                onDateRangeChanged: (start, end) {
                  setState(() {
                    _startDate = start;
                    _endDate = end;
                  });
                },
              ),
              // Inventory list
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No items match your search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}