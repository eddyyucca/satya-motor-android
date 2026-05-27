import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';
import '../models/service.dart';
import '../models/transaction.dart';
import '../models/mechanic.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'satya_motor.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT '',
        buy_price REAL NOT NULL DEFAULT 0,
        sell_price REAL NOT NULL DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        unit TEXT NOT NULL DEFAULT 'pcs',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        description TEXT DEFAULT '',
        mechanic_percentage REAL NOT NULL DEFAULT 50,
        owner_percentage REAL NOT NULL DEFAULT 50,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mechanics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT DEFAULT '',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        customer_name TEXT DEFAULT '',
        mechanic_id INTEGER,
        mechanic_name TEXT DEFAULT '',
        total_amount REAL NOT NULL DEFAULT 0,
        total_mechanic_share REAL NOT NULL DEFAULT 0,
        total_owner_share REAL NOT NULL DEFAULT 0,
        notes TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (mechanic_id) REFERENCES mechanics(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        sell_price REAL NOT NULL DEFAULT 0,
        buy_price REAL NOT NULL DEFAULT 0,
        mechanic_percentage REAL NOT NULL DEFAULT 30,
        owner_percentage REAL NOT NULL DEFAULT 70,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        service_name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        mechanic_percentage REAL NOT NULL DEFAULT 50,
        owner_percentage REAL NOT NULL DEFAULT 50,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Sample mechanics
    await db.insert('mechanics', {
      'name': 'Budi Santoso',
      'phone': '081234567890',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('mechanics', {
      'name': 'Andi Prasetyo',
      'phone': '081298765432',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Sample items
    await db.insert('items', {
      'name': 'Oli Mesin 1L',
      'category': 'Oli',
      'buy_price': 35000,
      'sell_price': 55000,
      'stock': 25,
      'unit': 'botol',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('items', {
      'name': 'Kampas Rem Depan',
      'category': 'Sparepart',
      'buy_price': 25000,
      'sell_price': 45000,
      'stock': 15,
      'unit': 'set',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('items', {
      'name': 'Busi NGK',
      'category': 'Sparepart',
      'buy_price': 15000,
      'sell_price': 30000,
      'stock': 30,
      'unit': 'pcs',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('items', {
      'name': 'Ban Luar 70/90',
      'category': 'Ban',
      'buy_price': 120000,
      'sell_price': 175000,
      'stock': 8,
      'unit': 'pcs',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('items', {
      'name': 'Ban Dalam 17',
      'category': 'Ban',
      'buy_price': 20000,
      'sell_price': 35000,
      'stock': 12,
      'unit': 'pcs',
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('items', {
      'name': 'Filter Udara',
      'category': 'Sparepart',
      'buy_price': 18000,
      'sell_price': 35000,
      'stock': 3,
      'unit': 'pcs',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Sample services
    await db.insert('services', {
      'name': 'Ganti Oli',
      'price': 25000,
      'description': 'Jasa ganti oli mesin',
      'mechanic_percentage': 50,
      'owner_percentage': 50,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('services', {
      'name': 'Servis Ringan',
      'price': 50000,
      'description': 'Servis ringan motor standar',
      'mechanic_percentage': 50,
      'owner_percentage': 50,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('services', {
      'name': 'Servis Besar',
      'price': 150000,
      'description': 'Servis besar termasuk tune-up',
      'mechanic_percentage': 50,
      'owner_percentage': 50,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('services', {
      'name': 'Ganti Ban',
      'price': 20000,
      'description': 'Jasa pasang ban',
      'mechanic_percentage': 50,
      'owner_percentage': 50,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('services', {
      'name': 'Tambal Ban',
      'price': 15000,
      'description': 'Tambal ban tubeless/biasa',
      'mechanic_percentage': 50,
      'owner_percentage': 50,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Sample transactions
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // 2-3 transactions per day
      final txCount = (i % 2 == 0) ? 3 : 2;
      for (int j = 0; j < txCount; j++) {
        final amount = 100000.0 + (i * 30000) + (j * 50000);
        final mechanicShare = amount * 0.35;
        final ownerShare = amount - mechanicShare;
        await db.insert('transactions', {
          'date': dateStr,
          'customer_name': 'Pelanggan ${i * 3 + j + 1}',
          'mechanic_id': (j % 2) + 1,
          'mechanic_name': j % 2 == 0 ? 'Budi Santoso' : 'Andi Prasetyo',
          'total_amount': amount,
          'total_mechanic_share': mechanicShare,
          'total_owner_share': ownerShare,
          'notes': '',
          'created_at': date.toIso8601String(),
        });
      }
    }
  }

  // ========================
  // ITEMS (STOK BARANG)
  // ========================

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getItems({String? search, String? category}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      whereClause = 'name LIKE ?';
      whereArgs.add('%$search%');
    }
    if (category != null && category.isNotEmpty && category != 'Semua') {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    return (await db.query(
      'items',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    ))
        .map((e) => Item.fromMap(e))
        .toList();
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update('items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStock(int itemId, int quantitySold) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE items SET stock = stock - ? WHERE id = ?',
      [quantitySold, itemId],
    );
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT category FROM items WHERE category != "" ORDER BY category');
    return result.map((e) => e['category'] as String).toList();
  }

  Future<int> getLowStockCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(*) as count FROM items WHERE stock < 5');
    return result.first['count'] as int;
  }

  Future<int> getTotalItemCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM items');
    return result.first['count'] as int;
  }

  // ========================
  // SERVICES (JASA)
  // ========================

  Future<int> insertService(Service service) async {
    final db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<List<Service>> getServices() async {
    final db = await database;
    return (await db.query('services', orderBy: 'name ASC'))
        .map((e) => Service.fromMap(e))
        .toList();
  }

  Future<int> updateService(Service service) async {
    final db = await database;
    return await db.update('services', service.toMap(),
        where: 'id = ?', whereArgs: [service.id]);
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  // ========================
  // MECHANICS (MEKANIK)
  // ========================

  Future<int> insertMechanic(Mechanic mechanic) async {
    final db = await database;
    return await db.insert('mechanics', mechanic.toMap());
  }

  Future<List<Mechanic>> getMechanics({bool activeOnly = false}) async {
    final db = await database;
    return (await db.query(
      'mechanics',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'name ASC',
    ))
        .map((e) => Mechanic.fromMap(e))
        .toList();
  }

  Future<int> updateMechanic(Mechanic mechanic) async {
    final db = await database;
    return await db.update('mechanics', mechanic.toMap(),
        where: 'id = ?', whereArgs: [mechanic.id]);
  }

  Future<int> deleteMechanic(int id) async {
    final db = await database;
    return await db.delete('mechanics', where: 'id = ?', whereArgs: [id]);
  }

  // ========================
  // TRANSACTIONS (TRANSAKSI)
  // ========================

  Future<int> insertTransaction(
    Transaction transaction,
    List<TransactionItem> items,
    List<TransactionService> services,
  ) async {
    final db = await database;
    int txId = 0;
    await db.transaction((txn) async {
      txId = await txn.insert('transactions', transaction.toMap());

      for (var item in items) {
        final map = item.toMap();
        map['transaction_id'] = txId;
        await txn.insert('transaction_items', map);

        // Kurangi stok
        await txn.rawUpdate(
          'UPDATE items SET stock = stock - ? WHERE id = ?',
          [item.quantity, item.itemId],
        );
      }

      for (var service in services) {
        final map = service.toMap();
        map['transaction_id'] = txId;
        await txn.insert('transaction_services', map);
      }
    });
    return txId;
  }

  Future<List<Transaction>> getTransactions({
    String? startDate,
    String? endDate,
    int? mechanicId,
    int limit = 50,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause = 'date >= ?';
      whereArgs.add(startDate);
    }
    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date <= ?';
      whereArgs.add(endDate);
    }
    if (mechanicId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'mechanic_id = ?';
      whereArgs.add(mechanicId);
    }

    return (await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
      limit: limit,
    ))
        .map((e) => Transaction.fromMap(e))
        .toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ========================
  // DASHBOARD QUERIES
  // ========================

  Future<double> getTodayIncome() async {
    final db = await database;
    final today =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total_amount), 0) as total FROM transactions WHERE date = ?',
      [today],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<int> getTodayTransactionCount() async {
    final db = await database;
    final today =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE date = ?',
      [today],
    );
    return result.first['count'] as int;
  }

  Future<double> getMonthIncome() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total_amount), 0) as total FROM transactions WHERE date >= ?',
      [startOfMonth],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getLast7DaysIncome() async {
    final db = await database;
    final now = DateTime.now();
    List<Map<String, dynamic>> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final query = await db.rawQuery(
        'SELECT COALESCE(SUM(total_amount), 0) as total FROM transactions WHERE date = ?',
        [dateStr],
      );
      result.add({
        'date': dateStr,
        'day': _getDayName(date.weekday),
        'total': (query.first['total'] as num).toDouble(),
      });
    }
    return result;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Min';
      default:
        return '';
    }
  }

  Future<double> getMechanicTotalIncome(int mechanicId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total_mechanic_share), 0) as total FROM transactions WHERE mechanic_id = ?',
      [mechanicId],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getIncomeByPeriod(
      String startDate, String endDate) async {
    final db = await database;
    final totalResult = await db.rawQuery(
      'SELECT COALESCE(SUM(total_amount), 0) as total, COALESCE(SUM(total_mechanic_share), 0) as mechanic, COALESCE(SUM(total_owner_share), 0) as owner FROM transactions WHERE date >= ? AND date <= ?',
      [startDate, endDate],
    );
    return {
      'total': (totalResult.first['total'] as num).toDouble(),
      'mechanic': (totalResult.first['mechanic'] as num).toDouble(),
      'owner': (totalResult.first['owner'] as num).toDouble(),
    };
  }
}
