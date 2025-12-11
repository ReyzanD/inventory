import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';

class ProductComponentsWidget extends StatefulWidget {
  final List<ProductComponent> components;
  final Function(List<ProductComponent>) onComponentsChanged;

  const ProductComponentsWidget({
    required this.components,
    required this.onComponentsChanged,
  });

  @override
  _ProductComponentsWidgetState createState() =>
      _ProductComponentsWidgetState();
}

class _ProductComponentsWidgetState extends State<ProductComponentsWidget> {
  String _selectedInventoryItem = '';
  double _quantityNeeded = 1.0;
  String _unit = 'g';

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final availableItems = provider.inventoryItems;

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                if (availableItems.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value:
                        _selectedInventoryItem.isEmpty &&
                            availableItems.isNotEmpty
                        ? availableItems.first.id
                        : _selectedInventoryItem,
                    decoration: InputDecoration(
                      labelText: 'Select Inventory Item',
                      border: OutlineInputBorder(),
                    ),
                    items: availableItems
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              '${item.name} (${item.quantity.toStringAsFixed(2)} ${item.unit})',
                            ),
                          ),
                        )
                        .toList(),
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
                          items: ['g', 'kg', 'mg', 'L', 'ml', 'pieces']
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
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
                    onPressed: () => _addComponent(provider),
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
        );
      },
    );
  }

  void _addComponent(InventoryProvider provider) {
    if (_selectedInventoryItem.isNotEmpty) {
      provider.getInventoryItemById(_selectedInventoryItem);

      // Check if the inventory item is already added to components
      bool alreadyAdded = widget.components.any(
        (comp) => comp.inventoryItemId == _selectedInventoryItem,
      );

      if (alreadyAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This inventory item is already added as a component',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        final newComponents = List<ProductComponent>.from(widget.components);
        newComponents.add(
          ProductComponent(
            inventoryItemId: _selectedInventoryItem,
            quantityNeeded: _quantityNeeded,
            unit: _unit,
          ),
        );
        widget.onComponentsChanged(newComponents);
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
  }
}

class ProductComponentsList extends StatelessWidget {
  final List<ProductComponent> components;
  final Function(int, ProductComponent) onComponentUpdated;
  final Function(int) onComponentRemoved;

  const ProductComponentsList({
    required this.components,
    required this.onComponentUpdated,
    required this.onComponentRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 200,
          child: ListView.builder(
            itemCount: components.length,
            itemBuilder: (context, index) {
              final component = components[index];
              final item = provider.getInventoryItemById(
                component.inventoryItemId,
              );

              return Card(
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  title: Text(
                    '${item?.name ?? 'Unknown Item'}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${component.quantityNeeded.toStringAsFixed(2)} ${component.unit} required',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditDialog(context, index, component),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.red),
                        onPressed: () => onComponentRemoved(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    int index,
    ProductComponent component,
  ) {
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
                items: ['g', 'kg', 'mg', 'L', 'ml', 'pieces']
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
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
                onComponentUpdated(
                  index,
                  ProductComponent(
                    inventoryItemId: component.inventoryItemId,
                    quantityNeeded: newQuantity,
                    unit: newUnit,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
