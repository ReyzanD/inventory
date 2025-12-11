import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/utils/type_converter.dart';

void main() {
  group('TypeConverter', () {
    group('toDouble', () {
      test('should return default value when value is null', () {
        expect(TypeConverter.toDouble(null), 0.0);
        expect(TypeConverter.toDouble(null, 5.5), 5.5);
      });

      test('should return value when value is double', () {
        expect(TypeConverter.toDouble(3.14), 3.14);
        expect(TypeConverter.toDouble(0.0), 0.0);
        expect(TypeConverter.toDouble(-5.5), -5.5);
      });

      test('should convert int to double', () {
        expect(TypeConverter.toDouble(5), 5.0);
        expect(TypeConverter.toDouble(0), 0.0);
        expect(TypeConverter.toDouble(-10), -10.0);
      });

      test('should parse valid string to double', () {
        expect(TypeConverter.toDouble('3.14'), 3.14);
        expect(TypeConverter.toDouble('5'), 5.0);
        expect(TypeConverter.toDouble('0'), 0.0);
        expect(TypeConverter.toDouble('-10.5'), -10.5);
      });

      test('should return default value for invalid string', () {
        expect(TypeConverter.toDouble('invalid'), 0.0);
        expect(TypeConverter.toDouble('abc', 10.0), 10.0);
        expect(TypeConverter.toDouble(''), 0.0);
      });

      test('should return default value for unsupported types', () {
        expect(TypeConverter.toDouble(true), 0.0);
        expect(TypeConverter.toDouble([1, 2, 3]), 0.0);
        expect(TypeConverter.toDouble({'key': 'value'}), 0.0);
      });
    });

    group('toInt', () {
      test('should return default value when value is null', () {
        expect(TypeConverter.toInt(null), 0);
        expect(TypeConverter.toInt(null, 10), 10);
      });

      test('should return value when value is int', () {
        expect(TypeConverter.toInt(5), 5);
        expect(TypeConverter.toInt(0), 0);
        expect(TypeConverter.toInt(-10), -10);
      });

      test('should convert double to int', () {
        expect(TypeConverter.toInt(5.7), 5);
        expect(TypeConverter.toInt(5.2), 5);
        expect(TypeConverter.toInt(-10.9), -10);
        expect(TypeConverter.toInt(0.0), 0);
      });

      test('should parse valid string to int', () {
        expect(TypeConverter.toInt('5'), 5);
        expect(TypeConverter.toInt('0'), 0);
        expect(TypeConverter.toInt('-10'), -10);
        expect(TypeConverter.toInt('100'), 100);
      });

      test('should return default value for invalid string', () {
        expect(TypeConverter.toInt('invalid'), 0);
        expect(TypeConverter.toInt('abc', 10), 10);
        expect(TypeConverter.toInt('5.5'), 0); // Decimal string returns default
        expect(TypeConverter.toInt(''), 0);
      });

      test('should return default value for unsupported types', () {
        expect(TypeConverter.toInt(true), 0);
        expect(TypeConverter.toInt([1, 2, 3]), 0);
        expect(TypeConverter.toInt({'key': 'value'}), 0);
      });
    });

    group('toStringValue', () {
      test('should return default value when value is null', () {
        expect(TypeConverter.toStringValue(null), '');
        expect(TypeConverter.toStringValue(null, 'default'), 'default');
      });

      test('should convert int to string', () {
        expect(TypeConverter.toStringValue(5), '5');
        expect(TypeConverter.toStringValue(0), '0');
        expect(TypeConverter.toStringValue(-10), '-10');
      });

      test('should convert double to string', () {
        expect(TypeConverter.toStringValue(3.14), '3.14');
        expect(TypeConverter.toStringValue(0.0), '0.0');
        expect(TypeConverter.toStringValue(-5.5), '-5.5');
      });

      test('should return string as is', () {
        expect(TypeConverter.toStringValue('hello'), 'hello');
        expect(TypeConverter.toStringValue(''), '');
        expect(TypeConverter.toStringValue('123'), '123');
      });

      test('should convert bool to string', () {
        expect(TypeConverter.toStringValue(true), 'true');
        expect(TypeConverter.toStringValue(false), 'false');
      });

      test('should convert other types to string', () {
        expect(TypeConverter.toStringValue([1, 2, 3]), '[1, 2, 3]');
        expect(TypeConverter.toStringValue({'key': 'value'}), '{key: value}');
      });
    });

    group('toBool', () {
      test('should return default value when value is null', () {
        expect(TypeConverter.toBool(null), false);
        expect(TypeConverter.toBool(null, true), true);
      });

      test('should return value when value is bool', () {
        expect(TypeConverter.toBool(true), true);
        expect(TypeConverter.toBool(false), false);
      });

      test('should convert int to bool', () {
        expect(TypeConverter.toBool(1), true);
        expect(TypeConverter.toBool(0), false);
        expect(TypeConverter.toBool(-1), true);
        expect(TypeConverter.toBool(100), true);
      });

      test('should parse string "true" (case insensitive)', () {
        expect(TypeConverter.toBool('true'), true);
        expect(TypeConverter.toBool('TRUE'), true);
        expect(TypeConverter.toBool('True'), true);
        expect(TypeConverter.toBool('tRuE'), true);
      });

      test('should return false for non-"true" strings', () {
        expect(TypeConverter.toBool('false'), false);
        expect(TypeConverter.toBool('yes'), false);
        expect(TypeConverter.toBool('1'), false);
        expect(TypeConverter.toBool(''), false);
        expect(TypeConverter.toBool('anything'), false);
      });

      test('should return default value for unsupported types', () {
        expect(TypeConverter.toBool(3.14), false);
        expect(TypeConverter.toBool([1, 2, 3]), false);
        expect(TypeConverter.toBool({'key': 'value'}), false);
      });
    });

    group('toDateTime', () {
      test('should return default value when value is null', () {
        final defaultDate = DateTime(2020, 1, 1);
        final result = TypeConverter.toDateTime(null, defaultDate);
        expect(result, defaultDate);
      });

      test(
        'should return DateTime.now() as default when no default provided',
        () {
          final before = DateTime.now();
          final result = TypeConverter.toDateTime(null);
          final after = DateTime.now();
          expect(result.isAfter(before.subtract(Duration(seconds: 1))), true);
          expect(result.isBefore(after.add(Duration(seconds: 1))), true);
        },
      );

      test('should return value when value is DateTime', () {
        final date = DateTime(2023, 5, 15, 10, 30);
        expect(TypeConverter.toDateTime(date), date);
      });

      test('should convert int (milliseconds) to DateTime', () {
        final timestamp = 1684150200000; // May 15, 2023 10:30:00 UTC
        final expected = DateTime.fromMillisecondsSinceEpoch(timestamp);
        expect(TypeConverter.toDateTime(timestamp), expected);
      });

      test('should parse valid ISO 8601 string', () {
        final dateString = '2023-05-15T10:30:00.000Z';
        final expected = DateTime.parse(dateString);
        expect(TypeConverter.toDateTime(dateString), expected);
      });

      test('should parse valid date string without time', () {
        final dateString = '2023-05-15';
        final expected = DateTime.parse(dateString);
        expect(TypeConverter.toDateTime(dateString), expected);
      });

      test('should return default value for invalid string', () {
        final defaultDate = DateTime(2020, 1, 1);
        expect(TypeConverter.toDateTime('invalid', defaultDate), defaultDate);
        expect(
          TypeConverter.toDateTime('not-a-date', defaultDate),
          defaultDate,
        );
        expect(TypeConverter.toDateTime('', defaultDate), defaultDate);
      });

      test('should return default value for unsupported types', () {
        final defaultDate = DateTime(2020, 1, 1);
        expect(TypeConverter.toDateTime(true, defaultDate), defaultDate);
        expect(TypeConverter.toDateTime([1, 2, 3], defaultDate), defaultDate);
        expect(
          TypeConverter.toDateTime({'key': 'value'}, defaultDate),
          defaultDate,
        );
      });

      test('should handle edge cases', () {
        // Very old timestamp (Unix epoch start)
        final oldTimestamp = 0; // January 1, 1970
        final oldDate = TypeConverter.toDateTime(oldTimestamp);
        expect(oldDate.year, 1970);

        // Very future timestamp
        final futureTimestamp = 4102444800000; // Year 2100
        final futureDate = TypeConverter.toDateTime(futureTimestamp);
        expect(futureDate.year, 2100);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty strings consistently', () {
        expect(TypeConverter.toDouble(''), 0.0);
        expect(TypeConverter.toInt(''), 0);
        expect(TypeConverter.toStringValue(''), '');
        expect(TypeConverter.toBool(''), false);
      });

      test('should handle whitespace strings', () {
        expect(TypeConverter.toDouble('   '), 0.0);
        expect(TypeConverter.toInt('   '), 0);
        expect(TypeConverter.toStringValue('   '), '   ');
        expect(TypeConverter.toBool('   '), false);
      });

      test('should handle very large numbers', () {
        expect(
          TypeConverter.toDouble(1.7976931348623157e+308),
          1.7976931348623157e+308,
        );
        expect(TypeConverter.toInt(9223372036854775807), 9223372036854775807);
      });

      test('should handle negative numbers', () {
        expect(TypeConverter.toDouble(-100.5), -100.5);
        expect(TypeConverter.toInt(-100), -100);
        expect(TypeConverter.toStringValue(-100), '-100');
      });

      test('should handle zero values', () {
        expect(TypeConverter.toDouble(0), 0.0);
        expect(TypeConverter.toInt(0), 0);
        expect(TypeConverter.toStringValue(0), '0');
        expect(TypeConverter.toBool(0), false);
      });
    });
  });
}
