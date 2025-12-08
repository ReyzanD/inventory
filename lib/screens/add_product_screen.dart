import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../models/inventory_item.dart';
import '../widgets/form_widgets.dart';
import '../widgets/currency_widgets.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product; // Make product optional for editing

  AddProductScreen({this.product});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _categoryController;

  late String _selectedCategory;
  List<String> _categories = ['General', 'Food', 'Beverages', 'Electronics', 'Clothing', 'Other'];

  // For product components
  late List<ProductComponent> _components;
  String _selectedInventoryItem = '';
  double _quantityNeeded = 1.0;
  String _unit = 'g';

  @override
  void initState() {
    super.initState();

    // Initialize values based on whether we're editing or creating
    if (widget.product != null) {
      // Editing existing product
      _nameController = TextEditingController(text: widget.product!.name);
      _descriptionController = TextEditingController(text: widget.product!.description);
      _sellingPriceController = TextEditingController(text: widget.product!.sellingPrice.toString());
      _categoryController = TextEditingController(text: widget.product!.category);
      _selectedCategory = widget.product!.category;
      _components = List.from(widget.product!.components);
    } else {
      // Creating new product
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _sellingPriceController = TextEditingController();
      _categoryController = TextEditingController();
      _selectedCategory = 'General';
      _components = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sellingPriceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Create Product'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              // Get all inventory items that can be used as components
              final availableItems = provider.inventoryItems;

              return ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  CurrencyTextFormField(
                    controller: _sellingPriceController,
                    label: 'Selling Price',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter selling price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) =>
                      DropdownMenuItem(value: category, child: Text(category))
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Product Components',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (availableItems.isNotEmpty) ...[
                            DropdownButtonFormField<String>(
                              value: _selectedInventoryItem.isEmpty && availableItems.isNotEmpty
                                ? availableItems.first.id
                                : _selectedInventoryItem,
                              decoration: InputDecoration(
                                labelText: 'Select Inventory Item',
                                border: OutlineInputBorder(),
                              ),
                              items: availableItems.map((item) =>
                                DropdownMenuItem(value: item.id, child: Text('${item.name} (${item.quantity.toStringAsFixed(2)} ${item.unit})'))
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedInventoryItem = value!;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Quantity Needed',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    initialValue: _quantityNeeded.toString(),
                                    onChanged: (value) {
                                      final parsed = double.tryParse(value);
                                      if (parsed != null) {
                                        setState(() {
                                          _quantityNeeded = parsed;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    value: _unit,
                                    decoration: InputDecoration(
                                      labelText: 'Unit',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: ['g', 'kg', 'mg', 'L', 'ml', 'pieces'].map((unit) =>
                                      DropdownMenuItem(value: unit, child: Text(unit))
                                    ).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _unit = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_selectedInventoryItem.isNotEmpty) {
                                  final item = provider.getInventoryItemById(_selectedInventoryItem)!;

                                  // Check if the inventory item is already added to components
                                  bool alreadyAdded = _components.any((comp) => comp.inventoryItemId == _selectedInventoryItem);

                                  if (alreadyAdded) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('This inventory item is already added as a component'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _components.add(ProductComponent(
                                      inventoryItemId: _selectedInventoryItem,
                                      quantityNeeded: _quantityNeeded,
                                      unit: _unit,
                                    ));
                                  });

                                  // Reset form
                                  _quantityNeeded = 1.0;
                                  _unit = 'g';
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Please select an inventory item'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Add Component'),
                            ),
                          ] else ...[
                            Text(
                              'No inventory items available. Please add inventory items first.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_components.isNotEmpty) ...[
                    Text(
                      'Selected Components',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _components.length,
                        itemBuilder: (context, index) {
                          final component = _components[index];
                          final item = provider.getInventoryItemById(component.inventoryItemId);

                          return Card(
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              title: Text(
                                '${item?.name ?? 'Unknown Item'}',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text('${component.quantityNeeded.toStringAsFixed(2)} ${component.unit} required'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Edit the component
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          double newQuantity = component.quantityNeeded;
                                          String newUnit = component.unit;
                                          return AlertDialog(
                                            title: Text('Edit Component'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  initialValue: newQuantity.toString(),
                                                  decoration: InputDecoration(labelText: 'Quantity'),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (value) {
                                                    final parsed = double.tryParse(value);
                                                    if (parsed != null) {
                                                      newQuantity = parsed;
                                                    }
                                                  },
                                                ),
                                                SizedBox(height: 16),
                                                DropdownButtonFormField<String>(
                                                  value: newUnit,
                                                  decoration: InputDecoration(labelText: 'Unit'),
                                                  items: ['g', 'kg', 'mg', 'L', 'ml', 'pieces'].map((unit) =>
                                                    DropdownMenuItem(value: unit, child: Text(unit))
                                                  ).toList(),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      newUnit = value;
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _components[index] = ProductComponent(
                                                      inventoryItemId: component.inventoryItemId,
                                                      quantityNeeded: newQuantity,
                                                      unit: newUnit,
                                                    );
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _components.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_components.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please add at least one component'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (widget.product != null) {
                          // Update existing product
                          final updatedProduct = Product(
                            id: widget.product!.id,
                            name: _nameController.text,
                            description: _descriptionController.text,
                            sellingPrice: double.parse(_sellingPriceController.text),
                            components: _components,
                            dateCreated: widget.product!.dateCreated, // Keep original creation date
                            category: _selectedCategory,
                          );

                          provider.updateProduct(updatedProduct);
                        } else {
                          // Create new product
                          final newProduct = Product(
                            id: Uuid().v4(),
                            name: _nameController.text,
                            description: _descriptionController.text,
                            sellingPrice: double.parse(_sellingPriceController.text),
                            components: _components,
                            dateCreated: DateTime.now(),
                            category: _selectedCategory,
                          );

                          provider.addProduct(newProduct);
                        }

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.product != null ? 'Update Product' : 'Create Product'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}