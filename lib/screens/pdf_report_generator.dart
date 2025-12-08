import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';

Future<void> generatePdfReport({
  required List<InventoryItem> inventoryItems,
  required List<Product> products,
}) async {
  final pdf = Document(
    title: 'Inventory Report',
    author: 'Inventory Management System',
  );

  // Add cover page
  pdf.addPage(
    Page(
      build: (Context context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'INVENTORY REPORT',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Generated on ${DateFormat.yMMMMd('en_US').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 16,
                  color: PdfColors.grey700,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: PdfColors.grey400,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Items: ${inventoryItems.length}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Total Products: ${products.length}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Total Inventory Value: Rp${inventoryItems.fold(0.0, (sum, item) => sum + item.totalCost).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Low Stock Items (< 10): ${inventoryItems.where((item) => item.quantity < 10).length}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Add inventory items page
  if (inventoryItems.isNotEmpty) {
    pdf.addPage(
      Page(
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INVENTORY ITEMS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Table.fromTextArray(
                  headers: [
                    'Name',
                    'Description',
                    'Quantity',
                    'Unit',
                    'Category',
                    'Cost/Unit',
                    'Total Cost',
                  ],
                  data: inventoryItems.map((item) {
                    return [
                      item.name,
                      item.description,
                      item.quantity.toStringAsFixed(2),
                      item.unit,
                      item.category,
                      'Rp${item.costPerUnit.toStringAsFixed(2)}',
                      'Rp${item.totalCost.toStringAsFixed(2)}',
                    ];
                  }).toList(),
                  border: TableBorder.all(),
                  headerStyle: TextStyle(fontWeight: FontWeight.bold),
                  cellHeight: 10,
                  cellAlignments: {
                    0: Alignment.centerLeft,
                    1: Alignment.centerLeft,
                    2: Alignment.centerRight,
                    3: Alignment.center,
                    4: Alignment.center,
                    5: Alignment.centerRight,
                    6: Alignment.centerRight,
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Add products page
  if (products.isNotEmpty) {
    pdf.addPage(
      Page(
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUCTS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Table.fromTextArray(
                  headers: [
                    'Name',
                    'Description',
                    'Selling Price',
                    'Category',
                    'Components Count',
                  ],
                  data: products.map((product) {
                    return [
                      product.name,
                      product.description,
                      'Rp${product.sellingPrice.toStringAsFixed(2)}',
                      product.category,
                      product.components.length.toString(),
                    ];
                  }).toList(),
                  border: TableBorder.all(),
                  headerStyle: TextStyle(fontWeight: FontWeight.bold),
                  cellHeight: 10,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Save the PDF
  savePdf(pdf);
}

Future<void> savePdf(Document pdf) async {
  // In a real app, you would save this to a file
  // For now, we're just printing the PDF content (in bytes)
  List<int> bytes = await pdf.save();
  print('PDF generated with ${bytes.length} bytes');
  // Here you would typically use the printing package to show preview or save
}