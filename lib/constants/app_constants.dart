// Currency constants
const String CURRENCY_SYMBOL = 'Rp ';
const String CURRENCY_LOCALE = 'id_ID';

// Database constants
const String DATABASE_NAME = 'InventoryManagement.db';
const String INVENTORY_TABLE = 'inventory';
const String PRODUCTS_TABLE = 'products';
const String PRODUCT_COMPONENTS_TABLE = 'product_components';

// Unit conversion constants
const Map<String, double> UNIT_CONVERSIONS = {
  'kg_to_g': 1000.0,
  'g_to_kg': 0.001,
  'kg_to_mg': 1000000.0,
  'g_to_mg': 1000.0,
  'L_to_ml': 1000.0,
  'ml_to_L': 0.001,
};