import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    test('getConversionFactor - same unit returns 1.0', () {
      expect(UnitConverter.getConversionFactor('kg', 'kg'), 1.0);
      expect(UnitConverter.getConversionFactor('g', 'g'), 1.0);
      expect(UnitConverter.getConversionFactor('L', 'L'), 1.0);
    });

    test('getConversionFactor - kg to g conversion', () {
      expect(UnitConverter.getConversionFactor('kg', 'g'), 1000.0);
      expect(UnitConverter.getConversionFactor('g', 'kg'), 0.001);
    });

    test('getConversionFactor - kg to mg conversion', () {
      expect(UnitConverter.getConversionFactor('kg', 'mg'), 1000000.0);
      // mg to kg is not directly supported, returns 1.0 (default)
      expect(UnitConverter.getConversionFactor('mg', 'kg'), 1.0);
    });

    test('getConversionFactor - L to ml conversion', () {
      // UnitConverter uses lowercase comparison
      expect(UnitConverter.getConversionFactor('l', 'ml'), 1000.0);
      expect(UnitConverter.getConversionFactor('ml', 'l'), 0.001);
      // Also test uppercase
      expect(UnitConverter.getConversionFactor('L', 'ml'), 1000.0);
      expect(UnitConverter.getConversionFactor('ml', 'L'), 0.001);
    });

    test('getConversionFactor - unknown units return 1.0', () {
      expect(UnitConverter.getConversionFactor('unknown', 'unit'), 1.0);
      expect(UnitConverter.getConversionFactor('kg', 'unknown'), 1.0);
    });

    test('convert - converts quantity correctly', () {
      // 2 kg to g = 2000 g
      expect(UnitConverter.convert(2.0, 'kg', 'g'), 2000.0);

      // 500 g to kg = 0.5 kg
      expect(UnitConverter.convert(500.0, 'g', 'kg'), 0.5);

      // 1.5 L to ml = 1500 ml (case insensitive)
      expect(UnitConverter.convert(1.5, 'l', 'ml'), 1500.0);
      expect(UnitConverter.convert(1.5, 'L', 'ml'), 1500.0);

      // 250 ml to L = 0.25 L (case insensitive)
      expect(UnitConverter.convert(250.0, 'ml', 'l'), 0.25);
      expect(UnitConverter.convert(250.0, 'ml', 'L'), 0.25);
    });

    test('convert - same unit returns same quantity', () {
      expect(UnitConverter.convert(100.0, 'kg', 'kg'), 100.0);
      expect(UnitConverter.convert(50.0, 'g', 'g'), 50.0);
    });

    test('convert - handles zero quantity', () {
      expect(UnitConverter.convert(0.0, 'kg', 'g'), 0.0);
      expect(UnitConverter.convert(0.0, 'L', 'ml'), 0.0);
    });

    test('convert - handles negative quantity', () {
      expect(UnitConverter.convert(-5.0, 'kg', 'g'), -5000.0);
    });
  });
}
