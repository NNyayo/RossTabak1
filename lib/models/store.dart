class Store {
  final int? id;

  final String name;

  final String address;

  final String metro;

  final String markerColor;

  final bool isActive;

  final String? createdAt;

  Store({
    this.id,

    required this.name,

    required this.address,

    required this.metro,

    required this.markerColor,

    required this.isActive,

    this.createdAt,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],

      name: map['name'],

      address: map['address'],

      metro: map['metro'],

      markerColor: map['marker_color'] ?? map['markerColor'],

      isActive: (map['is_active'] ?? map['isActive']) == 1,

      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'name': name,

      'address': address,

      'metro': metro,

      'marker_color': markerColor,

      'is_active': isActive ? 1 : 0,

      'created_at': createdAt,
    };
  }

  Store copyWith({
    int? id,
    String? name,
    String? address,
    String? metro,
    String? markerColor,
    bool? isActive,
    String? createdAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      metro: metro ?? this.metro,
      markerColor: markerColor ?? this.markerColor,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Store && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
