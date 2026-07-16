class Shift {
  final int? id;
  final int storeId;
  final String date;
  final String shiftType;
  final String startTime;
  final String endTime;
  final String? createdAt;

  Shift({
    this.id,
    required this.storeId,
    required this.date,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    this.createdAt,
  });

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'],
      storeId: map['store_id'] ?? map['storeId'],
      date: map['date'],
      shiftType: map['shift_type'] ?? map['shiftType'],
      startTime: map['start_time'] ?? map['startTime'],
      endTime: map['end_time'] ?? map['endTime'],
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'date': date,
      'shift_type': shiftType,
      'start_time': startTime,
      'end_time': endTime,
      'created_at': createdAt,
    };
  }

  Shift copyWith({
    int? id,
    int? storeId,
    String? date,
    String? shiftType,
    String? startTime,
    String? endTime,
    String? createdAt,
  }) {
    return Shift(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      date: date ?? this.date,
      shiftType: shiftType ?? this.shiftType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Shift(id: $id, storeId: $storeId, date: $date, shiftType: $shiftType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shift && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
