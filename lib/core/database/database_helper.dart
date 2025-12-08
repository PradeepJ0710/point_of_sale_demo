import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Menu Table
    await db.execute('''
      CREATE TABLE menu (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // Category Table
    await db.execute('''
      CREATE TABLE category (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        menu_id INTEGER NOT NULL,
        FOREIGN KEY (menu_id) REFERENCES menu (id)
      )
    ''');

    // Item Table
    await db.execute('''
      CREATE TABLE item (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        cat_id INTEGER NOT NULL,
        menu_id INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (cat_id) REFERENCES category (id),
        FOREIGN KEY (menu_id) REFERENCES menu (id)
      )
    ''');

    // Order Headers Table (The "Master" record of an order)
    await db.execute('''
      CREATE TABLE order_headers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_date TEXT NOT NULL, 
        order_status TEXT NOT NULL,
        total_amount REAL NOT NULL
      )
    ''');

    // Order Items Table (The individual line items)
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        price REAL NOT NULL,
        qty INTEGER NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES order_headers (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES item (id)
      )
    ''');

    // Payments Table - Linked to Order Headers
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_date TEXT NOT NULL,
        order_id INTEGER NOT NULL,
        amount_due REAL NOT NULL,
        tips REAL NOT NULL,
        discount REAL NOT NULL,
        total_paid REAL NOT NULL,
        payment_type TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES order_headers (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
