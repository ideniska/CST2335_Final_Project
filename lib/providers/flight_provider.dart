import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/flight.dart';

class FlightProvider with ChangeNotifier {
  // List to store flights
  List<Flight> _flights = [];
  // Instance of DatabaseHelper to interact with the database
  final dbHelper = DatabaseHelper();

  List<Flight> get flights => _flights;

  Future<List<Flight>> getFlights() async {
    return await DatabaseHelper().getFlights();
    notifyListeners();
  }

  Future<void> addFlight(Flight flight) async {
    await dbHelper.insertFlight(flight);
    // Reload the list of flights to include the new addition
    await getFlights();
  }

  Future<void> updateFlight(Flight flight) async {
    await dbHelper.updateFlight(flight);
    // Reload the list of flights to reflect the update
    await getFlights();
  }

  Future<void> deleteFlight(int id) async {
    await dbHelper.deleteFlight(id);
    // Reload the list of flights to reflect the deletion
    await getFlights();
  }
}
