import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/reservation.dart';

class ReservationProvider with ChangeNotifier {
  List<Reservation> reservations = [];
  final dbHelper = DatabaseHelper();

  Future<void> getReservations() async {
    reservations = await dbHelper.getReservations();
    notifyListeners();
  }

  Future<void> addReservation(Reservation reservation) async {
    await dbHelper.insertReservation(reservation);
    await getReservations();
  }

  Future<void> updateReservation(Reservation reservation) async {
    await dbHelper.updateReservation(reservation);
    await getReservations();
  }

  Future<void> deleteReservation(int id) async {
    await dbHelper.deleteReservation(id);
    await getReservations();
  }
}
