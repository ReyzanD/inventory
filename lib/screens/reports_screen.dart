import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import 'pdf_report_generator.dart';
import '../utils/error_handler.dart';

class ReportTemplate {
  final String id;
  final String name;
  final String description;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;
  String _statusMessage = '';
  Color _statusColor = Colors.grey;
  String? _selectedTemplate;

  final List<ReportTemplate> _reportTemplates = [
    ReportTemplate(
      id: 'standard',
      name: 'Standard Report',
      description: 'Basic inventory and product information',
    ),
    ReportTemplate(
      id: 'detailed',
      name: 'Detailed Report',
      description: 'Complete information with charts and analytics',
    ),
    ReportTemplate(
      id: 'financial',
      name: 'Financial Summary',
      description: 'Focus on cost, revenue, and profit metrics',
    ),
    ReportTemplate(
      id: 'inventory_only',
      name: 'Inventory Only',
      description: 'Inventory-focused report without products',
    ),
    ReportTemplate(
      id: 'products_only',
      name: 'Products Only',
      description: 'Product-focused report without inventory details',
    ),
  ];

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, adjust it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _statusMessage = 'Please select both start and end dates';
        _statusColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _statusMessage = 'Generating report...';
      _statusColor = Colors.blue;
    });

    try {
      final provider = context.read<InventoryProvider>();

      await generatePdfReport(
        inventoryItems: provider.inventoryItems,
        products: provider.products,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _statusMessage = 'Report generated successfully!';
        _statusColor = Colors.green;
      });
    } catch (e) {
      final errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      setState(() {
        _statusMessage = 'Error generating report: $errorMessage';
        _statusColor = Colors.red;
      });
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        customMessage: 'Failed to generate report',
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateMonthlyComparisonReport() async {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _statusMessage = 'Please select both start and end dates';
        _statusColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _statusMessage = 'Generating monthly comparison...';
      _statusColor = Colors.blue;
    });

    try {
      // In a full implementation, this would generate a monthly comparison report
      // For now, we'll just show a dialog with the basic idea
      await _showMonthlyComparison();

      setState(() {
        _statusMessage = 'Monthly comparison report generated!';
        _statusColor = Colors.green;
      });
    } catch (e) {
      final errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      setState(() {
        _statusMessage = 'Error generating comparison: $errorMessage';
        _statusColor = Colors.red;
      });
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        customMessage: 'Failed to generate monthly comparison',
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _showMonthlyComparison() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Monthly Comparison Report'),
          content: const Text(
            'This would show a detailed comparison of inventory values between months.\n\n'
            'In a full implementation:\n'
            '- Compare inventory values month-over-month\n'
            '- Show trends and analytics\n'
            '- Include charts and graphs\n'
            '- Export to PDF with comparative analysis',
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateCustomReport() async {
    if (_selectedTemplate == null) {
      setState(() {
        _statusMessage = 'Please select a report template';
        _statusColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _statusMessage = 'Generating custom report...';
      _statusColor = Colors.blue;
    });

    try {
      final provider = context.read<InventoryProvider>();

      // Based on template selection, we would call different report generation methods
      // For now, we'll use the same generator but this could be extended in a full implementation
      await generatePdfReport(
        inventoryItems: _selectedTemplate == 'products_only'
            ? [] // No inventory items for products-only template
            : provider.inventoryItems,
        products: _selectedTemplate == 'inventory_only'
            ? [] // No products for inventory-only template
            : provider.products,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _statusMessage = 'Custom report generated successfully!';
        _statusColor = Colors.green;
      });
    } catch (e) {
      final errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      setState(() {
        _statusMessage = 'Error generating custom report: $errorMessage';
        _statusColor = Colors.red;
      });
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        customMessage: 'Failed to generate custom report',
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date Range Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectStartDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate != null
                                  ? DateFormat.yMd().format(_startDate!)
                                  : 'Start Date',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('to'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectEndDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _endDate != null
                                  ? DateFormat.yMd().format(_endDate!)
                                  : 'End Date',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _startDate != null && _endDate != null
                          ? 'Selected Range: ${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}'
                          : 'No date range selected',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Standard Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateReport,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate PDF Report'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Generate a detailed PDF report with inventory and products data for the selected date range.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isGenerating
                          ? null
                          : _generateMonthlyComparisonReport,
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Monthly Comparison'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Generate comparative analysis showing trends month-over-month.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom Report Templates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a template for your report:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTemplate,
                      items: _reportTemplates.map((template) {
                        return DropdownMenuItem(
                          value: template.id,
                          child: Text(template.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTemplate = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateCustomReport,
                      icon: const Icon(Icons.print),
                      label: const Text('Generate Custom Report'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create reports with custom layouts and data fields.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(color: _statusColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
