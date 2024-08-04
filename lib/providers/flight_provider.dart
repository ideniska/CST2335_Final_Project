import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/flight.dart';


class FlightProvider with ChangeNotifier {
  List<Flight> _flights = [];

  List<Flight> get flights => _flights;

  Future<void> fetchFlights() async {
    final dataList =  await DatabaseHelper().getFlights();
    _flights = dataList;
    notifyListeners();
  }

  Future<List<Flight>> listFlights() async {
    return await DatabaseHelper().getFlights();
    notifyListeners();
  }

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

  Future<void> updateFlight(Flight flight) async {
    await DatabaseHelper().updateFlight(flight);
    final index = _flights.indexWhere((item) => item.id == flight.id);
    _flights[index] = flight;
    notifyListeners();
  }

  Future<void> deleteFlight(int id) async {
    await DatabaseHelper().deleteFlight(id);
    _flights.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<Flight?> getFlightById(int id) async {
    final flights = await DatabaseHelper().getFlights();
    try {
      return flights.firstWhere((flight) => flight.id == id);
    } catch (e) {
      return null; // Return null if not found
    }
  }

}
