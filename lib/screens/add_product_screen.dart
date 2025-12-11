import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/form_widgets.dart';
import '../widgets/product_components_widget.dart';
import '../utils/validation_utils.dart';
import '../utils/error_handler.dart';
import '../utils/form_save_helper.dart';

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
                  CurrencyTextFormField(
                    controller: _sellingPriceController,
                    label: 'Selling Price',
                    validator: ValidationUtils.validatePrice,
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
                    onPressed: () async {
                      if (_components.isEmpty) {
                        ErrorHandler.showErrorSnackBar(
                          context,
                          'Please add at least one component',
                          customMessage: 'Please add at least one component',
                        );
                        return;
                      }

                      final success = await FormSaveHelper.saveProduct(
                        context: context,
                        formKey: _formKey,
                        existingProduct: widget.product,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        sellingPrice: _sellingPriceController.text,
                        category: _selectedCategory,
                        components: _components,
                        saveFunction: widget.product != null
                            ? (product) => provider.updateProduct(product)
                            : (product) => provider.addProduct(product),
                        successMessage: widget.product != null
                            ? 'Product updated successfully'
                            : 'Product created successfully',
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
