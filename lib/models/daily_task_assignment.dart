class DailyTaskAssignment {
  final int? id;
  final int dailyTaskTemplateId;
  final int? employeeId;
  final int? storeId;
  final int? shiftId;
  final String date;
  final String status;
  final String? completedAt;
  final String? createdAt;

  // Joined fields
  final String? taskTitle;
  final String? taskDescription;
  final String? storeName;

  DailyTaskAssignment({
    this.id,
    required this.dailyTaskTemplateId,
    this.employeeId,
    this.storeId,
    this.shiftId,
    required this.date,
    this.status = 'NEW',
    this.completedAt,
    this.createdAt,
    this.taskTitle,
    this.taskDescription,
    this.storeName,
  });

  factory DailyTaskAssignment.fromMap(Map<String, dynamic> map) {
    return DailyTaskAssignment(
      id: map['id'],
      dailyTaskTemplateId:
          map['daily_task_template_id'] ?? map['dailyTaskTemplateId'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      storeId: map['store_id'] ?? map['storeId'],
      shiftId: map['shift_id'] ?? map['shiftId'],
      date: map['date'],
      status: map['status'],
      completedAt: map['completed_at'] ?? map['completedAt'],
      createdAt: map['created_at'] ?? map['createdAt'],
      taskTitle: map['task_title'] ?? map['taskTitle'],
      taskDescription: map['task_description'] ?? map['taskDescription'],
      storeName: map['store_name'] ?? map['storeName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_task_template_id': dailyTaskTemplateId,
      'employee_id': employeeId,
      'store_id': storeId,
      'shift_id': shiftId,
      'date': date,
      'status': status,
      'completed_at': completedAt,
      'created_at': createdAt,
    };
  }

  DailyTaskAssignment copyWith({
    int? id,
    int? dailyTaskTemplateId,
    int? employeeId,
    int? storeId,
    int? shiftId,
    String? date,
    String? status,
    String? completedAt,
    String? createdAt,
    String? taskTitle,
    String? taskDescription,
    String? storeName,
  }) {
    return DailyTaskAssignment(
      id: id ?? this.id,
      dailyTaskTemplateId: dailyTaskTemplateId ?? this.dailyTaskTemplateId,
      employeeId: employeeId ?? this.employeeId,
      storeId: storeId ?? this.storeId,
      shiftId: shiftId ?? this.shiftId,
      date: date ?? this.date,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDescription: taskDescription ?? this.taskDescription,
      storeName: storeName ?? this.storeName,
    );
  }

  bool get isCompleted => status == 'COMPLETED';

  @override
  String toString() {
    return 'DailyTaskAssignment(id: $id, templateId: $dailyTaskTemplateId, status: $status)';
  }
}
