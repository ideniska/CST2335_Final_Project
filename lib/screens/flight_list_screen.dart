import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../providers/flight_provider.dart';
import 'flight_form_screen.dart';

class FlightListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flights List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FlightFormScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<FlightProvider>(context, listen: false).fetchFlights(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Consumer<FlightProvider>(
              builder: (context, flightProvider, child) => ListView.builder(
                itemCount: flightProvider.flights.length,
                itemBuilder: (context, index) {
                  final flight = flightProvider.flights[index];
                  return ListTile(
                    title: Text('${flight.departureCity} to ${flight.destinationCity}'),
                    subtitle: Text('${flight.departureTime} to ${flight.arrivalTime}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        Provider.of<FlightProvider>(context, listen: false).deleteFlight(flight.id!);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Flight removed')));
                      },
                    ),
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
    );
  }
}
