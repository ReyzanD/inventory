import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',  // Indonesian locale
      symbol: 'Rp ',    // Rupiah symbol
      decimalDigits: 0, // No decimal places for rupiah in common usage
    );
    return formatter.format(amount);
  }
  
  static String formatRupiahWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2, // With decimal places
    );
    return formatter.format(amount);
  }
  
  // Format number with thousands separator but no currency symbol
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }
}