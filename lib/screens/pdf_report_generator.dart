import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';
import '../services/logging_service.dart';

Future<void> generatePdfReport({
  required List<InventoryItem> inventoryItems,
  required List<Product> products,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Filter items based on date range if provided
  final filteredInventoryItems = startDate != null && endDate != null
      ? inventoryItems
            .where(
              (item) =>
                  item.dateAdded.isAfter(startDate) &&
                  item.dateAdded.isBefore(endDate),
            )
            .toList()
      : inventoryItems;

  final filteredProducts = startDate != null && endDate != null
      ? products
            .where(
              (product) =>
                  product.dateCreated.isAfter(startDate) &&
                  product.dateCreated.isBefore(endDate),
            )
            .toList()
      : products;

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
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Generated on ${DateFormat.yMMMMd('en_US').format(DateTime.now())}',
                style: TextStyle(fontSize: 16, color: PdfColors.grey700),
              ),
              if (startDate != null && endDate != null)
                Text(
                  'Date Range: ${DateFormat.yMd('en_US').format(startDate)} - ${DateFormat.yMd('en_US').format(endDate)}',
                  style: TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              SizedBox(height: 40),
              Text(
                'Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: PdfColors.grey400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Items: ${filteredInventoryItems.length}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Total Products: ${filteredProducts.length}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Total Inventory Value: Rp${filteredInventoryItems.fold(0.0, (sum, item) => sum + item.totalCost).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Low Stock Items (< 10): ${filteredInventoryItems.where((item) => item.quantity < 10).length}',
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
  if (filteredInventoryItems.isNotEmpty) {
    pdf.addPage(
      Page(
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INVENTORY ITEMS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  data: filteredInventoryItems.map((item) {
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
  if (filteredProducts.isNotEmpty) {
    pdf.addPage(
      Page(
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUCTS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  data: filteredProducts.map((product) {
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

  // Add charts page - create simple text-based charts
  if (filteredInventoryItems.isNotEmpty) {
    pdf.addPage(
      Page(
        build: (Context context) {
          // Group items by category to create category distribution chart
          final categoryMap = <String, List<InventoryItem>>{};
          for (final item in filteredInventoryItems) {
            if (categoryMap.containsKey(item.category)) {
              categoryMap[item.category]!.add(item);
            } else {
              categoryMap[item.category] = [item];
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CATEGORY DISTRIBUTION',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              for (final entry in categoryMap.entries)
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ${entry.value.length} items',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 10,
                        width:
                            (entry.value.length /
                                filteredInventoryItems.length) *
                            400,
                        color: PdfColors.blue,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Value: Rp${entry.value.fold(0.0, (sum, item) => sum + item.totalCost).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 30),
              Text(
                'VALUE BY CATEGORY',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              for (final entry in categoryMap.entries)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(entry.key)),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 12,
                          child: Stack(
                            children: [
                              Container(color: PdfColors.grey300),
                              Container(
                                width:
                                    (entry.value.fold(
                                          0.0,
                                          (sum, item) => sum + item.totalCost,
                                        ) /
                                        filteredInventoryItems.fold(
                                          0.0,
                                          (sum, item) => sum + item.totalCost,
                                        )) *
                                    200,
                                color: PdfColors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Rp${entry.value.fold(0.0, (sum, item) => sum + item.totalCost).toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
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
  // For now, we're just logging the PDF content (in bytes)
  List<int> bytes = await pdf.save();
  LoggingService.info('PDF generated with ${bytes.length} bytes');
  // Here you would typically use the printing package to show preview or save
}
