import 'package:flutter/foundation.dart';
import 'package:bt/data/models/notification.dart';

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _unreadCount--;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
      }
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void deleteNotification(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadCount--;
      }
      _notifications.removeAt(index);
      notifyListeners();
    }
  }
}
