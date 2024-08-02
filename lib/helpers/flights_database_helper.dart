import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('flights.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE flights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      departureCity TEXT,
      destinationCity TEXT,
      departureTime TEXT,
      arrivalTime TEXT
    )
    ''');
    print("Database created successfully");
  }

  Future<int> create(Map<String, dynamic> data) async {
    final db = await instance.database;
    print("Creating flight: $data");
    return await db.insert('flights', data);
  }

  Future<List<Map<String, dynamic>>> readAll() async {
    final db = await instance.database;
    print("Reading all flights");
    return await db.query('flights');
  }

  Future<int> update(Map<String, dynamic> data) async {
    final db = await instance.database;

    final id = data['id'];
    print("Updating flight with id $id: $data");
    return await db.update(
      'flights',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    print("Deleting flight with id $id");
    return await db.delete(
      'flights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
