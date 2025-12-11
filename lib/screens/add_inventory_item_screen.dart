import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../widgets/form_widgets.dart';
import '../utils/validation_utils.dart';
import '../utils/form_save_helper.dart';
import '../utils/provider_extensions.dart';

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
  late TextEditingController _lowStockThresholdController;
  late TextEditingController _categoryController;

  late String _selectedUnit;
  late String _selectedCategory;
  DateTime? _expiryDate;

  List<String> _units = ['kg', 'g', 'mg', 'L', 'ml', 'pieces'];
  List<String> _categories = [
    'General',
    'Food',
    'Beverages',
    'Electronics',
    'Clothing',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers based on whether we're editing or adding a new item
    if (widget.inventoryItem != null) {
      // Editing existing item
      _nameController = TextEditingController(text: widget.inventoryItem!.name);
      _descriptionController = TextEditingController(
        text: widget.inventoryItem!.description,
      );
      _quantityController = TextEditingController(
        text: widget.inventoryItem!.quantity.toString(),
      );
      _costPerUnitController = TextEditingController(
        text: widget.inventoryItem!.costPerUnit.toString(),
      );
      _sellingPriceController = TextEditingController(
        text: widget.inventoryItem!.sellingPricePerUnit.toString(),
      );
      _lowStockThresholdController = TextEditingController(
        text: widget.inventoryItem!.lowStockThreshold.toString(),
      );
      _categoryController = TextEditingController(
        text: widget.inventoryItem!.category,
      );
      _selectedUnit = widget.inventoryItem!.unit;
      _selectedCategory = widget.inventoryItem!.category;
      _expiryDate = widget.inventoryItem!.expiryDate;
    } else {
      // Adding new item
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _quantityController = TextEditingController();
      _costPerUnitController = TextEditingController();
      _sellingPriceController = TextEditingController();
      _lowStockThresholdController = TextEditingController(text: '5');
      _categoryController = TextEditingController();
      _selectedUnit = 'kg';
      _selectedCategory = 'General';
      _expiryDate = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _costPerUnitController.dispose();
    _sellingPriceController.dispose();
    _lowStockThresholdController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.inventoryItem != null
              ? 'Edit Inventory Item'
              : 'Add Inventory Item',
        ),
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
                validator: ValidationUtils.validateName,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: ValidationUtils.validateDescription,
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
                      validator: ValidationUtils.validateQuantity,
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
                      items: _units
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
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
                validator: ValidationUtils.validatePrice,
              ),
              SizedBox(height: 16),
              CurrencyTextFormField(
                controller: _sellingPriceController,
                label: 'Selling Price Per Unit',
                validator: ValidationUtils.validatePrice,
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
              SizedBox(height: 16),
              TextFormField(
                controller: _lowStockThresholdController,
                decoration: InputDecoration(
                  labelText: 'Low Stock Threshold',
                  border: OutlineInputBorder(),
                  hintText: 'Enter minimum quantity before alert',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => ValidationUtils.validatePositiveNumber(
                  value,
                  'Low Stock Threshold',
                ),
              ),
              SizedBox(height: 16),
              // Expiry date field
              ListTile(
                title: Text('Expiry Date'),
                subtitle: Text(
                  _expiryDate != null
                      ? 'Expires: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'No expiry date set',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _expiryDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final success = await FormSaveHelper.saveInventoryItem(
                    context: context,
                    formKey: _formKey,
                    existingItem: widget.inventoryItem,
                    name: _nameController.text,
                    description: _descriptionController.text,
                    quantity: _quantityController.text,
                    unit: _selectedUnit,
                    costPerUnit: _costPerUnitController.text,
                    sellingPrice: _sellingPriceController.text,
                    category: _selectedCategory,
                    lowStockThreshold: _lowStockThresholdController.text,
                    expiryDate: _expiryDate,
                    saveFunction: widget.inventoryItem != null
                        ? (item) => context.inventoryProvider
                              .updateInventoryItem(item)
                        : (item) =>
                              context.inventoryProvider.addInventoryItem(item),
                    successMessage: widget.inventoryItem != null
                        ? 'Inventory item updated successfully'
                        : 'Inventory item added successfully',
                  );

                  if (success) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.inventoryItem != null ? 'Update Item' : 'Add Item',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
