import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/airplane.dart';
import '../models/customer.dart';
import '../models/reservation.dart';
import '../models/flight.dart';

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
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE airplanes(id INTEGER PRIMARY KEY, type TEXT, passengers INTEGER, maxSpeed REAL, range REAL)',
    );
    await db.execute(
      'CREATE TABLE customers(id INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT, address TEXT, birthday TEXT)',
    );
    await db.execute(
      'CREATE TABLE reservations(id INTEGER PRIMARY KEY AUTOINCREMENT, customerId INTEGER, flightId INTEGER, date TEXT, FOREIGN KEY (customerId) REFERENCES customers(id), FOREIGN KEY (flightId) REFERENCES airplanes(id))',
    );
    await db.execute(
      'CREATE TABLE flights(id INTEGER PRIMARY KEY AUTOINCREMENT, departureCity TEXT, destinationCity TEXT, departureTime TEXT, arrivalTime TEXT)',
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'CREATE TABLE flights(id INTEGER PRIMARY KEY AUTOINCREMENT, departureCity TEXT, destinationCity TEXT, departureTime TEXT, arrivalTime TEXT)',
      );
    }
  }

  // Airplane methods
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

  // Customer methods
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

  // Reservation methods
  Future<int> insertReservation(Reservation reservation) async {
    Database db = await database;
    return await db.insert('reservations', reservation.toMap());
  }

  Future<List<Reservation>> getReservations() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reservations');
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<int> updateReservation(Reservation reservation) async {
    Database db = await database;
    return await db.update('reservations', reservation.toMap(), where: 'id = ?', whereArgs: [reservation.id]);
  }

  Future<int> deleteReservation(int id) async {
    Database db = await database;
    return await db.delete('reservations', where: 'id = ?', whereArgs: [id]);
  }

  // Flight methods
  Future<int> insertFlight(Flight flight) async {
    Database db = await database;
    return await db.insert('flights', flight.toMap());
  }

  Future<List<Flight>> getFlights() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('flights');
    return List.generate(maps.length, (i) => Flight.fromMap(maps[i]));
  }

  Future<int> updateFlight(Flight flight) async {
    Database db = await database;
    return await db.update('flights', flight.toMap(), where: 'id = ?', whereArgs: [flight.id]);
  }

  Future<int> deleteFlight(int id) async {
    Database db = await database;
    return await db.delete('flights', where: 'id = ?', whereArgs: [id]);
  }
}
