import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/airplane.dart';

class AirplaneProvider with ChangeNotifier {
  // List to store airplanes
  List<Airplane> airplanes = [];
  // Instance of DatabaseHelper to interact with the database
  final dbHelper = DatabaseHelper();

  Future<void> loadAirplanes() async {
    airplanes = await dbHelper.getAirplanes();
    // Notify listeners to update the UI
    notifyListeners();
  }

  Future<void> addAirplane(Airplane airplane) async {
    await dbHelper.insertAirplane(airplane);
    // Reload the list of airplanes to include the new addition
    await loadAirplanes();
  }


  Future<void> updateAirplane(Airplane airplane) async {
    await dbHelper.updateAirplane(airplane);
    // Reload the list of airplanes to reflect the update
    await loadAirplanes();
  }

  Future<void> deleteAirplane(int id) async {
    await dbHelper.deleteAirplane(id);
    // Reload the list of airplanes to reflect the deletion
    await loadAirplanes();
  }
}