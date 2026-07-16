import 'package:flutter/foundation.dart';

import '../models/notification.dart';
import '../repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<AppNotification> notifications = [];
  int unreadCount = 0;
  bool isLoading = false;

  Future<void> load(int employeeId) async {
    isLoading = true;
    notifyListeners();
    notifications = await _repository.getForEmployee(employeeId);
    unreadCount = await _repository.getUnreadCount(employeeId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    await _repository.markAsRead(notificationId);
    final idx = notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
      unreadCount = (unreadCount - 1).clamp(0, notifications.length);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(int employeeId) async {
    await _repository.markAllAsRead(employeeId);
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    unreadCount = 0;
    notifyListeners();
  }
}
