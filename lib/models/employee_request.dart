class EmployeeRequest {
  final int? id;
  final String title;
  final String? description;
  final int? storeId;
  final int employeeId;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  // Joined fields
  final String? employeeName;
  final String? storeName;

  EmployeeRequest({
    this.id,
    required this.title,
    this.description,
    this.storeId,
    required this.employeeId,
    this.status = 'NEW',
    this.createdAt,
    this.updatedAt,
    this.employeeName,
    this.storeName,
  });

  factory EmployeeRequest.fromMap(Map<String, dynamic> map) {
    return EmployeeRequest(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      storeId: map['store_id'] ?? map['storeId'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      status: map['status'],
      createdAt: map['created_at'] ?? map['createdAt'],
      updatedAt: map['updated_at'] ?? map['updatedAt'],
      employeeName: map['employee_name'] ?? map['employeeName'],
      storeName: map['store_name'] ?? map['storeName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'store_id': storeId,
      'employee_id': employeeId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  EmployeeRequest copyWith({
    int? id,
    String? title,
    String? description,
    int? storeId,
    int? employeeId,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? employeeName,
    String? storeName,
  }) {
    return EmployeeRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      storeId: storeId ?? this.storeId,
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      employeeName: employeeName ?? this.employeeName,
      storeName: storeName ?? this.storeName,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'NEW':
        return 'Новая';
      case 'IN_PROGRESS':
        return 'В работе';
      case 'COMPLETED':
        return 'Выполнена';
      default:
        return status;
    }
  }

  bool get isNew => status == 'NEW';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';

  @override
  String toString() {
    return 'EmployeeRequest(id: $id, title: $title, status: $status)';
  }
}