import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/airplane.dart';
import '../models/customer.dart';

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
    await db.execute(
      'CREATE TABLE customers(id INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT, address TEXT, birthday TEXT)',
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

  Future<int> insertCustomer(Customer customer) async {
    Database db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<int> updateCustomer(Customer customer) async {
    Database db = await database;
    return await db.update('customers', customer.toMap(), where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<int> deleteCustomer(int id) async {
    Database db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}