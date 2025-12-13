import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/notification_item.dart';
import '../providers/inventory_provider.dart';
import '../services/logging_service.dart';
import '../l10n/app_localizations.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.notifications),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;

          return notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationItem(
                      notification: notification,
                      onTap: () {
                        // Mark as read and navigate to relevant screen
                        LoggingService.info(
                          'Notification tapped: ${notification.title}',
                        );
                        // Could navigate to the inventory item screen here
                      },
                      onDismiss: () {
                        // For now, just remove from the list
                        // In a real implementation, this would mark as read in the database
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
