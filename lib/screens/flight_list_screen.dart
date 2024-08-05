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
        actions: [
          buildInfoButton(context, localizations),
        ],
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

/// Builds an info button that shows a dialog with instructions when pressed.
IconButton buildInfoButton(BuildContext context, AppLocalizations localizations) {
  return IconButton(
    icon: Icon(Icons.info),
    onPressed: () {
      // Show a dialog with instructions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.translate('instructions')!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.translate('appInstruction1')!),
              SizedBox(height: 8),
              Text(localizations.translate('appInstruction2')!),
              SizedBox(height: 8),
              Text(localizations.translate('appInstruction3')!),
              SizedBox(height: 8),
              Text(localizations.translate('appInstruction4')!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.translate('ok')!),
            ),
          ],
        ),
      );
    },
  );
}
