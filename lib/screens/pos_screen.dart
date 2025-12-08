import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../models/pos_transaction.dart';
import '../widgets/currency_widgets.dart';

class POSScreen extends StatefulWidget {
  @override
  _POSScreenState createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<PosTransactionItem> _cart = [];
  double _taxRate = 0.0;
  double _discount = 0.0;

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Products',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5, // More columns for sidebar layout
                                  childAspectRatio: 0.9, // Slightly more square
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                ),
                                itemCount: provider.products.length,
                                itemBuilder: (context, index) {
                                  final product = provider.products[index];
                                  // Don't check inventory for POS, allow sales regardless

                                  return Card(
                                    child: InkWell(
                                      onTap: () {
                                        // Add to cart
                                        setState(() {
                                          _cart.add(PosTransactionItem(
                                            productId: product.id,
                                            productName: product.name,
                                            quantity: 1,
                                            unitPrice: product.sellingPrice,
                                            totalItemPrice: product.sellingPrice,
                                          ));
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(4), // Even smaller padding
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.production_quantity_limits,
                                              size: 24, // Smaller icon
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            SizedBox(height: 2), // Less space
                                            Text(
                                              product.name,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 9, // Smaller font
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 1), // Less space
                                            RupiahText(
                                              amount: product.sellingPrice,
                                              style: TextStyle(
                                                fontSize: 10, // Smaller font
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
                        ),
                      ),
                    ),
                    // Cart section (right side)
                    Container(
                      width: 350, // Fixed width for cart
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(
                          left: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cart (${_cart.length} items)',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: _cart.isEmpty ? null : () {
                                    setState(() {
                                      _cart.clear();
                                    });
                                  },
                                  child: Text('Clear Cart', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                            Expanded(
                              child: _cart.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Cart is empty\n\nAdd products to start a transaction',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _cart.length,
                                      itemBuilder: (context, index) {
                                        final item = _cart[index];
                                        return Dismissible(
                                          key: Key(item.productId + index.toString()),
                                          direction: DismissDirection.endToStart,
                                          onDismissed: (direction) {
                                            setState(() {
                                              _cart.removeAt(index);
                                            });
                                          },
                                          background: Container(
                                            color: Colors.red,
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.only(right: 16),
                                            child: Icon(Icons.delete, color: Colors.white),
                                          ),
                                          child: ListTile(
                                            title: Text(item.productName),
                                            subtitle: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                RupiahText(
                                                  amount: item.unitPrice,
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                                Text(' × ${item.quantity}'),
                                              ],
                                            ),
                                            trailing: RupiahText(
                                              amount: item.totalItemPrice,
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            if (_cart.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Subtotal:', style: TextStyle(fontSize: 16)),
                                    RupiahText(
                                      amount: _cart.fold(0.0, (sum, item) => sum + item.totalItemPrice),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Tax Rate (%)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final parsed = double.tryParse(value);
                                        setState(() {
                                          _taxRate = parsed ?? 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Discount (\$)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final parsed = double.tryParse(value);
                                        setState(() {
                                          _discount = parsed ?? 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_cart.isEmpty) return;

                                  // Process transaction - no inventory check now
                                  final transaction = PosTransaction.create(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    items: _cart,
                                    taxRate: _taxRate / 100,
                                    discount: _discount,
                                  );

                                  // Optionally reduce inventory (if you want to track it)
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
                                      content: Text('Transaction completed! Total: \$${transaction.total.toStringAsFixed(2)}'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                child: Text('Process Transaction'),
                              ),
                            ],
                          ],
                        ),
                      ),
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