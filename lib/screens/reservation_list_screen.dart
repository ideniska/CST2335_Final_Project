import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import '../models/reservation.dart';
import '../l10n/app_localizations.dart';
import '../screens/reservation_form_screen.dart';

class ReservationListScreen extends StatefulWidget {
  @override
  _ReservationListScreenState createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  Reservation? selectedReservation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
      reservationProvider.getReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final localizations = AppLocalizations.of(context);

    if (localizations == null) {
      return Scaffold(
        body: Center(child: Text('Localization not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('reservations') ?? 'Reservations'),
      ),
      body: reservationProvider.reservations == null
          ? Center(child: CircularProgressIndicator())
          : reservationProvider.reservations!.isEmpty
          ? Center(child: Text(localizations.translate('noReservations') ?? 'No Reservations'))
          : ListView.builder(
        itemCount: reservationProvider.reservations!.length,
        itemBuilder: (context, index) {
          final reservation = reservationProvider.reservations![index];
          return ListTile(
            title: Text('${reservation.customerId} - ${reservation.flightId}'),
            subtitle: Text('${reservation.date.toLocal()}'), // Convert DateTime to readable format
            onTap: () {
              setState(() {
                selectedReservation = reservation;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReservationFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
