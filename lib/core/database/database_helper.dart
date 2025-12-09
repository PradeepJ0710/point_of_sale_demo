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

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final Batch batch = db.batch();

    batch.rawInsert('INSERT INTO menu(id, name) VALUES(1, "Food")');
    batch.rawInsert('INSERT INTO menu(id, name) VALUES(2, "Drinks")');

    batch.rawInsert(
      'INSERT INTO category(id, name, menu_id) VALUES(1, "Starters", 1)',
    );
    batch.rawInsert(
      'INSERT INTO category(id, name, menu_id) VALUES(2, "Soft Drinks", 2)',
    );
    batch.rawInsert(
      'INSERT INTO category(id, name, menu_id) VALUES(3, "Mains", 1)',
    );
    batch.rawInsert(
      'INSERT INTO category(id, name, menu_id) VALUES(4, "Desserts", 2)',
    );
    batch.rawInsert(
      'INSERT INTO category(id, name, menu_id) VALUES(5, "Hot Drinks", 2)',
    );

    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(1, "Item1 (S)", 1, 1, 150)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(2, "Item1 (L)", 1, 1, 250)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(3, "Item2", 1, 1, 300)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(4, "Item3", 2, 2, 250)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(5, "Item4", 2, 2, 150)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(6, "Item5", 2, 1, 100)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(7, "Item6 (S)", 3, 1, 250)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(8, "Item6 (L)", 3, 1, 360)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(9, "Item7", 3, 1, 250)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(10, "Item8 (S)", 4, 2, 375)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(11, "Item8 (L)", 4, 2, 650)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(12, "Item9", 4, 2, 150)',
    );
    batch.rawInsert(
      'INSERT INTO item(id, name, cat_id, menu_id, price) VALUES(13, "Item10", 5, 2, 200)',
    );

    await batch.commit();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
