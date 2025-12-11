import 'package:flutter/material.dart';

class SideMenuBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isCollapsed;

  const SideMenuBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final collapsed = isCollapsed || screenWidth < 720;

    return Container(
      width: collapsed ? 60 : 240,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (!collapsed)
                  Expanded(
                    child: Text(
                      'Inventory System',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  )
                else
                  Text(
                    'I',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.inventory,
                  title: 'Inventory',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.production_quantity_limits,
                  title: 'Products',
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.point_of_sale,
                  title: 'POS',
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.qr_code_scanner,
                  title: 'Scan Item',
                  index: 4,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.history,
                  title: 'Transaction History',
                  index: 5,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  index: 6,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
    required int currentIndex,
    required Function(int) onTap,
    required bool isCollapsed,
  }) {
    final bool isSelected = index == currentIndex;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
        title: isCollapsed
            ? null
            : Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
        onTap: () => onTap(index),
        selected: isSelected,
        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
        horizontalTitleGap: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
