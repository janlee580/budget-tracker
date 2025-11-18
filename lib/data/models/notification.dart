class AppNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
    this.isRead = false,
  });
}
