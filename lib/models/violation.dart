class Violation {
  final int? id;
  final int employeeId;
  final int taskId;
  final String type;
  final String? description;
  final String? createdAt;

  Violation({
    this.id,
    required this.employeeId,
    required this.taskId,
    required this.type,
    this.description,
    this.createdAt,
  });

  factory Violation.fromMap(Map<String, dynamic> map) {
    return Violation(
      id: map['id'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      taskId: map['task_id'] ?? map['taskId'],
      type: map['type'],
      description: map['description'],
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'task_id': taskId,
      'type': type,
      'description': description,
      'created_at': createdAt,
    };
  }
}
