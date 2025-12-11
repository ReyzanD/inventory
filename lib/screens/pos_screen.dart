import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/pos_transaction.dart';
import '../models/product.dart';
import '../widgets/pos_widgets.dart';

class POSScreen extends StatefulWidget {
  @override
  _POSScreenState createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<PosTransactionItem> _cart = [];
  double _taxRate = 0.0;
  double _discount = 0.0;

  bool _isAddingToCart = false; // Flag to prevent rapid updates

  void _addToCart(Product product) {
    if (_isAddingToCart) return; // Prevent multiple rapid additions

    _isAddingToCart = true;
    if (mounted) {
      setState(() {
        _cart.add(
          PosTransactionItem(
            productId: product.id,
            productName: product.name,
            quantity: 1,
            unitPrice: product.sellingPrice,
            totalItemPrice: product.sellingPrice,
          ),
        );
      });
    }

    // Reset the flag after a short delay
    Future.delayed(Duration(milliseconds: 150), () {
      if (mounted) {
        _isAddingToCart = false;
      }
    });
  }

  void _processTransaction() async {
    if (_cart.isEmpty) return;

    // Process transaction - no inventory check now
    final transaction = PosTransaction.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: _cart,
      taxRate: _taxRate / 100,
      discount: _discount,
    );

    // Optionally reduce inventory (if you want to track it)
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    for (final cartItem in _cart) {
      await provider.reduceInventoryForSoldProduct(cartItem.productId);
    }

    // Clear cart
    setState(() {
      _cart.clear();
      _taxRate = 0.0;
      _discount = 0.0;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction completed! Total: \$${transaction.total.toStringAsFixed(2)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS System'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Main content area (products and cart)
              Expanded(
                child: Row(
                  children: [
                    // Product selection section (left side)
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Consumer<InventoryProvider>(
                          builder: (context, provider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Products',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          childAspectRatio: 0.9,
                                          crossAxisSpacing: 6,
                                          mainAxisSpacing: 6,
                                        ),
                                    itemCount: provider.products.length,
                                    itemBuilder: (context, index) {
                                      final product = provider.products[index];
                                      return Card(
                                        child: InkWell(
                                          onTap: () => _addToCart(product),
                                          child: Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .production_quantity_limits,
                                                  size: 24,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  product.name,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 1),
                                                Text(
                                                  '\$${product.sellingPrice.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      ),
                    ),
                    // Cart section (right side)
                    POSCart(
                      cart: _cart,
                      taxRate: _taxRate,
                      discount: _discount,
                      onCartChanged: (newCart) {
                        // Prevent multiple rapid updates that can interfere with mouse tracking
                        if (mounted) {
                          setState(() {
                            _cart = newCart;
                          });
                        }
                      },
                      onTaxRateChanged: (newTaxRate) {
                        // Prevent multiple rapid updates that can interfere with mouse tracking
                        if (mounted) {
                          setState(() {
                            _taxRate = newTaxRate;
                          });
                        }
                      },
                      onDiscountChanged: (newDiscount) {
                        // Prevent multiple rapid updates that can interfere with mouse tracking
                        if (mounted) {
                          setState(() {
                            _discount = newDiscount;
                          });
                        }
                      },
                      onProcessTransaction: _processTransaction,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
