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
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final content = Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) {
                return const Center(
                  child: Text('No notifications yet.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return Card(
                    color: notification.isRead ? Theme.of(context).cardColor : primaryGradientTop.withAlpha(50),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(
                        notification.title,
                        style: TextStyle(fontWeight: !notification.isRead ? FontWeight.bold : FontWeight.normal),
                      ),
                      subtitle: Text(
                        notification.body,
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
                    ),
                  );
                },
              );
            },
          );

          if (isWide) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: content,
              ),
            );
          }
          return content;
        },
      ),
    );
  }
}
