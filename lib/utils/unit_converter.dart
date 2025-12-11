/// Utility class for unit conversions
/// Centralizes all unit conversion logic to avoid duplication
class UnitConverter {
  // Common unit conversion factors
  static const double kgToG = 1000.0;
  static const double gToKg = 0.001;
  static const double kgToMg = 1000000.0;
  static const double gToMg = 1000.0;
  static const double lToMl = 1000.0;
  static const double mlToL = 0.001;

  /// Get conversion factor from inventory unit to component unit
  /// Returns the factor to multiply inventory quantity by to get component quantity
  static double getConversionFactor(
    String inventoryUnit,
    String componentUnit,
  ) {
    // Same units - no conversion needed
    if (inventoryUnit.toLowerCase() == componentUnit.toLowerCase()) {
      return 1.0;
    }

    // Weight conversions
    if (inventoryUnit.toLowerCase() == 'kg' &&
        componentUnit.toLowerCase() == 'g') {
      return kgToG;
    }
    if (inventoryUnit.toLowerCase() == 'g' &&
        componentUnit.toLowerCase() == 'kg') {
      return gToKg;
    }
    if (inventoryUnit.toLowerCase() == 'kg' &&
        componentUnit.toLowerCase() == 'mg') {
      return kgToMg;
    }
    if (inventoryUnit.toLowerCase() == 'g' &&
        componentUnit.toLowerCase() == 'mg') {
      return gToMg;
    }

    // Volume conversions
    if (inventoryUnit.toLowerCase() == 'l' &&
        componentUnit.toLowerCase() == 'ml') {
      return lToMl;
    }
    if (inventoryUnit.toLowerCase() == 'ml' &&
        componentUnit.toLowerCase() == 'l') {
      return mlToL;
    }

    // Default: assume same units if conversion not found
    // This allows the system to work even with unknown units
    return 1.0;
  }

  /// Convert quantity from one unit to another
  static double convert(double quantity, String fromUnit, String toUnit) {
    final factor = getConversionFactor(fromUnit, toUnit);
    return quantity * factor;
  }
}
