class TransactionItem {
  final int? id;
  final int? transactionId;
  final int itemId;
  final String itemName;
  final int quantity;
  final double sellPrice;
  final double buyPrice;
  final double mechanicPercentage;
  final double ownerPercentage;

  TransactionItem({
    this.id,
    this.transactionId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.sellPrice,
    required this.buyPrice,
    this.mechanicPercentage = 30.0,
    this.ownerPercentage = 70.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'sell_price': sellPrice,
      'buy_price': buyPrice,
      'mechanic_percentage': mechanicPercentage,
      'owner_percentage': ownerPercentage,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int?,
      itemId: map['item_id'] as int,
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as int,
      sellPrice: (map['sell_price'] as num).toDouble(),
      buyPrice: (map['buy_price'] as num).toDouble(),
      mechanicPercentage: (map['mechanic_percentage'] as num).toDouble(),
      ownerPercentage: (map['owner_percentage'] as num).toDouble(),
    );
  }

  double get subtotal => sellPrice * quantity;
  double get profit => (sellPrice - buyPrice) * quantity;
  double get mechanicShare => profit * mechanicPercentage / 100;
  double get ownerShare => profit * ownerPercentage / 100;
}

class TransactionService {
  final int? id;
  final int? transactionId;
  final int serviceId;
  final String serviceName;
  final double price;
  final double mechanicPercentage;
  final double ownerPercentage;

  TransactionService({
    this.id,
    this.transactionId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    this.mechanicPercentage = 50.0,
    this.ownerPercentage = 50.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'service_id': serviceId,
      'service_name': serviceName,
      'price': price,
      'mechanic_percentage': mechanicPercentage,
      'owner_percentage': ownerPercentage,
    };
  }

  factory TransactionService.fromMap(Map<String, dynamic> map) {
    return TransactionService(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int?,
      serviceId: map['service_id'] as int,
      serviceName: map['service_name'] as String,
      price: (map['price'] as num).toDouble(),
      mechanicPercentage: (map['mechanic_percentage'] as num).toDouble(),
      ownerPercentage: (map['owner_percentage'] as num).toDouble(),
    );
  }

  double get mechanicShare => price * mechanicPercentage / 100;
  double get ownerShare => price * ownerPercentage / 100;
}

class Transaction {
  final int? id;
  final String date;
  final String? customerName;
  final int? mechanicId;
  final String? mechanicName;
  final double totalAmount;
  final double totalMechanicShare;
  final double totalOwnerShare;
  final String? notes;
  final String? createdAt;
  final List<TransactionItem> items;
  final List<TransactionService> services;

  Transaction({
    this.id,
    required this.date,
    this.customerName,
    this.mechanicId,
    this.mechanicName,
    required this.totalAmount,
    required this.totalMechanicShare,
    required this.totalOwnerShare,
    this.notes,
    this.createdAt,
    this.items = const [],
    this.services = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'customer_name': customerName ?? '',
      'mechanic_id': mechanicId,
      'mechanic_name': mechanicName ?? '',
      'total_amount': totalAmount,
      'total_mechanic_share': totalMechanicShare,
      'total_owner_share': totalOwnerShare,
      'notes': notes ?? '',
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      date: map['date'] as String,
      customerName: map['customer_name'] as String?,
      mechanicId: map['mechanic_id'] as int?,
      mechanicName: map['mechanic_name'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      totalMechanicShare: (map['total_mechanic_share'] as num).toDouble(),
      totalOwnerShare: (map['total_owner_share'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
