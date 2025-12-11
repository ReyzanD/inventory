import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import 'add_inventory_item_screen.dart';
import '../widgets/currency_widgets.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/search_and_filter_bar.dart';
import '../utils/debouncer.dart';
import '../widgets/loading_widgets.dart';
import '../utils/error_handler.dart';
import '../utils/provider_extensions.dart';
import '../utils/filter_helper.dart';
import '../utils/sort_helper.dart';
import '../utils/list_extensions.dart';
import '../widgets/empty_state_widget.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedSort = 'Name A-Z';
  double _minStock = 0.0;
  double _maxStock = 10000.0;
  DateTime? _startDate;
  DateTime? _endDate;

  final Debouncer _debouncer = Debouncer();

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

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
            context.inventoryProvider.loadInventoryItems();
          });
        },
        child: Icon(Icons.add),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          // Show loading indicator when loading
          if (provider.isLoadingInventory) {
            return LoadingIndicator(message: 'Loading inventory items...');
          }

          // Error banner if load failed
          if (provider.inventoryError != null) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.red.withOpacity(0.1),
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ErrorHandler.getUserFriendlyMessage(
                            provider.inventoryError,
                          ),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.inventoryProvider.loadInventoryItems();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Unable to load inventory.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            );
          }

          // Get unique categories for the filter dropdown
          final categories = provider.inventoryItems.extractUniqueCategories();

          if (provider.inventoryItems.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'No inventory items found',
              subtitle: 'Tap the + button to add your first item',
            );
          }

          // Apply all filters and sorting using helper utilities
          List<InventoryItem> filteredItems =
              FilterHelper.applyInventoryFilters(
                items: provider.inventoryItems,
                searchQuery: _searchQuery,
                category: _selectedCategory,
                minStock: _minStock,
                maxStock: _maxStock,
                startDate: _startDate,
                endDate: _endDate,
              );

          // Apply sorting
          filteredItems = SortHelper.sortInventoryItems(
            filteredItems,
            _selectedSort,
          );

          return Column(
            children: [
              // Search and filter bar
              SearchAndFilterBar(
                hintText: 'Search inventory items...',
                categories: categories,
                sortOptions: [
                  'Name A-Z',
                  'Name Z-A',
                  'Quantity High-Low',
                  'Quantity Low-High',
                  'Date Added (Newest)',
                  'Price High-Low',
                ],
                onSearchChanged: (query) {
                  // Use debounced search
                  _debouncer.call(() {
                    if (mounted) {
                      setState(() {
                        _searchQuery = query;
                      });
                    }
                  }, milliseconds: 500);
                },
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category ?? '';
                  });
                },
                onSortChanged: (sortOption) {
                  setState(() {
                    _selectedSort = sortOption ?? 'Name A-Z';
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
                    ? EmptySearchStateWidget()
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
                                MaterialPageRoute(
                                  builder: (context) => AddInventoryItemScreen(
                                    inventoryItem: item,
                                  ),
                                ),
                              ).then((_) {
                                Provider.of<InventoryProvider>(
                                  context,
                                  listen: false,
                                ).loadInventoryItems();
                              });
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete Item'),
                                    content: Text(
                                      'Are you sure you want to delete ${item.name}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final deletedItem = item;
                                          try {
                                            await provider.deleteInventoryItem(
                                              item.id,
                                            );
                                            Navigator.of(context).pop();
                                            // Show undoable delete message
                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text('Item deleted'),
                                                  action: SnackBarAction(
                                                    label: 'UNDO',
                                                    onPressed: () async {
                                                      await Provider.of<
                                                            InventoryProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
                                                          .addInventoryItem(
                                                            deletedItem,
                                                          );
                                                    },
                                                  ),
                                                ),
                                              );
                                          } catch (e) {
                                            Navigator.of(context).pop();
                                            // Show user-friendly error message
                                            ErrorHandler.showErrorSnackBar(
                                              context,
                                              e,
                                              customMessage:
                                                  'Failed to delete item',
                                              onRetry: () async {
                                                try {
                                                  await provider
                                                      .deleteInventoryItem(
                                                        item.id,
                                                      );
                                                  Navigator.of(context).pop();
                                                  ErrorHandler.showSuccessSnackBar(
                                                    context,
                                                    'Item deleted successfully',
                                                  );
                                                } catch (retryError) {
                                                  ErrorHandler.showErrorSnackBar(
                                                    context,
                                                    retryError,
                                                  );
                                                }
                                              },
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
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
