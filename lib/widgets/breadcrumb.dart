import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const Breadcrumb({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Container();

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.home,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8),
          ...List.generate(
            items.length,
            (index) {
              final item = items[index];
              bool isLast = index == items.length - 1;

              return Row(
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: isLast 
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class BreadcrumbItem {
  final String title;
  final VoidCallback? onTap;

  BreadcrumbItem({required this.title, this.onTap});
}