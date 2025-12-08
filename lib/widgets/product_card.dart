import 'package:flutter/material.dart';
import '../widgets/currency_widgets.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double sellingPrice;
  final double cogs;
  final double profit;
  final int componentsCount;
  final String category;
  final List<String> componentsList;
  final bool expanded;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExpansionChanged;

  const ProductCard({
    Key? key,
    required this.name,
    required this.sellingPrice,
    required this.cogs,
    required this.profit,
    required this.componentsCount,
    required this.category,
    required this.componentsList,
    this.expanded = false,
    required this.onEdit,
    required this.onDelete,
    required this.onExpansionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profitPercentage = cogs > 0 ? (profit / cogs) * 100 : 0;

    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: (_) => onExpansionChanged(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
            RupiahText(
              amount: sellingPrice,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        subtitle: Text(
          'COGS: ${cogs > 0 ? '${profitPercentage.toStringAsFixed(1)}%' : 'N/A'} profit | $componentsCount components',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Components ($componentsCount):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                ...componentsList.map((component) => Container(
                  margin: EdgeInsets.only(bottom: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    component,
                    style: TextStyle(fontSize: 12),
                  ),
                )).toList(),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: Icon(Icons.edit, size: 16),
                        label: Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete, size: 16),
                        label: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}