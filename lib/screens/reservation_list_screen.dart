import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/flight.dart';
import '../providers/reservation_provider.dart';
import '../models/reservation.dart';
import '../l10n/app_localizations.dart';
import 'reservation_form_screen.dart';
import '../providers/customer_provider.dart';
import '../providers/flight_provider.dart';

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
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              _showInstructionsDialog(context, localizations);
            },
          ),
        ],
      ),
      body: reservationProvider.reservations == null
          ? Center(child: CircularProgressIndicator())
          : reservationProvider.reservations!.isEmpty
          ? Center(child: Text(localizations.translate('noReservations') ?? 'No Reservations'))
          : LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return buildTabletLayout(reservationProvider, localizations);
          } else {
            return buildMobileLayout(reservationProvider, localizations);
          }
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

  void _showInstructionsDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('instructions') ?? 'Instructions'),
          content: Text(localizations.translate('reservationListInstructions') ?? 'Press an item to edit or delete, Press + to add a new reservation.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(localizations.translate('ok') ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTabletLayout(ReservationProvider reservationProvider, AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: reservationProvider.reservations!.length,
            itemBuilder: (context, index) {
              final reservation = reservationProvider.reservations![index];
              return ListTile(
                title: Text('${reservation.name}'), // Display the name of the reservation
                subtitle: Text('${reservation.date.toLocal()}'),
                onTap: () {
                  setState(() {
                    selectedReservation = reservation;
                  });
                },
              );
            },
          ),
        ),
        if (selectedReservation != null)
          Expanded(
            child: ReservationDetail(reservation: selectedReservation!),
          ),
      ],
    );
  }

  Widget buildMobileLayout(ReservationProvider reservationProvider, AppLocalizations localizations) {
    return ListView.builder(
      itemCount: reservationProvider.reservations!.length,
      itemBuilder: (context, index) {
        final reservation = reservationProvider.reservations![index];
        return ListTile(
          title: Text('${reservation.name}'), // Display the name of the reservation
          subtitle: Text('${reservation.date.toLocal()}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationFormScreen(reservation: reservation),
              ),
            );
          },
        );
      },
    );
  }
}

class ReservationDetail extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetail({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reservation: ${reservation.name}',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 8.0),
            FutureBuilder<Flight?>(
              future: flightProvider.getFlightById(reservation.flightId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading flight...');
                } else if (snapshot.hasError) {
                  return Text('Error loading flight');
                } else if (!snapshot.hasData) {
                  return Text('Flight not found');
                } else {
                  final flight = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${localizations.translate('departureCity')}: ${flight.departureCity ?? 'Unknown'}'),
                      Text('${localizations.translate('destinationCity')}: ${flight.destinationCity ?? 'Unknown'}'),
                      Text('${localizations.translate('departureTime')}: ${flight.departureTime ?? 'Unknown'}'),
                      Text('${localizations.translate('arrivalTime')}: ${flight.arrivalTime ?? 'Unknown'}'),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationFormScreen(reservation: reservation),
                  ),
                );
              },
              child: Text(localizations.translate('edit')!),
            ),
          ],
        ),
      ),
    );
  }
}
