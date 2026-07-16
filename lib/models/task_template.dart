class TaskTemplate {
  final int? id;
  final String title;
  final String? description;
  final String? category;
  final String shiftType;
  final String time;
  final bool isActive;

  TaskTemplate({
    this.id,
    required this.title,
    this.description,
    this.category,
    required this.shiftType,
    required this.time,
    this.isActive = true,
  });

  factory TaskTemplate.fromMap(Map<String, dynamic> map) {
    return TaskTemplate(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      shiftType: map['shift_type'] ?? map['shiftType'],
      time: map['time'],
      isActive: (map['is_active'] ?? map['isActive']) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'shift_type': shiftType,
      'time': time,
      'is_active': isActive ? 1 : 0,
    };
  }
}
