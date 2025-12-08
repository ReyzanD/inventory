import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_database_service.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Test',
      home: TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final LocalDatabaseService _db = LocalDatabaseService();
  String _message = 'Initializing database...';
  
  @override
  void initState() {
    super.initState();
    _testDatabase();
  }
  
  Future<void> _testDatabase() async {
    try {
      // Initialize database
      await _db.database;
      
      // Create test inventory item
      final testItem = InventoryItem(
        id: 'test1',
        name: 'Test Item',
        description: 'This is a test item',
        quantity: 10.0,
        unit: 'kg',
        costPerUnit: 5.0,
        sellingPricePerUnit: 10.0,
        dateAdded: DateTime.now(),
        category: 'Test',
      );
      
      // Add test item
      await _db.insertInventoryItem(testItem);
      
      // Get all items
      final items = await _db.getAllInventoryItems();
      
      setState(() {
        _message = 'Database test successful! Found ${items.length} items.';
      });
    } catch (e) {
      setState(() {
        _message = 'Database test failed: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Test'),
      ),
      body: Center(
        child: Text(
          _message,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}