import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/airplane.dart';

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
    String path = join(await getDatabasesPath(), 'airplanes.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE airplanes(id INTEGER PRIMARY KEY, type TEXT, passengers INTEGER, maxSpeed REAL, range REAL)',
    );
  }

  Future<int> insertAirplane(Airplane airplane) async {
    Database db = await database;
    return await db.insert('airplanes', airplane.toMap());
  }

  Future<List<Airplane>> getAirplanes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('airplanes');
    return List.generate(maps.length, (i) => Airplane.fromMap(maps[i]));
  }

  Future<int> updateAirplane(Airplane airplane) async {
    Database db = await database;
    return await db.update('airplanes', airplane.toMap(), where: 'id = ?', whereArgs: [airplane.id]);
  }

  Future<int> deleteAirplane(int id) async {
    Database db = await database;
    return await db.delete('airplanes', where: 'id = ?', whereArgs: [id]);
  }
}