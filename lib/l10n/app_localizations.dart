import 'package:flutter/material.dart';

/// Base class untuk lokalization
abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Settings Screen
  String get settings;
  String get appSettings;
  String get language;
  String get theme;
  String get notifications;
  String get inventory;
  String get display;
  String get other;

  // Language
  String get selectLanguage;
  String get bahasaIndonesia;
  String get english;

  // Theme
  String get selectTheme;
  String get lightTheme;
  String get darkTheme;
  String get systemTheme;
  String get primaryColor;

  // Notifications
  String get lowStockNotifications;
  String get expiryNotifications;
  String get transactionNotifications;

  // Inventory Settings
  String get defaultLowStockThreshold;
  String get defaultLowStockItemsThreshold;
  String get thresholdDescription;

  // Display Settings
  String get dateFormat;
  String get currencySymbol;
  String get currencyLocale;

  // Other Settings
  String get autoBackup;
  String get autoBackupInterval;
  String get soundEffects;
  String get hapticFeedback;
  String get days;

  // Actions
  String get save;
  String get cancel;
  String get reset;
  String get resetToDefault;
  String get savedSuccessfully;
  String get resetSuccessfully;

  // Common
  String get enabled;
  String get disabled;
  String get currentValue;

  // Screen Titles
  String get dashboard;
  String get products;
  String get pos;
  String get transactionHistory;
  String get reports;
  String get suppliers;
  String get scanItem;

  // Common Actions
  String get retry;
  String get delete;
  String get deleteItem;
  String get deleteProduct;
  String get edit;
  String get add;
  String get search;
  String get filter;
  String get sort;
  String get loading;
  String get error;
  String get noData;
  String get noItemsFound;
  String get noProductsFound;

  // Dashboard
  String get inventoryDistributionByCategory;
  String get inventoryStatus;
  String get totalItems;
  String get totalProducts;
  String get lowStockItems;
  String get financialSummary;
  String get totalInventoryCost;
  String get potentialRevenue;
  String get potentialProfit;
  String get topInventoryItems;
  String get topProducts;

  // Inventory
  String get loadingInventoryItems;
  String get unableToLoadInventory;
  String get itemDeleted;
  String get tapToCreateFirstItem;

  // Products
  String get loadingProducts;
  String get unableToLoadProducts;
  String get tapToCreateFirstProduct;

  // Messages
  String get areYouSure;
  String get thisActionCannotBeUndone;
  String get home;

  // POS
  String get posSystem;
  String get transactionCompleted;
  String get total;
  String get clear;
  String get processTransaction;
  String get cartCleared;
  String get subtotal;

  // Transaction History
  String get allTransactions;
  String get additions;
  String get deductions;
  String get transfers;

  // Inventory/Product Labels
  String get cost;
  String get sell;
  String get cogs;
  String get profit;
  String get components;
  String get componentsCount;

  // Common Widgets
  String get tryAgain;
  String get selectDateRange;
  String get allCategories;
  String get addComponent;
  String get pleaseSelectInventoryItem;
  String get editComponent;

  // Dashboard Stats
  String get inventoryItems;
  String get totalValue;
  String get lowStock;
}

/// Bahasa Indonesia
class AppLocalizationsId extends AppLocalizations {
  @override
  String get settings => 'Pengaturan';
  @override
  String get appSettings => 'Pengaturan Aplikasi';
  @override
  String get language => 'Bahasa';
  @override
  String get theme => 'Tema';
  @override
  String get notifications => 'Notifikasi';
  @override
  String get inventory => 'Inventori';
  @override
  String get display => 'Tampilan';
  @override
  String get other => 'Lainnya';

  @override
  String get selectLanguage => 'Pilih Bahasa';
  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';
  @override
  String get english => 'English';

  @override
  String get selectTheme => 'Pilih Tema';
  @override
  String get lightTheme => 'Terang';
  @override
  String get darkTheme => 'Gelap';
  @override
  String get systemTheme => 'Sesuai Sistem';
  @override
  String get primaryColor => 'Warna Utama';

  @override
  String get lowStockNotifications => 'Notifikasi Stok Rendah';
  @override
  String get expiryNotifications => 'Notifikasi Kadaluarsa';
  @override
  String get transactionNotifications => 'Notifikasi Transaksi';

  @override
  String get defaultLowStockThreshold => 'Batas Stok Rendah Default';
  @override
  String get defaultLowStockItemsThreshold => 'Batas Item Stok Rendah Default';
  @override
  String get thresholdDescription => 'Nilai default untuk item inventori baru';

  @override
  String get dateFormat => 'Format Tanggal';
  @override
  String get currencySymbol => 'Simbol Mata Uang';
  @override
  String get currencyLocale => 'Lokalisasi Mata Uang';

  @override
  String get autoBackup => 'Backup Otomatis';
  @override
  String get autoBackupInterval => 'Interval Backup Otomatis';
  @override
  String get soundEffects => 'Efek Suara';
  @override
  String get hapticFeedback => 'Getaran';
  @override
  String get days => 'hari';

