// Currency constants
const String currencySymbol = 'Rp ';
const String currencyLocale = 'id_ID';

// Database constants
const String databaseName = 'InventoryManagement.db';
const String inventoryTable = 'inventory';
const String productsTable = 'products';
const String productComponentsTable = 'product_components';

// Unit conversion constants
const Map<String, double> unitConversions = {
  'kg_to_g': 1000.0,
  'g_to_kg': 0.001,
  'kg_to_mg': 1000000.0,
  'g_to_mg': 1000.0,
  'L_to_ml': 1000.0,
  'ml_to_L': 0.001,
};