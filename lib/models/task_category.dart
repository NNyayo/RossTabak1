class TaskCategory {
  final int? id;
  final String name;
  final String? description;
  final bool isActive;
  final String? createdAt;

  TaskCategory({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  factory TaskCategory.fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      isActive: (map['is_active'] ?? map['isActive']) == 1,
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  TaskCategory copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    String? createdAt,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TaskCategory(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCategory && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
