import 'package:flutter/material.dart';
import 'filter_popups.dart';

class SearchAndFilterBar extends StatefulWidget {
  final String hintText;
  final List<String> categories;
  final Function(String) onSearchChanged;
  final Function(String) onCategoryChanged;
  final Function(double, double) onStockRangeChanged;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const SearchAndFilterBar({
    Key? key,
    required this.hintText,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onStockRangeChanged,
    required this.onDateRangeChanged,
  }) : super(key: key);

  @override
  _SearchAndFilterBarState createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  double _minStock = 0;
  double _maxStock = 10000;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                widget.onSearchChanged(_searchQuery);
              });
            },
          ),
          SizedBox(height: 16),
          // Filters row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Category filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      hintText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: ['All', ...widget.categories].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                          widget.onCategoryChanged(
                            _selectedCategory == 'All' ? '' : _selectedCategory,
                          );
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 12),
                // Stock filter button
                Expanded(
                  child: PopupMenuButton(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Stock: $_minStock - $_maxStock',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: StockRangePopup(
                          onApply: (min, max) {
                            setState(() {
                              _minStock = min;
                              _maxStock = max;
                            });
                            widget.onStockRangeChanged(min, max);
                          },
                          initialMin: _minStock,
                          initialMax: _maxStock,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                // Date filter button
                Expanded(
                  child: PopupMenuButton(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.date_range, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _startDate != null
                                  ? '${_startDate!.toString().split(' ')[0]} - ${_endDate != null ? _endDate!.toString().split(' ')[0] : 'Present'}'
                                  : 'Date Range',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: DateRangePopup(
                          onApply: (start, end) {
                            setState(() {
                              _startDate = start;
                              _endDate = end;
                            });
                            widget.onDateRangeChanged(start, end);
                          },
                          initialStart: _startDate,
                          initialEnd: _endDate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
