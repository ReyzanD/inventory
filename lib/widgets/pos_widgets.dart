import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/pos_transaction.dart';
import '../widgets/currency_widgets.dart';
import '../l10n/app_localizations.dart';

class POSProductGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = (constraints.maxWidth / 160)
                      .clamp(2, 5)
                      .toInt();
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      // Don't check inventory for POS, allow sales regardless

                      return Card(
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class POSCart extends StatefulWidget {
  final List<PosTransactionItem> cart;
  final double taxRate;
  final double discount;
  final Function(List<PosTransactionItem>) onCartChanged;
  final Function(double) onTaxRateChanged;
  final Function(double) onDiscountChanged;
  final Function() onProcessTransaction;

  const POSCart({
    required this.cart,
    required this.taxRate,
    required this.discount,
    required this.onCartChanged,
    required this.onTaxRateChanged,
    required this.onDiscountChanged,
    required this.onProcessTransaction,
  });

  @override
  _POSCartState createState() => _POSCartState();
}

class _POSCartState extends State<POSCart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, // Fixed width for cart
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart (${widget.cart.length} items)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: widget.cart.isEmpty
                      ? null
                      : () {
                          final removedItems = List<PosTransactionItem>.from(
                            widget.cart,
                          );
                          widget.onCartChanged([]);
                          final localizations = AppLocalizations.of(context);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations?.cartCleared ?? 'Cart cleared',
                                ),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {
                                    widget.onCartChanged(removedItems);
                                  },
                                ),
                              ),
                            );
                        },
                  child: Text(
                    'Clear Cart',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            Expanded(
              child: widget.cart.isEmpty
                  ? Center(
                      child: Text(
                        'Cart is empty\n\nAdd products to start a transaction',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.cart.length,
                      itemBuilder: (context, index) {
                        final item = widget.cart[index];
                        return Dismissible(
                          key: Key(item.productId + index.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            // Add slight delay to prevent conflicts with mouse tracking
                            await Future.delayed(Duration(milliseconds: 50));
                            final newCart = List<PosTransactionItem>.from(
                              widget.cart,
                            );
                            final removed = newCart.removeAt(index);
                            widget.onCartChanged(newCart);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${removed.productName} removed',
                                  ),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      final restored =
                                          List<PosTransactionItem>.from(
                                            newCart,
                                          );
                                      restored.insert(index, removed);
                                      widget.onCartChanged(restored);
                                    },
                                  ),
                                ),
                              );
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (widget.cart.isNotEmpty) ...[
              _buildCartSummary(),
              _buildTaxDiscountFields(),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.onProcessTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Builder(
                  builder: (context) {
                    final localizations = AppLocalizations.of(context);
                    return Text(
                      localizations?.processTransaction ??
                          'Process Transaction',
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    final localizations = AppLocalizations.of(context);
    final subtotal = widget.cart.fold(
      0.0,
      (sum, item) => sum + item.totalItemPrice,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations?.subtotal ?? 'Subtotal:',
            style: TextStyle(fontSize: 16),
          ),
          RupiahText(
            amount: subtotal,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxDiscountFields() {
    return Row(
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
              widget.onTaxRateChanged(parsed ?? 0.0);
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
              widget.onDiscountChanged(parsed ?? 0.0);
            },
          ),
        ),
      ],
    );
  }
}
