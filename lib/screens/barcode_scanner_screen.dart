import 'dart:io';
import 'package:flutter/material.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  @override
  Widget build(BuildContext context) {
    // Check if we're on a platform that supports camera
    bool supportsCamera = true; // Default to true

    // On desktop platforms, the QR scanner may not work
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      supportsCamera = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: supportsCamera ? _buildCameraScanner() : _buildManualEntry(),
    );
  }

  Widget _buildCameraScanner() {
    // Import QRView only when needed
    try {
      // Attempt to dynamically import QRView
      return _buildQrView();
    } catch (e) {
      // Fallback to manual entry if QR scanner isn't available
      return _buildManualEntry();
    }
  }

  Widget _buildQrView() {
    // This is just the skeleton since the import would need to be dynamic
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Camera Scanner',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Point your camera at a barcode to scan it',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Simulate scanning
              _showScanResult('SIMULATED-BARCODE-12345');
            },
            child: Text('Simulate Scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry() {
    String? barcodeInput;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Enter Barcode Manually',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                labelText: 'Barcode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              onChanged: (value) {
                barcodeInput = value;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (barcodeInput != null && barcodeInput!.isNotEmpty) {
                  _showScanResult(barcodeInput!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a barcode'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: Text('Process Barcode'),
            ),
            SizedBox(height: 16),
            Text(
              'Note: Camera scanner is not supported on this platform',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanResult(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Barcode Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barcode: $barcode'),
            SizedBox(height: 16),
            Text('What would you like to do?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Barcode $barcode processed for adding'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Add Item'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Barcode $barcode processed for updating'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text('Update Existing'),
          ),
        ],
      ),
    );
  }
}