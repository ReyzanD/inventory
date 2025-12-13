import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import 'add_product_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/search_and_filter_bar.dart';
import '../widgets/loading_widgets.dart';
import '../utils/error_handler.dart';
import '../utils/provider_extensions.dart';
import '../utils/filter_helper.dart';
import '../utils/sort_helper.dart';
import '../utils/list_extensions.dart';
import '../widgets/empty_state_widget.dart';
import '../l10n/app_localizations.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedSort = 'Name A-Z';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.products),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          ).then((_) {
            context.inventoryProvider.loadProducts();
          });
        },
        child: Icon(Icons.add),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          // Show loading indicator when loading
          if (provider.isLoadingProducts) {
            return LoadingIndicator(message: localizations.loadingProducts);
          }

          // Error banner if load failed
          if (provider.productsError != null) {
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
                            provider.productsError,
                          ),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.inventoryProvider.loadProducts();
                        },
                        child: Text(localizations.retry),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      localizations.unableToLoadProducts,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            );
          }

          // Get unique categories for the filter dropdown
          final categories = provider.products.extractUniqueCategories();

          if (provider.products.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.production_quantity_limits,
              title: localizations.noProductsFound,
              subtitle: localizations.tapToCreateFirstProduct,
            );
          }

          // Apply all filters and sorting using helper utilities
          List<Product> filteredProducts = FilterHelper.applyProductFilters(
            products: provider.products,
            searchQuery: _searchQuery,
            category: _selectedCategory,
          );

          // Apply sorting
          filteredProducts = SortHelper.sortProducts(
            filteredProducts,
            _selectedSort,
          );

          return Column(
            children: [
              // Search and filter bar
              SearchAndFilterBar(
                hintText: 'Search products...',
                categories: categories,
                sortOptions: [
                  'Name A-Z',
                  'Name Z-A',
                  'Price High-Low',
                  'Price Low-High',
                  'Date Added (Newest)',
                ],
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
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
                  // Do nothing for product screen
                },
                onDateRangeChanged: (start, end) {
                  // Do nothing for product screen
                },
              ),
              // Products list
              Expanded(
                child: filteredProducts.isEmpty
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
                              'No products match your search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final cogs = provider.calculateProductCogs(
                            product.id,
                          );
                          final profit = product.sellingPrice - cogs;

                          // Create a list of component descriptions
                          List<String> componentsList = product.components.map((
                            component,
                          ) {
                            final inventoryItem = provider.getInventoryItemById(
                              component.inventoryItemId,
                            );
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
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddProductScreen(product: product),
                                ),
                              ).then((_) {
                                Provider.of<InventoryProvider>(
                                  context,
                                  listen: false,
                                ).loadProducts();
                              });
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(localizations.deleteProduct),
                                    content: Text(
                                      '${localizations.areYouSure} ${localizations.thisActionCannotBeUndone}\n\n${product.name}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(localizations.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final deletedProduct = product;
                                          try {
                                            await provider.deleteProduct(
                                              product.id,
                                            );
                                            Navigator.of(context).pop();
                                            // Show undoable delete message
                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${localizations.products} ${localizations.delete.toLowerCase()}',
                                                  ),
                                                  action: SnackBarAction(
                                                    label: 'UNDO',
                                                    onPressed: () async {
                                                      await Provider.of<
                                                            InventoryProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
                                                          .addProduct(
                                                            deletedProduct,
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
                                                  'Failed to delete product',
                                              onRetry: () async {
                                                try {
                                                  await provider.deleteProduct(
                                                    product.id,
                                                  );
                                                  Navigator.of(context).pop();
                                                  ErrorHandler.showSuccessSnackBar(
                                                    context,
                                                    'Product deleted successfully',
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
                                          localizations.delete,
                                          style: TextStyle(color: Colors.red),
                                        ),
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
