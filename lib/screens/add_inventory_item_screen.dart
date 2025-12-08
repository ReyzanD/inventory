import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../widgets/form_widgets.dart';
import '../widgets/currency_widgets.dart';

class AddInventoryItemScreen extends StatefulWidget {
  final InventoryItem? inventoryItem; // Make this optional for editing

  AddInventoryItemScreen({this.inventoryItem});

  @override
  _AddInventoryItemScreenState createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _costPerUnitController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _categoryController;

  late String _selectedUnit;
  late String _selectedCategory;

  List<String> _units = ['kg', 'g', 'mg', 'L', 'ml', 'pieces'];
  List<String> _categories = ['General', 'Food', 'Beverages', 'Electronics', 'Clothing', 'Other'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers based on whether we're editing or adding a new item
    if (widget.inventoryItem != null) {
      // Editing existing item
      _nameController = TextEditingController(text: widget.inventoryItem!.name);
      _descriptionController = TextEditingController(text: widget.inventoryItem!.description);
      _quantityController = TextEditingController(text: widget.inventoryItem!.quantity.toString());
      _costPerUnitController = TextEditingController(text: widget.inventoryItem!.costPerUnit.toString());
      _sellingPriceController = TextEditingController(text: widget.inventoryItem!.sellingPricePerUnit.toString());
      _categoryController = TextEditingController(text: widget.inventoryItem!.category);
      _selectedUnit = widget.inventoryItem!.unit;
      _selectedCategory = widget.inventoryItem!.category;
    } else {
      // Adding new item
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _quantityController = TextEditingController();
      _costPerUnitController = TextEditingController();
      _sellingPriceController = TextEditingController();
      _categoryController = TextEditingController();
      _selectedUnit = 'kg';
      _selectedCategory = 'General';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _costPerUnitController.dispose();
    _sellingPriceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inventoryItem != null ? 'Edit Inventory Item' : 'Add Inventory Item'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
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
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: _units.map((unit) =>
                        DropdownMenuItem(value: unit, child: Text(unit))
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CurrencyTextFormField(
                controller: _costPerUnitController,
                label: 'Cost Per Unit',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost per unit';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CurrencyTextFormField(
                controller: _sellingPriceController,
                label: 'Selling Price Per Unit',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter selling price per unit';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CategoryDropdownFormField(
                value: _selectedCategory,
                categories: _categories,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.inventoryItem != null) {
                      // Update existing item
                      final updatedItem = InventoryItem(
                        id: widget.inventoryItem!.id,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        quantity: double.parse(_quantityController.text),
                        unit: _selectedUnit,
                        costPerUnit: double.parse(_costPerUnitController.text),
                        sellingPricePerUnit: double.parse(_sellingPriceController.text),
                        dateAdded: widget.inventoryItem!.dateAdded, // Keep original date
                        category: _selectedCategory,
                      );

                      Provider.of<InventoryProvider>(context, listen: false)
                          .updateInventoryItem(updatedItem);
                    } else {
                      // Add new item
                      final newItem = InventoryItem(
                        id: Uuid().v4(),
                        name: _nameController.text,
                        description: _descriptionController.text,
                        quantity: double.parse(_quantityController.text),
                        unit: _selectedUnit,
                        costPerUnit: double.parse(_costPerUnitController.text),
                        sellingPricePerUnit: double.parse(_sellingPriceController.text),
                        dateAdded: DateTime.now(),
                        category: _selectedCategory,
                      );

                      Provider.of<InventoryProvider>(context, listen: false)
                          .addInventoryItem(newItem);
                    }

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(widget.inventoryItem != null ? 'Update Item' : 'Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}