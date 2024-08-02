import 'package:flutter/material.dart';
import '../models/flight.dart';
import '../helpers//flights_database_helper.dart';

class FlightProvider with ChangeNotifier {
  List<Flight> _flights = [];

  List<Flight> get flights => _flights;

  Future<void> fetchFlights() async {
    final dataList = await DatabaseHelper.instance.readAll();
    _flights = dataList.map((item) => Flight.fromMap(item)).toList();
    notifyListeners();
  }

  Future<void> addFlight(Flight flight) async {
    final id = await DatabaseHelper.instance.create(flight.toMap());
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
    await DatabaseHelper.instance.update(flight.toMap());
    final index = _flights.indexWhere((item) => item.id == flight.id);
    _flights[index] = flight;
    notifyListeners();
  }

  Future<void> deleteFlight(int id) async {
    await DatabaseHelper.instance.delete(id);
    _flights.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
