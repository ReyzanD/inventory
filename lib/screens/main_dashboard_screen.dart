import 'package:flutter/material.dart';
import 'responsive_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use the enhanced dashboard instead of the responsive one
    return ResponsiveDashboardScreen();
  }
}

// For now, keep both options - you can switch by uncommenting below
/*
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EnhancedDashboard();
  }
}
*/