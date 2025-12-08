import 'package:flutter/material.dart';

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
  Size get PreferredSize => Size.fromHeight(kToolbarHeight);

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
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
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
