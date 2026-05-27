class Item {
  final int? id;
  final String name;
  final String category;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final String unit;
  final String? createdAt;

  Item({
    this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.unit = 'pcs',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'stock': stock,
      'unit': unit,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      buyPrice: (map['buy_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
      stock: map['stock'] as int,
      unit: map['unit'] as String? ?? 'pcs',
      createdAt: map['created_at'] as String?,
    );
  }

  Item copyWith({
    int? id,
    String? name,
    String? category,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    String? unit,
    String? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get margin => sellPrice - buyPrice;
  double get marginPercent => buyPrice > 0 ? (margin / buyPrice) * 100 : 0;
}
