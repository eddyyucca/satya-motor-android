class Service {
  final int? id;
  final String name;
  final double price;
  final String? description;
  final double mechanicPercentage;
  final double ownerPercentage;
  final String? createdAt;

  Service({
    this.id,
    required this.name,
    required this.price,
    this.description,
    this.mechanicPercentage = 50.0,
    this.ownerPercentage = 50.0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description ?? '',
      'mechanic_percentage': mechanicPercentage,
      'owner_percentage': ownerPercentage,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String?,
      mechanicPercentage: (map['mechanic_percentage'] as num).toDouble(),
      ownerPercentage: (map['owner_percentage'] as num).toDouble(),
      createdAt: map['created_at'] as String?,
    );
  }

  Service copyWith({
    int? id,
    String? name,
    double? price,
    String? description,
    double? mechanicPercentage,
    double? ownerPercentage,
    String? createdAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      mechanicPercentage: mechanicPercentage ?? this.mechanicPercentage,
      ownerPercentage: ownerPercentage ?? this.ownerPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get mechanicShare => price * mechanicPercentage / 100;
  double get ownerShare => price * ownerPercentage / 100;
}
