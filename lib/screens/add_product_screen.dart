import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/form_widgets.dart';
import '../widgets/currency_widgets.dart';
import '../widgets/product_components_widget.dart';

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
  List<String> _categories = [
    'General',
    'Food',
    'Beverages',
    'Electronics',
    'Clothing',
    'Other',
  ];

  // For product components
  late List<ProductComponent> _components;

  @override
  void initState() {
    super.initState();

    // Initialize values based on whether we're editing or creating
    if (widget.product != null) {
      // Editing existing product
      _nameController = TextEditingController(text: widget.product!.name);
      _descriptionController = TextEditingController(
        text: widget.product!.description,
      );
      _sellingPriceController = TextEditingController(
        text: widget.product!.sellingPrice.toString(),
      );
      _categoryController = TextEditingController(
        text: widget.product!.category,
      );
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
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Product Components',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ProductComponentsWidget(
                    components: _components,
                    onComponentsChanged: (newComponents) {
                      setState(() {
                        _components = newComponents;
                      });
                    },
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
                    ProductComponentsList(
                      components: _components,
                      onComponentUpdated: (index, updatedComponent) {
                        setState(() {
                          _components[index] = updatedComponent;
                        });
                      },
                      onComponentRemoved: (index) {
                        setState(() {
                          _components.removeAt(index);
                        });
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_components.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please add at least one component',
                              ),
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
                            sellingPrice: double.parse(
                              _sellingPriceController.text,
                            ),
                            components: _components,
                            dateCreated: widget
                                .product!
                                .dateCreated, // Keep original creation date
                            category: _selectedCategory,
                          );

                          provider.updateProduct(updatedProduct);
                        } else {
                          // Create new product
                          final newProduct = Product(
                            id: Uuid().v4(),
                            name: _nameController.text,
                            description: _descriptionController.text,
                            sellingPrice: double.parse(
                              _sellingPriceController.text,
                            ),
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
                    child: Text(
                      widget.product != null
                          ? 'Update Product'
                          : 'Create Product',
                    ),
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
