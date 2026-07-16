class AppNotification {
  final int? id;
  final int? employeeId;
  final String type;
  final String title;
  final String? message;
  final bool isRead;
  final String? createdAt;

  AppNotification({
    this.id,
    this.employeeId,
    required this.type,
    required this.title,
    this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      type: map['type'],
      title: map['title'],
      message: map['message'],
      isRead: (map['is_read'] ?? map['isRead'] ?? 0) == 1,
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt,
    };
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      employeeId: employeeId,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
