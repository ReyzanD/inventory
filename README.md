# Inventory Management System

Aplikasi manajemen inventori yang komprehensif dibangun dengan Flutter untuk mengelola stok barang, produk, transaksi, dan laporan. Aplikasi ini mendukung multi-platform (Android, iOS, Web, Windows, macOS, Linux) dengan fitur-fitur lengkap untuk manajemen inventori modern.

## 📋 Fitur Utama

### Manajemen Inventori

- ✅ **CRUD Inventory Items** - Tambah, edit, hapus, dan lihat item inventori
- ✅ **Kategori & Organisasi** - Organisasi item berdasarkan kategori
- ✅ **Low Stock Alerts** - Notifikasi otomatis untuk stok rendah dengan threshold yang dapat dikonfigurasi
- ✅ **Expiry Tracking** - Pelacakan tanggal kadaluarsa untuk item yang mudah rusak
- ✅ **Search & Filter** - Pencarian dan filter berdasarkan kategori, tanggal, dan stok
- ✅ **Sort Options** - Pengurutan berdasarkan nama, kuantitas, atau tanggal

### Manajemen Produk

- ✅ **Product Management** - Kelola produk yang terdiri dari beberapa komponen inventori
- ✅ **COGS Calculation** - Perhitungan Cost of Goods Sold otomatis
- ✅ **Component Tracking** - Pelacakan komponen yang digunakan dalam produk

### Point of Sale (POS)

- ✅ **POS System** - Sistem penjualan terintegrasi
- ✅ **Automatic Inventory Reduction** - Pengurangan inventori otomatis saat penjualan
- ✅ **Transaction Recording** - Pencatatan semua transaksi penjualan

### Laporan & Analytics

- ✅ **Dashboard Analytics** - Dashboard dengan statistik dan grafik
- ✅ **PDF Reports** - Generate laporan PDF dengan chart dan analisis
- ✅ **Date Range Filtering** - Filter laporan berdasarkan rentang tanggal
- ✅ **Comparative Analysis** - Analisis perbandingan bulan ke bulan

### Audit Trail & History

- ✅ **Transaction History** - Riwayat lengkap semua transaksi
- ✅ **Audit Trail** - Pelacakan semua perubahan dengan timestamp dan user attribution
- ✅ **Change Tracking** - Pelacakan perubahan kuantitas dan detail lainnya

### Backup & Restore

- ✅ **CSV Export/Import** - Ekspor dan impor data dalam format CSV
- ✅ **Data Validation** - Validasi data saat import
- ✅ **Backup Management** - Manajemen backup data

### Notifikasi

- ✅ **Low Stock Notifications** - Notifikasi untuk stok rendah
- ✅ **Expiry Alerts** - Peringatan untuk item yang akan kadaluarsa
- ✅ **Notification Center** - Pusat notifikasi terpusat

### Supplier Management

- ✅ **Supplier Tracking** - Manajemen supplier
- ✅ **Supplier Performance** - Metrik performa supplier
- ✅ **Supplier Linking** - Menghubungkan supplier dengan item inventori

### Fitur Tambahan

- ✅ **Barcode Scanner** - Pemindaian barcode untuk item
- ✅ **Responsive Design** - Desain responsif untuk berbagai ukuran layar
- ✅ **Offline Support** - Dukungan mode offline dengan sinkronisasi
- ✅ **Multi-platform** - Berjalan di Android, iOS, Web, Windows, macOS, Linux

## 🚀 Instalasi & Setup

### Prerequisites

- Flutter SDK (3.10.3 atau lebih baru)
- Dart SDK (3.10.3 atau lebih baru)
- Android Studio / VS Code dengan Flutter extension
- Git

### Langkah Instalasi

