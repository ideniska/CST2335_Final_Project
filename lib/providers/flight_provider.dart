import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/flight.dart';

/// A provider class for managing a list of flights.
///
/// This class uses the ChangeNotifier mixin to notify listeners
/// when the list of flights changes
class FlightProvider with ChangeNotifier {
  /// The list of flights.
  List<Flight> _flights = [];
  /// Returns the list of flights.
  List<Flight> get flights => _flights;

  /// Fetches the list of flights from the database.
  ///
  /// This method fetches the list of flights from the database
  /// and updates the [_flights] list. It also notifies listeners
  /// about the change.
  Future<void> fetchFlights() async {
    final dataList =  await DatabaseHelper().getFlights();
    _flights = dataList;
    notifyListeners();
  }

  /// Returns the list of flights from the database.
  ///
  /// This method fetches the list of flights from the database
  /// and returns it.
  Future<List<Flight>> listFlights() async {
    return await DatabaseHelper().getFlights();
  }

  /// Adds a new flight to the database and updates the list of flights.
  ///
  /// This method inserts a new flight into the database and then
  /// adds it to the [_flights] list. It also notifies listeners
  /// about the change.
  ///
  /// [flight] The flight to be added.
  Future<void> addFlight(Flight flight) async {
    final id = await DatabaseHelper().insertFlight(flight);
    final newFlight = Flight(
      id: id,
      departureCity: flight.departureCity,
      destinationCity: flight.destinationCity,
      departureTime: flight.departureTime,
      arrivalTime: flight.arrivalTime,
    );
    _flights.add(newFlight);
    notifyListeners();
  }

  /// Updates an existing flight in the database and updates the list of flights.
  ///
  /// This method updates an existing flight in the database and then
  /// updates it in the [_flights] list. It also notifies listeners
  /// about the change.
  ///
  /// [flight] The flight to be updated.
  Future<void> updateFlight(Flight flight) async {
    await DatabaseHelper().updateFlight(flight);
    final index = _flights.indexWhere((item) => item.id == flight.id);
    _flights[index] = flight;
    notifyListeners();
  }

  /// Deletes a flight from the database and updates the list of flights.
  ///
  /// This method deletes a flight from the database by its ID and then
  /// removes it from the [_flights] list. It also notifies listeners
  /// about the change.
  ///
  /// [id] The ID of the flight to be deleted.
  Future<void> deleteFlight(int id) async {
    await DatabaseHelper().deleteFlight(id);
    _flights.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// Returns a flight by its ID from the database.
  ///
  /// This method fetches the list of flights from the database and
  /// returns the flight with the specified ID. If no flight is found,
  /// it returns null.
  ///
  /// [id] The ID of the flight to be fetched.
  Future<Flight?> getFlightById(int id) async {
    final flights = await DatabaseHelper().getFlights();
    try {
      return flights.firstWhere((flight) => flight.id == id);
    } catch (e) {
      return null;
    }
  }

}
