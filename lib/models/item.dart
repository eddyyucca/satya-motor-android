class Item {
  final int? id;
  final String name;
  final String category;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final int minStock;
  final int maxStock;
  final String unit;
  final String? createdAt;

  Item({
    this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.minStock = 5,
    this.maxStock = 20,
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
      'min_stock': minStock,
      'max_stock': maxStock,
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
      minStock: (map['min_stock'] as int?) ?? 5,
      maxStock: (map['max_stock'] as int?) ?? 20,
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
    int? minStock,
    int? maxStock,
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
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get margin => sellPrice - buyPrice;
  double get marginPercent => buyPrice > 0 ? (margin / buyPrice) * 100 : 0;
}
