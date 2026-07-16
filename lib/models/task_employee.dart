class TaskEmployee {
  final int? id;
  final int taskId;
  final int employeeId;
  final String status;

  TaskEmployee({
    this.id,
    required this.taskId,
    required this.employeeId,
    required this.status,
  });

  factory TaskEmployee.fromMap(Map<String, dynamic> map) {
    return TaskEmployee(
      id: map['id'],
      taskId: map['task_id'] ?? map['taskId'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'employee_id': employeeId,
      'status': status,
    };
  }
}
