import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/reservation.dart';

/// Manages a list of reservations and interacts with the database.
///
/// This class provides methods to fetch, add, update, and delete reservations.
class ReservationProvider with ChangeNotifier {
  /// List of current reservations.
  List<Reservation> reservations = [];

  /// Helper class for database operations.
  final dbHelper = DatabaseHelper();

  /// Retrieves the list of reservations from the database.
  ///
  /// Updates the internal [reservations] list and notifies listeners of changes.
  Future<void> getReservations() async {
    reservations = await dbHelper.getReservations();
    notifyListeners();
  }

  /// Adds a new reservation to the database.
  ///
  /// After adding, it retrieves the updated list of reservations and notifies listeners.
  Future<void> addReservation(Reservation reservation) async {
    await dbHelper.insertReservation(reservation);
    await getReservations();
  }

  /// Updates an existing reservation in the database.
  ///
  /// After updating, it retrieves the updated list of reservations and notifies listeners.
  Future<void> updateReservation(Reservation reservation) async {
    await dbHelper.updateReservation(reservation);
    await getReservations();
  }

  /// Deletes a reservation from the database.
  ///
  /// After deletion, it retrieves the updated list of reservations and notifies listeners.
  Future<void> deleteReservation(int id) async {
    await dbHelper.deleteReservation(id);
    await getReservations();
  }
}