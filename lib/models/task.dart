class Task {
  final int? id;
  final String title;
  final String? description;
  final String? category;
  final String? priority;
  final int createdBy;
  final int? shiftId;
  final int? storeId;
  final String status;
  final String? deadline;
  final bool isActive;
  final String? createdAt;
  final String? completedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    this.category,
    this.priority,
    required this.createdBy,
    this.shiftId,
    this.storeId,
    required this.status,
    this.deadline,
    this.isActive = true,
    this.createdAt,
    this.completedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      priority: map['priority'],
      createdBy: map['created_by'] ?? map['createdBy'],
      shiftId: map['shift_id'] ?? map['shiftId'],
      storeId: map['store_id'] ?? map['storeId'],
      status: map['status'],
      deadline: map['deadline'],
      isActive: (map['is_active'] ?? map['isActive'] ?? 1) == 1,
      createdAt: map['created_at'] ?? map['createdAt'],
      completedAt: map['completed_at'] ?? map['completedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'created_by': createdBy,
      'shift_id': shiftId,
      'store_id': storeId,
      'status': status,
      'deadline': deadline,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'completed_at': completedAt,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    int? createdBy,
    int? shiftId,
    int? storeId,
    String? status,
    String? deadline,
    bool? isActive,
    String? createdAt,
    String? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      shiftId: shiftId ?? this.shiftId,
      storeId: storeId ?? this.storeId,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
