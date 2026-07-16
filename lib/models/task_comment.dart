class TaskComment {
  final int? id;
  final int taskId;
  final int employeeId;
  final String text;
  final String? createdAt;

  TaskComment({
    this.id,
    required this.taskId,
    required this.employeeId,
    required this.text,
    this.createdAt,
  });

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      id: map['id'],
      taskId: map['task_id'] ?? map['taskId'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      text: map['text'],
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'employee_id': employeeId,
      'text': text,
      'created_at': createdAt,
    };
  }
}
