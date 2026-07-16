class ShiftEmployee {
  final int? id;
  final int shiftId;
  final int employeeId;
  final String? roleOnShift;

  ShiftEmployee({
    this.id,
    required this.shiftId,
    required this.employeeId,
    this.roleOnShift,
  });

  factory ShiftEmployee.fromMap(Map<String, dynamic> map) {
    return ShiftEmployee(
      id: map['id'],
      shiftId: map['shift_id'] ?? map['shiftId'],
      employeeId: map['employee_id'] ?? map['employeeId'],
      roleOnShift: map['role_on_shift'] ?? map['roleOnShift'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shift_id': shiftId,
      'employee_id': employeeId,
      'role_on_shift': roleOnShift,
    };
  }
}
