import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
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
                  title: localizations!.dashboard,
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.inventory,
                  title: localizations.inventory,
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.production_quantity_limits,
                  title: localizations.products,
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.point_of_sale,
                  title: localizations.pos,
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.qr_code_scanner,
                  title: localizations.scanItem,
                  index: 4,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.history,
                  title: localizations.transactionHistory,
                  index: 5,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.notifications,
                  title: localizations.notifications,
                  index: 6,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  isCollapsed: collapsed,
                ),
                _buildSideMenuTile(
                  context: context,
                  icon: Icons.settings,
                  title: localizations.settings,
                  index: 7,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ],
              )
            : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    size: 20,
                  ),
                ),
                if (!isCollapsed) ...[
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 14,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
