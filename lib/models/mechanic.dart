class Mechanic {
  final int? id;
  final String name;
  final String? phone;
  final bool isActive;
  final String? createdAt;

  Mechanic({
    this.id,
    required this.name,
    this.phone,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone ?? '',
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Mechanic.fromMap(Map<String, dynamic> map) {
    return Mechanic(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] as String?,
    );
  }

  Mechanic copyWith({
    int? id,
    String? name,
    String? phone,
    bool? isActive,
    String? createdAt,
  }) {
    return Mechanic(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
