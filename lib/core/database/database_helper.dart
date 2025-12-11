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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure, // Optimization: Configure DB before creation
    );
  }

  Future<void> _onConfigure(Database db) async {
    // 1. Enforce Foreign Keys
    await db.execute('PRAGMA foreign_keys = ON');
    // 2. Enable WAL Mode (This returns a row, so execute() fails on some platforms. Use rawQuery)
    await db.rawQuery('PRAGMA journal_mode = WAL');
    await db.rawQuery('PRAGMA synchronous = NORMAL');
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

    // Item Table - Price in Cents
    await db.execute('''
      CREATE TABLE item (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        cat_id INTEGER NOT NULL,
        menu_id INTEGER NOT NULL,
        price INTEGER NOT NULL CHECK (price >= 0),
        FOREIGN KEY (cat_id) REFERENCES category (id),
        FOREIGN KEY (menu_id) REFERENCES menu (id)
      )
    ''');

    // Order Headers Table - Total in Cents
    await db.execute('''
      CREATE TABLE order_headers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_date TEXT NOT NULL, 
        order_status TEXT NOT NULL,
        total_amount INTEGER NOT NULL CHECK (total_amount >= 0)
      )
    ''');

    // Order Items Table - Price and Total in Cents
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        price INTEGER NOT NULL CHECK (price >= 0),
        qty INTEGER NOT NULL CHECK (qty > 0), 
        total INTEGER NOT NULL CHECK (total >= 0),
        FOREIGN KEY (order_id) REFERENCES order_headers (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES item (id)
      )
    ''');

    // Payments Table - Money fields in Cents
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_date TEXT NOT NULL,
        order_id INTEGER NOT NULL,
        amount_due INTEGER NOT NULL CHECK (amount_due >= 0),
        tips INTEGER NOT NULL CHECK (tips >= 0),
        discount INTEGER NOT NULL CHECK (discount >= 0),
        total_paid INTEGER NOT NULL CHECK (total_paid >= 0),
        payment_type TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES order_headers (id) ON DELETE CASCADE
      )
    ''');

    // 3. Indexes for High-Performance Read/Lookup
    await db.execute('CREATE INDEX idx_category_menu_id ON category(menu_id)');
    await db.execute('CREATE INDEX idx_item_cat_id ON item(cat_id)');
    await db.execute('CREATE INDEX idx_item_menu_id ON item(menu_id)');
    await db.execute(
      'CREATE INDEX idx_order_items_order_id ON order_items(order_id)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_order_id ON payments(order_id)',
    );

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final Batch batch = db.batch();

    batch.execute('''
      INSERT INTO menu (id, name) VALUES
        (1, 'Food'),
        (2, 'Drinks');
    ''');

    batch.execute('''
      INSERT INTO category(id, name, menu_id) VALUES
        (1, "Starters", 1),
        (2, "Soft Drinks", 2),
        (3, "Mains", 1),
        (4, "Desserts", 2),
        (5, "Hot Drinks", 2);
      ''');

    batch.execute('''
      INSERT INTO item(id, name, cat_id, menu_id, price) VALUES
        (1, "Item 1 (S)", 1, 1, 150),
        (2, "Item 1 (L)", 1, 1, 250),
        (3, "Item 2", 1, 1, 300),
        (4, "Item 3", 2, 2, 250),
        (5, "Item 4", 2, 2, 150),
        (6, "Item 5", 2, 1, 100),
        (7, "Item 6 (S)", 3, 1, 250),
        (8, "Item 6 (L)", 3, 1, 360),
        (9, "Item 7", 3, 1, 250),
        (10, "Item 8 (S)", 4, 2, 375),
        (11, "Item 8 (L)", 4, 2, 650),
        (12, "Item 9", 4, 2, 150),
        (13, "Item 10", 5, 2, 200);
      ''');

    await batch.commit();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
