import 'package:flutter/material.dart';

class StockRangePopup extends StatefulWidget {
  final Function(double, double) onApply;
  final double initialMin;
  final double initialMax;

  const StockRangePopup({
    required this.onApply,
    this.initialMin = 0,
    this.initialMax = 10000,
  });

  @override
  _StockRangePopupState createState() => _StockRangePopupState();
}

class _StockRangePopupState extends State<StockRangePopup> {
  late double _minStock;
  late double _maxStock;

  @override
  void initState() {
    super.initState();
    _minStock = widget.initialMin;
    _maxStock = widget.initialMax;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Stock Range', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _minStock = double.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _maxStock = double.tryParse(value) ?? 10000;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onApply(_minStock, _maxStock);
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}

class DateRangePopup extends StatefulWidget {
  final Function(DateTime, DateTime) onApply;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const DateRangePopup({
    required this.onApply,
    this.initialStart,
    this.initialEnd,
  });

  @override
  _DateRangePopupState createState() => _DateRangePopupState();
}

class _DateRangePopupState extends State<DateRangePopup> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
                icon: Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _startDate?.toLocal().toString().split(' ')[0] ??
                      'Start Date',
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
                icon: Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _endDate?.toLocal().toString().split(' ')[0] ?? 'End Date',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: _startDate != null && _endDate != null
              ? () {
                  Navigator.of(context).pop();
                  widget.onApply(_startDate!, _endDate!);
                }
              : null,
          child: Text('Apply'),
        ),
      ],
    );
  }
}
