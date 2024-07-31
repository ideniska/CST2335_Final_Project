import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/airplane.dart';

class AirplaneProvider with ChangeNotifier {
  List<Airplane> airplanes = [];
  final dbHelper = DatabaseHelper();

  Future<void> loadAirplanes() async {
    try {
      airplanes = await dbHelper.getAirplanes();
      notifyListeners();
    } catch (error) {
      print("Error loading airplanes: $error");
    }
  }

  Future<void> addAirplane(Airplane airplane) async {
    await dbHelper.insertAirplane(airplane);
    await loadAirplanes();
  }

  Future<void> updateAirplane(Airplane airplane) async {
    await dbHelper.updateAirplane(airplane);
    await loadAirplanes();
  }

  Future<void> deleteAirplane(int id) async {
    await dbHelper.deleteAirplane(id);
    await loadAirplanes();
  }
}
