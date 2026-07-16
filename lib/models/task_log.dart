class TaskLog {
  final int? id;
  final int taskId;
  final int employeeId;
  final String action;
  final String? description;
  final String? createdAt;

  TaskLog({
    this.id,
    required this.taskId,
    required this.employeeId,
    required this.action,
    this.description,
    this.createdAt,
  });

  factory TaskLog.fromMap(Map<String, dynamic> map) {
    return TaskLog(
      id: map['id'],
      taskId: map['task_id'] ?? map['taskId'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      action: map['action'],
      description: map['description'],
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'employee_id': employeeId,
      'action': action,
      'description': description,
      'created_at': createdAt,
    };
  }
}