  @override
  String get save => 'Simpan';
  @override
  String get cancel => 'Batal';
  @override
  String get reset => 'Reset';
  @override
  String get resetToDefault => 'Reset ke Default';
  @override
  String get savedSuccessfully => 'Pengaturan berhasil disimpan';
  @override
  String get resetSuccessfully => 'Pengaturan berhasil direset';

  @override
  String get enabled => 'Diaktifkan';
  @override
  String get disabled => 'Dinonaktifkan';
  @override
  String get currentValue => 'Nilai saat ini';

  @override
  String get dashboard => 'Dashboard';
  @override
  String get products => 'Produk';
  @override
  String get pos => 'POS';
  @override
  String get transactionHistory => 'Riwayat Transaksi';
  @override
  String get reports => 'Laporan';
  @override
  String get suppliers => 'Supplier';
  @override
  String get scanItem => 'Pindai Item';

  @override
  String get retry => 'Coba Lagi';
  @override
  String get delete => 'Hapus';
  @override
  String get deleteItem => 'Hapus Item';
  @override
  String get deleteProduct => 'Hapus Produk';
  @override
  String get edit => 'Edit';
  @override
  String get add => 'Tambah';
  @override
  String get search => 'Cari';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Urutkan';
  @override
  String get loading => 'Memuat...';
  @override
  String get error => 'Error';
  @override
  String get noData => 'Tidak ada data';
  @override
  String get noItemsFound => 'Tidak ada item ditemukan';
  @override
  String get noProductsFound => 'Tidak ada produk ditemukan';

  @override
  String get inventoryDistributionByCategory => 'Distribusi Inventori berdasarkan Kategori';
  @override
  String get inventoryStatus => 'Status Inventori';
  @override
  String get totalItems => 'Total Item';
  @override
  String get totalProducts => 'Total Produk';
  @override
  String get lowStockItems => 'Item Stok Rendah';
  @override
  String get financialSummary => 'Ringkasan Keuangan';
  @override
  String get totalInventoryCost => 'Total Biaya Inventori';
  @override
  String get potentialRevenue => 'Pendapatan Potensial';
  @override
  String get potentialProfit => 'Keuntungan Potensial';
  @override
  String get topInventoryItems => 'Item Inventori Teratas';
  @override
  String get topProducts => 'Produk Teratas';

  @override
  String get loadingInventoryItems => 'Memuat item inventori...';
  @override
  String get unableToLoadInventory => 'Tidak dapat memuat inventori.';
  @override
  String get itemDeleted => 'Item dihapus';
  @override
  String get tapToCreateFirstItem => 'Ketuk tombol + untuk membuat item pertama Anda';

  @override
  String get loadingProducts => 'Memuat produk...';
  @override
  String get unableToLoadProducts => 'Tidak dapat memuat produk.';
  @override
  String get tapToCreateFirstProduct => 'Ketuk tombol + untuk membuat produk pertama Anda';

  @override
  String get areYouSure => 'Apakah Anda yakin?';
  @override
  String get thisActionCannotBeUndone => 'Tindakan ini tidak dapat dibatalkan';
  @override
  String get home => 'Beranda';

  @override
  String get posSystem => 'Sistem POS';
  @override
  String get transactionCompleted => 'Transaksi selesai! Total:';
  @override
  String get total => 'Total';
  @override
  String get clear => 'Hapus';
  @override
  String get processTransaction => 'Proses Transaksi';

  @override
  String get allTransactions => 'Semua Transaksi';
  @override
  String get additions => 'Penambahan';
  @override
  String get deductions => 'Pengurangan';
  @override
  String get transfers => 'Transfer';

  @override
  String get cartCleared => 'Keranjang dikosongkan';
  @override
  String get subtotal => 'Subtotal:';

  @override
  String get cost => 'Biaya:';
  @override
  String get sell => 'Jual:';
  @override
  String get cogs => 'COGS:';
  @override
  String get profit => 'keuntungan';
  @override
  String get components => 'komponen';
  @override
  String get componentsCount => 'Komponen';

  @override
  String get tryAgain => 'Coba Lagi';
  @override
  String get selectDateRange => 'Pilih Rentang Tanggal';
  @override
  String get allCategories => 'Semua Kategori';
  @override
  String get addComponent => 'Tambah Komponen';
  @override
  String get pleaseSelectInventoryItem => 'Silakan pilih item inventori';
  @override
  String get editComponent => 'Edit Komponen';

  @override
  String get inventoryItems => 'Item Inventori';
  @override
  String get totalValue => 'Total Nilai';
  @override
  String get lowStock => 'Stok Rendah';
}

/// English
class AppLocalizationsEn extends AppLocalizations {
  @override
  String get settings => 'Settings';
  @override
  String get appSettings => 'App Settings';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get notifications => 'Notifications';
  @override
  String get inventory => 'Inventory';
  @override
  String get display => 'Display';
  @override
  String get other => 'Other';

  @override
  String get selectLanguage => 'Select Language';
  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';
  @override
  String get english => 'English';

