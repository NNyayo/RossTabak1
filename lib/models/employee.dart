class Employee {
  final int? id;

  final String lastName;
  final String firstName;
  final String middleName;

  final String login;
  final String password;

  final List<int> storeIds;

  final String role;

  final bool isActive;

  final String? createdAt;
  final String? updatedAt;

  Employee({
    this.id,

    required this.lastName,

    required this.firstName,

    required this.middleName,

    required this.login,

    required this.password,

    required this.storeIds,

    this.role = 'EMPLOYEE',

    this.isActive = true,

    this.createdAt,

    this.updatedAt,
  });

  String get fullName {
    return '$lastName $firstName $middleName';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'last_name': lastName,

      'first_name': firstName,

      'middle_name': middleName,

      'login': login,

      'password': password,

      'role': role,

      'is_active': isActive ? 1 : 0,

      'created_at': createdAt,

      'updated_at': updatedAt,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    final dynamic rawStoreIds = map['storeIds'];

    final List<int> storeIds = rawStoreIds is List
        ? rawStoreIds.whereType<int>().toList()
        : rawStoreIds is String
        ? rawStoreIds.isNotEmpty
              ? rawStoreIds
                    .split(',')
                    .map((value) => int.tryParse(value.trim()))
                    .whereType<int>()
                    .toList()
              : []
        : [];

    return Employee(
      id: map['id'],

      lastName: map['last_name'] ?? map['lastName'],

      firstName: map['first_name'] ?? map['firstName'],

      middleName: map['middle_name'] ?? map['middleName'] ?? '',

      login: map['login'],

      password: map['password'],

      storeIds: storeIds,

      role: map['role'],

      isActive: (map['is_active'] ?? map['isActive']) == 1,

      createdAt: map['created_at'] ?? map['createdAt'],

      updatedAt: map['updated_at'] ?? map['updatedAt'],
    );
  }

  Employee copyWith({
    int? id,
    String? lastName,
    String? firstName,
    String? middleName,
    String? login,
    String? password,
    List<int>? storeIds,
    String? role,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      login: login ?? this.login,
      password: password ?? this.password,
      storeIds: storeIds ?? this.storeIds,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Employee(id: $id, fullName: $fullName, login: $login, role: $role, storeIds: $storeIds, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id && other.login == login;
  }

  @override
  int get hashCode => Object.hash(id, login);
}
