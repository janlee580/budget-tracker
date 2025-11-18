import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bt/providers/notification_provider.dart';
import 'package:bt/ui/themes/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
          )
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }
          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return ListTile(
                title: Text(
                  notification.title,
                  style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
                ),
                subtitle: Text(
                  notification.body,
                  style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: warningRed),
                  onPressed: () {
                    Provider.of<NotificationProvider>(context, listen: false).deleteNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${notification.title} dismissed')),
                    );
                  },
                ),
                onTap: () {
                  Provider.of<NotificationProvider>(context, listen: false).markAsRead(notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
