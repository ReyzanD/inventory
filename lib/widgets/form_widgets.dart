import 'package:flutter/material.dart';

class CurrencyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool withDecimals;

  const CurrencyTextFormField({
    super.key,
    this.controller,
    required this.label,
    this.validator,
    this.onChanged,
    this.withDecimals = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixText: 'Rp ',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: withDecimals),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class UnitDropdownFormField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final List<String> units;

  const UnitDropdownFormField({
    Key? key,
    this.value,
    this.onChanged,
    this.units = const ['kg', 'g', 'mg', 'L', 'ml', 'pieces'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Unit',
        border: OutlineInputBorder(),
      ),
      items: units.map((unit) => 
        DropdownMenuItem(value: unit, child: Text(unit))
      ).toList(),
      onChanged: onChanged,
    );
  }
}

class CategoryDropdownFormField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final List<String> categories;

  const CategoryDropdownFormField({
    Key? key,
    this.value,
    this.onChanged,
    this.categories = const ['General', 'Food', 'Beverages', 'Electronics', 'Clothing', 'Other'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: categories.map((category) => 
        DropdownMenuItem(value: category, child: Text(category))
      ).toList(),
      onChanged: onChanged,
    );
  }
}