1. **Clone repository**

   ```bash
   git clone <repository-url>
   cd inventory
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run aplikasi**

   ```bash
   # Untuk development
   flutter run

   # Untuk platform spesifik
   flutter run -d windows
   flutter run -d chrome
   flutter run -d android
   ```

### Setup Database

Aplikasi menggunakan SQLite untuk penyimpanan lokal. Database akan dibuat otomatis saat pertama kali menjalankan aplikasi.

Untuk desktop platforms (Windows, macOS, Linux), aplikasi menggunakan `sqflite_common_ffi` yang sudah dikonfigurasi di `main.dart`.

## 📁 Struktur Proyek

```
lib/
├── constants/          # Konstanta aplikasi
├── models/            # Data models
│   ├── inventory_item.dart
│   ├── product.dart
│   ├── inventory_transaction.dart
│   ├── inventory_notification.dart
│   ├── supplier.dart
│   └── pos_transaction.dart
├── providers/         # State management
│   ├── inventory_provider.dart
│   └── riverpod_inventory_provider.dart
├── screens/           # UI Screens
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   ├── product_screen.dart
│   ├── pos_screen.dart
│   ├── transaction_history_screen.dart
│   ├── notification_screen.dart
│   ├── backup_restore_screen.dart
│   ├── reports_screen.dart
│   ├── settings_screen.dart
│   └── ...
├── services/          # Business logic & services
│   ├── inventory_service.dart
│   ├── audit_service.dart
│   ├── backup_restore_service.dart
│   ├── connectivity_service.dart
│   ├── logging_service.dart
│   └── ...
├── widgets/           # Reusable widgets
│   ├── dashboard_widgets.dart
│   ├── inventory_item_card.dart
│   ├── search_and_filter_bar.dart
│   └── ...
├── utils/             # Utility functions
│   ├── type_converter.dart
│   └── debouncer.dart
└── themes/            # App themes
    └── app_theme.dart

test/                  # Unit & integration tests
├── inventory_provider_test.dart
├── type_converter_test.dart
└── ...
```

## 💻 Teknologi yang Digunakan

### Core

- **Flutter** - Framework UI cross-platform
- **Dart** - Bahasa pemrograman

### State Management

- **Provider** - State management (legacy)
- **Riverpod** - State management modern

### Database

- **SQLite** - Database lokal
- **sqflite** - SQLite plugin untuk Flutter
- **sqflite_common_ffi** - SQLite untuk desktop platforms

### UI & Charts

- **fl_chart** - Library untuk chart dan grafik
- **Material Design** - Design system

### Utilities

- **get_it** - Dependency injection
- **logging** - Logging service
- **intl** - Internationalization & date formatting
- **uuid** - Unique ID generation
- **csv** - CSV parsing & generation
- **pdf** - PDF generation
- **printing** - PDF printing
- **connectivity_plus** - Network connectivity detection
- **rxdart** - Reactive programming

### Testing

- **flutter_test** - Unit testing
- **integration_test** - Integration testing
- **mockito** - Mocking untuk testing

## 📖 Cara Penggunaan

### Menambah Item Inventori

1. Buka menu **Inventory**
2. Klik tombol **+ Add Item**
3. Isi form dengan detail item:
   - Nama, deskripsi, kategori
   - Kuantitas dan unit
   - Harga beli dan harga jual
   - Low stock threshold
   - Tanggal kadaluarsa (opsional)
4. Klik **Save**

### Mengelola Produk

1. Buka menu **Products**
2. Klik **+ Add Product**
3. Isi detail produk dan tambahkan komponen dari inventori
4. Sistem akan menghitung COGS otomatis

### Point of Sale

1. Buka menu **POS**
2. Pilih produk yang akan dijual
3. Masukkan kuantitas
4. Klik **Sell**
5. Inventori akan berkurang otomatis

### Generate Laporan

1. Buka menu **Reports**
2. Pilih jenis laporan
3. Pilih rentang tanggal (opsional)
4. Klik **Generate PDF**

### Backup & Restore

1. Buka menu **Settings** > **Backup & Restore**
2. Untuk backup: Klik **Export to CSV**
3. Untuk restore: Klik **Import from CSV** dan pilih file

## 🧪 Testing

### Menjalankan Tests

```bash
# Semua tests
flutter test

# Test spesifik
flutter test test/inventory_provider_test.dart

# Integration tests
flutter test integration_test/integration_test.dart
```

### Coverage

```bash
flutter test --coverage
```

## 🛠️ Development

### Code Style

Proyek menggunakan `flutter_lints` untuk code style. Pastikan untuk menjalankan:

```bash
flutter analyze
```

### Build untuk Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

## 📝 TODO & Roadmap

Lihat [TODO.md](TODO.md) untuk daftar lengkap task yang sudah selesai dan yang masih dalam progress.

## 🤝 Kontribusi

Kontribusi sangat diterima! Untuk berkontribusi:

1. Fork repository
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

### Guidelines

- Ikuti code style yang sudah ditetapkan
- Tambahkan tests untuk fitur baru
- Update dokumentasi jika diperlukan
- Pastikan semua tests pass sebelum submit PR

## 📄 License

Proyek ini menggunakan license yang ditentukan oleh pemilik repository.

## 👥 Authors

- ReyN

## 🙏 Acknowledgments

- Flutter team untuk framework yang luar biasa
- Semua kontributor open source yang membuat package-package yang digunakan

---

**Note**: Aplikasi ini masih dalam tahap pengembangan aktif. Fitur-fitur baru dan perbaikan akan ditambahkan secara berkala.