  @override
  String get selectTheme => 'Select Theme';
  @override
  String get lightTheme => 'Light';
  @override
  String get darkTheme => 'Dark';
  @override
  String get systemTheme => 'System';
  @override
  String get primaryColor => 'Primary Color';

  @override
  String get lowStockNotifications => 'Low Stock Notifications';
  @override
  String get expiryNotifications => 'Expiry Notifications';
  @override
  String get transactionNotifications => 'Transaction Notifications';

  @override
  String get defaultLowStockThreshold => 'Default Low Stock Threshold';
  @override
  String get defaultLowStockItemsThreshold => 'Default Low Stock Items Threshold';
  @override
  String get thresholdDescription => 'Default value for new inventory items';

  @override
  String get dateFormat => 'Date Format';
  @override
  String get currencySymbol => 'Currency Symbol';
  @override
  String get currencyLocale => 'Currency Locale';

  @override
  String get autoBackup => 'Auto Backup';
  @override
  String get autoBackupInterval => 'Auto Backup Interval';
  @override
  String get soundEffects => 'Sound Effects';
  @override
  String get hapticFeedback => 'Haptic Feedback';
  @override
  String get days => 'days';

  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get reset => 'Reset';
  @override
  String get resetToDefault => 'Reset to Default';
  @override
  String get savedSuccessfully => 'Settings saved successfully';
  @override
  String get resetSuccessfully => 'Settings reset successfully';

  @override
  String get enabled => 'Enabled';
  @override
  String get disabled => 'Disabled';
  @override
  String get currentValue => 'Current value';

  @override
  String get dashboard => 'Dashboard';
  @override
  String get products => 'Products';
  @override
  String get pos => 'POS';
  @override
  String get transactionHistory => 'Transaction History';
  @override
  String get reports => 'Reports';
  @override
  String get suppliers => 'Suppliers';
  @override
  String get scanItem => 'Scan Item';

  @override
  String get retry => 'Retry';
  @override
  String get delete => 'Delete';
  @override
  String get deleteItem => 'Delete Item';
  @override
  String get deleteProduct => 'Delete Product';
  @override
  String get edit => 'Edit';
  @override
  String get add => 'Add';
  @override
  String get search => 'Search';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Sort';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get noData => 'No data';
  @override
  String get noItemsFound => 'No items found';
  @override
  String get noProductsFound => 'No products found';

  @override
  String get inventoryDistributionByCategory => 'Inventory Distribution by Category';
  @override
  String get inventoryStatus => 'Inventory Status';
  @override
  String get totalItems => 'Total Items';
  @override
  String get totalProducts => 'Total Products';
  @override
  String get lowStockItems => 'Low Stock Items';
  @override
  String get financialSummary => 'Financial Summary';
  @override
  String get totalInventoryCost => 'Total Inventory Cost';
  @override
  String get potentialRevenue => 'Potential Revenue';
  @override
  String get potentialProfit => 'Potential Profit';
  @override
  String get topInventoryItems => 'Top Inventory Items';
  @override
  String get topProducts => 'Top Products';

  @override
  String get loadingInventoryItems => 'Loading inventory items...';
  @override
  String get unableToLoadInventory => 'Unable to load inventory.';
  @override
  String get itemDeleted => 'Item deleted';
  @override
  String get tapToCreateFirstItem => 'Tap the + button to create your first item';

  @override
  String get loadingProducts => 'Loading products...';
  @override
  String get unableToLoadProducts => 'Unable to load products.';
  @override
  String get tapToCreateFirstProduct => 'Tap the + button to create your first product';

  @override
  String get areYouSure => 'Are you sure?';
  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone';
  @override
  String get home => 'Home';

  @override
  String get posSystem => 'POS System';
  @override
  String get transactionCompleted => 'Transaction completed! Total:';
  @override
  String get total => 'Total';
  @override
  String get clear => 'Clear';
  @override
  String get processTransaction => 'Process Transaction';

  @override
  String get allTransactions => 'All Transactions';
  @override
  String get additions => 'Additions';
  @override
  String get deductions => 'Deductions';
  @override
  String get transfers => 'Transfers';

  @override
  String get cartCleared => 'Cart cleared';
  @override
  String get subtotal => 'Subtotal:';

  @override
  String get cost => 'Cost:';
  @override
  String get sell => 'Sell:';
  @override
  String get cogs => 'COGS:';
  @override
  String get profit => 'profit';
  @override
  String get components => 'components';
  @override
  String get componentsCount => 'Components';

  @override
  String get tryAgain => 'Try Again';
  @override
  String get selectDateRange => 'Select Date Range';
  @override
  String get allCategories => 'All Categories';
  @override
  String get addComponent => 'Add Component';
  @override
  String get pleaseSelectInventoryItem => 'Please select an inventory item';
  @override
  String get editComponent => 'Edit Component';

  @override
  String get inventoryItems => 'Inventory Items';
  @override
  String get totalValue => 'Total Value';
  @override
  String get lowStock => 'Low Stock';
}

/// Localizations Delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'id':
        return AppLocalizationsId();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}

