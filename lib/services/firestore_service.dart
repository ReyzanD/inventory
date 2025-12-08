// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/inventory_item.dart';
// import '../models/product.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Inventory Item methods
//   Future<void> addInventoryItem(InventoryItem item) async {
//     await _firestore.collection('inventory').doc(item.id).set(item.toMap());
//   }

//   Future<void> updateInventoryItem(InventoryItem item) async {
//     await _firestore.collection('inventory').doc(item.id).update(item.toMap());
//   }

//   Future<void> deleteInventoryItem(String id) async {
//     await _firestore.collection('inventory').doc(id).delete();
//   }

//   Stream<List<InventoryItem>> inventoryItemsStream() {
//     return _firestore
//         .collection('inventory')
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => InventoryItem.fromMap(doc.data()!))
//             .toList());
//   }

//   Future<List<InventoryItem>> getAllInventoryItems() async {
//     final snapshot = await _firestore.collection('inventory').get();
//     return snapshot.docs
//         .map((doc) => InventoryItem.fromMap(doc.data()!))
//         .toList();
//   }

//   Future<InventoryItem?> getInventoryItemById(String id) async {
//     final doc = await _firestore.collection('inventory').doc(id).get();
//     if (doc.exists) {
//       return InventoryItem.fromMap(doc.data()!);
//     }
//     return null;
//   }

//   // Product methods
//   Future<void> addProduct(Product product) async {
//     await _firestore.collection('products').doc(product.id).set(product.toMap());
//   }

//   Future<void> updateProduct(Product product) async {
//     await _firestore.collection('products').doc(product.id).update(product.toMap());
//   }

//   Future<void> deleteProduct(String id) async {
//     await _firestore.collection('products').doc(id).delete();
//   }

//   Stream<List<Product>> productsStream() {
//     return _firestore
//         .collection('products')
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => Product.fromMap(doc.data()!))
//             .toList());
//   }

//   Future<List<Product>> getAllProducts() async {
//     final snapshot = await _firestore.collection('products').get();
//     return snapshot.docs
//         .map((doc) => Product.fromMap(doc.data()!))
//         .toList();
//   }

//   Future<Product?> getProductById(String id) async {
//     final doc = await _firestore.collection('products').doc(id).get();
//     if (doc.exists) {
//       return Product.fromMap(doc.data()!);
//     }
//     return null;
//   }
// }
