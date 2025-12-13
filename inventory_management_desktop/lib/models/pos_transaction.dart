import 'package:intl/intl.dart';
import 'product.dart';

class PosTransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalItemPrice;

  PosTransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalItemPrice,
  });
}

class PosTransaction {
  final String id;
  final List<PosTransactionItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final DateTime transactionDate;
  final String transactionDateFormatted;

  PosTransaction({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.transactionDate,
  }) : transactionDateFormatted = DateFormat('yyyy-MM-dd HH:mm').format(transactionDate);

  // Calculate subtotal, tax, and total
  static PosTransaction create({
    required String id,
    required List<PosTransactionItem> items,
    double taxRate = 0.0,
    double discount = 0.0,
  }) {
    double subtotal = items.fold(0, (sum, item) => sum + item.totalItemPrice);
    double taxAmount = subtotal * taxRate;
    double discountAmount = discount;
    double total = subtotal + taxAmount - discountAmount;

    return PosTransaction(
      id: id,
      items: items,
      subtotal: subtotal,
      tax: taxAmount,
      discount: discountAmount,
      total: total,
      transactionDate: DateTime.now(),
    );
  }
}