class DailyTaskTemplate {
  final int? id;
  final String title;
  final String? description;
  final bool isActive;
  final String? createdAt;

  DailyTaskTemplate({
    this.id,
    required this.title,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  factory DailyTaskTemplate.fromMap(Map<String, dynamic> map) {
    return DailyTaskTemplate(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isActive: (map['is_active'] ?? map['isActive'] ?? 1) == 1,
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  DailyTaskTemplate copyWith({
    int? id,
    String? title,
    String? description,
    bool? isActive,
    String? createdAt,
  }) {
    return DailyTaskTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DailyTaskTemplate(id: $id, title: $title)';
  }
}