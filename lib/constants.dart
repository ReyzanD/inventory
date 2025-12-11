import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // User constants
  static const String defaultUserId = 'current_user';

  // Validation limits
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const double maxQuantity = 999999.0;
  static const double maxPrice = 999999.0;

  // Default values
  static const double defaultLowStockThreshold = 5.0;
  static const int defaultLowStockItemsThreshold = 10;

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 1000;

  // Date formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Units
  static const List<String> commonUnits = [
    'pcs',
    'kg',
    'g',
    'mg',
    'L',
    'ml',
    'm',
    'cm',
    'm²',
    'm³',
  ];
}

class AppGradients {
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A9A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title});

  @override
  Widget build(BuildContext contex) {
    return AppBar(
      title: Text(title),
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppGradients.primaryGradient),
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class GradientCard extends StatelessWidget {
  final Widget child;

  const GradientCard({required this.child});

  @override
  Widget build(BuildContext contex) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
