import 'package:flutter/material.dart';

class SearchAndFilterBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSearchChanged;
  final List<String>? categories;
  final String? selectedCategory;
  final Function(String?)? onCategoryChanged;
  final String? selectedSort;
  final List<String>? sortOptions;
  final ValueChanged<String?>? onSortChanged;
  final Function(double, double)? onStockRangeChanged;
  final Function(DateTime?, DateTime?)? onDateRangeChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String hintText;

  const SearchAndFilterBar({
    Key? key,
    this.controller,
    this.onSearchChanged,
    this.categories,
    this.selectedCategory,
    this.onCategoryChanged,
    this.selectedSort,
    this.sortOptions,
    this.onSortChanged,
    this.onStockRangeChanged,
    this.onDateRangeChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText = 'Search...',
  }) : super(key: key);

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  final TextEditingController _textEditingController = TextEditingController();
  late final TextEditingController _effectiveController;
  String _searchQuery = '';

  // Stock range values
  double _minStock = 0.0;
  double _maxStock = 10000.0;

  // Date range values
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? _textEditingController;

    // Listen for changes in the search text
    _effectiveController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textEditingController.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    _searchQuery = _effectiveController.text;
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(_searchQuery);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });

      if (widget.onDateRangeChanged != null) {
        widget.onDateRangeChanged!(_startDate, _endDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _effectiveController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
              suffixIcon:
                  widget.suffixIcon ??
                  (_effectiveController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _effectiveController.clear();
                            widget.onSearchChanged?.call('');
                          },
                        )
                      : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildCategoryDropdown()),
              const SizedBox(width: 8),
              _buildSortDropdown(),
            ],
          ),
          const SizedBox(height: 8),
          // Stock range filter - wrapped in Flexible to handle layout issues in scrollable contexts
          if (widget.onStockRangeChanged != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use ConstrainedBox to ensure proper sizing in scrollable contexts
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 150, // Limit height to prevent overflow
                      minHeight: 100, // Ensure minimum height for usability
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Important: prevent taking infinite space
                      children: [
                        Text(
                          'Stock: ${_minStock.toInt()} - ${_maxStock.toInt()}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min, // Prevent taking infinite space
                          children: [
                            Flexible(  // Use Flexible instead of Expanded to be more lenient with constraints
                              child: Slider(
                                value: _minStock,
                                min: 0,
                                max: 5000,
                                onChanged: (value) {
                                  setState(() {
                                    _minStock = value;
                                  });
                                  if (widget.onStockRangeChanged != null) {
                                    widget.onStockRangeChanged!(_minStock, _maxStock);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(  // Use Flexible instead of Expanded
                              child: Slider(
                                value: _maxStock,
                                min: 0,
                                max: 10000,
                                onChanged: (value) {
                                  setState(() {
                                    _maxStock = value;
                                  });
                                  if (widget.onStockRangeChanged != null) {
                                    widget.onStockRangeChanged!(_minStock, _maxStock);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: _selectDateRange,
                            child: const Text('Select Date Range'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (widget.categories == null || widget.categories!.isEmpty) {
      return Container(); // Return empty container if no categories
    }

    return DropdownButtonFormField<String>(
      value: widget.selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Categories')),
        for (String category in widget.categories!)
          DropdownMenuItem(value: category, child: Text(category)),
      ],
      onChanged: widget.onCategoryChanged,
    );
  }

  Widget _buildSortDropdown() {
    if (widget.sortOptions == null || widget.sortOptions!.isEmpty) {
      return const Icon(Icons.sort);
    }

    return DropdownButtonFormField<String>(
      initialValue: widget.selectedSort,
      decoration: const InputDecoration(
        labelText: 'Sort By',
        border: OutlineInputBorder(),
      ),
      items: [
        for (String sortOption in widget.sortOptions!)
          DropdownMenuItem(value: sortOption, child: Text(sortOption)),
      ],
      onChanged: widget.onSortChanged,
    );
  }
}
