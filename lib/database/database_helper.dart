import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

/// Singleton que gestiona la base de datos SQLite local.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = join(await getDatabasesPath(), 'gastos_app.db');
    return openDatabase(
      dbPath,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas al instalar la app por primera vez.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        type        TEXT NOT NULL,
        amount      REAL NOT NULL,
        category    TEXT NOT NULL,
        description TEXT NOT NULL,
        date        TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE categories (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT NOT NULL,
        type     TEXT NOT NULL,
        icon_key TEXT NOT NULL DEFAULT 'label'
      )
    ''');
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          name     TEXT NOT NULL,
          type     TEXT NOT NULL,
          icon_key TEXT NOT NULL DEFAULT 'label'
        )
      ''');
    }
    if (oldVersion < 3) {
      // Agrega columna icon_key si ya existía la tabla sin ella
      try {
        await db.execute(
            'ALTER TABLE categories ADD COLUMN icon_key TEXT NOT NULL DEFAULT \'label\'');
      } catch (_) {}
    }
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now();
    final samples = [
      _row('ingreso', 1200.0,  'Salario',         'Salario mensual',          now.subtract(const Duration(days: 10))),
      _row('gasto',   85.50,   'Alimentación',    'Compras del supermercado', now.subtract(const Duration(days: 8))),
      _row('gasto',   30.0,    'Transporte',      'Gasolina',                 now.subtract(const Duration(days: 6))),
      _row('ingreso', 250.0,   'Freelance',       'Proyecto diseño web',      now.subtract(const Duration(days: 5))),
      _row('gasto',   45.0,    'Servicios',       'Factura eléctrica',        now.subtract(const Duration(days: 4))),
      _row('gasto',   20.0,    'Entretenimiento', 'Cine con amigos',          now.subtract(const Duration(days: 2))),
      _row('gasto',   60.0,    'Salud',           'Consulta médica',          now.subtract(const Duration(days: 1))),
    ];
    for (final s in samples) {
      await db.insert('transactions', s);
    }
  }

  Map<String, dynamic> _row(
    String type, double amount, String cat, String desc, DateTime date,
  ) => {
    'type': type, 'amount': amount, 'category': cat,
    'description': desc, 'date': date.toIso8601String(),
  };

  // ── CRUD ────────────────────────────────────────────────────────────────

  Future<List<TransactionModel>> getAll({String? type}) async {
    final db = await database;
    final rows = type != null
        ? await db.query('transactions', where: 'type = ?', whereArgs: [type], orderBy: 'date DESC')
        : await db.query('transactions', orderBy: 'date DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<double> getTotal(String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0.0) AS total FROM transactions WHERE type = ?',
      [type],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<int> insert(TransactionModel t) async {
    final db = await database;
    return db.insert('transactions', t.toMap());
  }

  Future<int> update(TransactionModel t) async {
    final db = await database;
    return db.update('transactions', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ── Categorías personalizadas ────────────────────────────────────────────

  /// Devuelve lista de mapas con 'name' e 'iconKey' para cada categoría personalizada.
  Future<List<Map<String, String>>> getCustomCategories(String type) async {
    final db = await database;
    final rows = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return rows.map((r) => {
      'name':    r['name']     as String,
      'iconKey': (r['icon_key'] as String?) ?? 'label',
    }).toList();
  }

  Future<void> addCustomCategory(
      String name, String type, {String iconKey = 'label'}) async {
    final db = await database;
    await db.insert('categories', {
      'name': name, 'type': type, 'icon_key': iconKey,
    });
  }

  Future<void> deleteCustomCategory(String name, String type) async {
    final db = await database;
    await db.delete('categories',
        where: 'name = ? AND type = ?', whereArgs: [name, type]);
  }
}
