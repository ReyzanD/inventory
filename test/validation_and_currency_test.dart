import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/utils/validation_utils.dart';
import 'package:inventory/utils/currency_utils.dart';

void main() {
  group('ValidationUtils.validatePrice', () {
    test('rejects null or empty', () {
      expect(ValidationUtils.validatePrice(null), 'Price is required');
      expect(ValidationUtils.validatePrice('   '), 'Price is required');
    });

    test('rejects non-numeric input', () {
      expect(
        ValidationUtils.validatePrice('abc'),
        'Please enter a valid number',
      );
    });

    test('rejects negative values', () {
      expect(ValidationUtils.validatePrice('-5'), 'Price cannot be negative');
    });

    test('rejects overly large values', () {
      expect(ValidationUtils.validatePrice('1000000'), 'Price is too large');
    });

    test('accepts valid price', () {
      expect(ValidationUtils.validatePrice('9999.99'), isNull);
    });
  });

  group('ValidationUtils.validateQuantity', () {
    test('rejects null or empty', () {
      expect(ValidationUtils.validateQuantity(null), 'Quantity is required');
      expect(ValidationUtils.validateQuantity('   '), 'Quantity is required');
    });

    test('rejects non-numeric input', () {
      expect(
        ValidationUtils.validateQuantity('abc'),
        'Please enter a valid number',
      );
    });

    test('rejects zero or negative', () {
      expect(
        ValidationUtils.validateQuantity('0'),
        'Quantity must be greater than 0',
      );
      expect(
        ValidationUtils.validateQuantity('-1'),
        'Quantity must be greater than 0',
      );
    });

    test('rejects overly large values', () {
      expect(
        ValidationUtils.validateQuantity('1000000'),
        'Quantity is too large',
      );
    });

    test('accepts valid quantity', () {
      expect(ValidationUtils.validateQuantity('42.5'), isNull);
    });
  });

  group('ValidationUtils.validatePositiveNumber', () {
    test('rejects invalid input with field name', () {
      expect(
        ValidationUtils.validatePositiveNumber('abc', 'Low Stock Threshold'),
        'Please enter a valid number for Low Stock Threshold',
      );
    });

    test('accepts valid input', () {
      expect(
        ValidationUtils.validatePositiveNumber('10', 'Low Stock Threshold'),
        isNull,
      );
    });
  });

  group('CurrencyUtils formatting', () {
    test('formatNumber does not include currency symbol', () {
      final formatted = CurrencyUtils.formatNumber(1234.5);
      expect(formatted.contains('Rp'), isFalse);
    });

    test('formatNumber handles zero and large numbers', () {
      expect(CurrencyUtils.formatNumber(0), '0');
      // Indonesian locale uses dot as thousand separator
      expect(CurrencyUtils.formatNumber(1000000), '1.000.000');
    });

    test('formatRupiah includes currency symbol', () {
      final formatted = CurrencyUtils.formatRupiah(5000);
      expect(formatted.contains('Rp'), isTrue);
    });

    test('formatRupiahWithDecimals keeps two decimals', () {
      final formatted = CurrencyUtils.formatRupiahWithDecimals(1234.5);
      expect(formatted.contains('Rp'), isTrue);
      // Indonesian locale uses comma as decimal separator
      expect(formatted.endsWith('1.234,50'), isTrue);
    });
  });
}
