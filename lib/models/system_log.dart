class SystemLog {
  final int? id;
  final int userId;
  final String action;
  final String? description;
  final String? createdAt;

  SystemLog({
    this.id,
    required this.userId,
    required this.action,
    this.description,
    this.createdAt,
  });

  factory SystemLog.fromMap(Map<String, dynamic> map) {
    return SystemLog(
      id: map['id'],
      userId: map['user_id'] ?? map['userId'],
      action: map['action'],
      description: map['description'],
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'description': description,
      'created_at': createdAt,
    };
  }
}
