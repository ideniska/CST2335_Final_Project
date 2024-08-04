import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/flight_provider.dart';
import 'flight_form_screen.dart';

/// A screen that displays a list of flights.
class FlightListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('flights')!),
      ),
      body: FutureBuilder(
        future: Provider.of<FlightProvider>(context, listen: false).fetchFlights(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(localizations.translate('errorLoadingFlights')!));
          } else {
            return Consumer<FlightProvider>(
              builder: (context, flightProvider, child) => ListView.builder(
                itemCount: flightProvider.flights.length,
                itemBuilder: (context, index) {
                  final flight = flightProvider.flights[index];
                  return ListTile(
                    title: Text('${flight.departureCity} to ${flight.destinationCity}'),
                    subtitle: Text('${flight.departureTime} to ${flight.arrivalTime}'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FlightFormScreen(flight: flight),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FlightFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),

    );
  }
}
