import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/airplane.dart';

/// A provider class for managing a list of airplanes.
///
/// This class uses the ChangeNotifier mixin to notify listeners
/// when the list of airplanes changes.
class AirplaneProvider with ChangeNotifier {
  /// The list of airplanes.
  List<Airplane> airplanes = [];
  final dbHelper = DatabaseHelper();

  /// Loads the list of airplanes from the database.
  ///
  /// This method fetches the list of airplanes from the database
  /// and updates the [airplanes] list. It also notifies listeners
  /// about the change.
  ///
  /// If an error occurs during the database operation, it prints
  /// an error message to the console.
  Future<void> loadAirplanes() async {
    try {
      airplanes = await dbHelper.getAirplanes();
      notifyListeners();
    } catch (error) {
      print("Error loading airplanes: $error");
    }
  }

  /// Adds a new airplane to the database and reloads the list of airplanes.
  ///
  /// This method inserts a new airplane into the database and then
  /// calls [loadAirplanes] to refresh the list of airplanes.
  ///
  /// [airplane] The airplane to be added.
  Future<void> addAirplane(Airplane airplane) async {
    await dbHelper.insertAirplane(airplane);
    await loadAirplanes();
  }

  /// Updates an existing airplane in the database and reloads the list of airplanes.
  ///
  /// This method updates an existing airplane in the database and then
  /// calls [loadAirplanes] to refresh the list of airplanes.
  ///
  /// [airplane] The airplane to be updated.
  Future<void> updateAirplane(Airplane airplane) async {
    await dbHelper.updateAirplane(airplane);
    await loadAirplanes();
  }

  /// Deletes an airplane from the database and reloads the list of airplanes.
  ///
  /// This method deletes an airplane from the database by its ID and then
  /// calls [loadAirplanes] to refresh the list of airplanes.
  ///
  /// [id] The ID of the airplane to be deleted.
  Future<void> deleteAirplane(int id) async {
    await dbHelper.deleteAirplane(id);
    await loadAirplanes();
  }
}
