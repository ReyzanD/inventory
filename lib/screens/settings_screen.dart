import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // App settings
  double _defaultLowStockThreshold = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // App Settings Section
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            
            // Default Low Stock Threshold Setting
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Low Stock Threshold',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set the default threshold used for new inventory items',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _defaultLowStockThreshold,
                            min: 1.0,
                            max: 100.0,
                            divisions: 99,
                            label: _defaultLowStockThreshold.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                _defaultLowStockThreshold = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: 80,
                          child: TextFormField(
                            initialValue: _defaultLowStockThreshold.toString(),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Value',
                            ),
                            onChanged: (value) {
                              double? parsedValue = double.tryParse(value);
                              if (parsedValue != null && parsedValue >= 1.0 && parsedValue <= 100.0) {
                                setState(() {
                                  _defaultLowStockThreshold = parsedValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Current value: ${_defaultLowStockThreshold.toInt()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Save button
            ElevatedButton(
              onPressed: () {
                // Save settings logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Settings saved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}