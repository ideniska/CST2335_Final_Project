import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/flight_provider.dart';
import 'flight_form_screen.dart';
import '../models/flight.dart';

/// A screen that displays a list of flights.
class FlightListScreen extends StatefulWidget {
  @override
  FlightListScreenState createState() => FlightListScreenState();
}

/// The state for the [FlightListScreen].
class FlightListScreenState extends State<FlightListScreen> {
  Flight? selectedFlight;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<FlightProvider>(context, listen: false).fetchFlights());
  }

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
      body: OrientationBuilder(
        builder: (context, orientation) {
          return buildBody(context, localizations, orientation);
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
                Text(localizations.translate('flightInstruction1')!),
                SizedBox(height: 8),
                Text(localizations.translate('flightInstruction2')!),
                SizedBox(height: 8),
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

  /// Builds the body of the screen based on the orientation.
  Widget buildBody(BuildContext context, AppLocalizations localizations, Orientation orientation) {
    return FutureBuilder(
      future: Provider.of<FlightProvider>(context, listen: false).fetchFlights(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(localizations.translate('errorLoadingFlights')!));
        } else {
          return Consumer<FlightProvider>(
            builder: (context, flightProvider, child) {
              if (flightProvider.flights.isEmpty) {
                return Center(child: Text(localizations.translate('noItemsAvailable')!));
              } else {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600 || orientation == Orientation.landscape) {
                      return buildTabletLayout(flightProvider, localizations);
                    } else {
                      return buildMobileLayout(flightProvider, localizations);
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  /// Builds the layout for tablet devices.
  Widget buildTabletLayout(FlightProvider flightProvider, AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: flightProvider.flights.length,
            itemBuilder: (context, index) {
              final flight = flightProvider.flights[index];
              return ListTile(
                title: Text('${flight.departureCity} to ${flight.destinationCity}'),
                subtitle: Text('${flight.departureTime} to ${flight.arrivalTime}'),
                onTap: () {
                  setState(() {
                    selectedFlight = flight;
                  });
                },
              );
            },
          ),
        ),
        if (selectedFlight != null)
          Expanded(
            child: FlightDetail(flight: selectedFlight!),
          ),
      ],
    );
  }

  /// Builds the layout for mobile devices.
  Widget buildMobileLayout(FlightProvider flightProvider, AppLocalizations localizations) {
    return ListView.builder(
      itemCount: flightProvider.flights.length,
      itemBuilder: (context, index) {
        final flight = flightProvider.flights[index];
        return ListTile(
          title: Text('${flight.departureCity} to ${flight.destinationCity}'),
          subtitle: Text('${flight.departureTime} to ${flight.arrivalTime}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlightFormScreen(flight: flight),
              ),
            );
          },
        );
      },
    );
  }
}

/// A widget that displays the details of a flight.
class FlightDetail extends StatelessWidget {
  final Flight flight;

  /// Creates a [FlightDetail] widget.
  const FlightDetail({required this.flight});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${flight.departureCity} to ${flight.destinationCity}', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8.0),
              Text('${localizations.translate('departureCity')}: ${flight.departureCity}'),
              Text('${localizations.translate('destinationCity')}: ${flight.destinationCity}'),
              Text('${localizations.translate('departureTime')}: ${flight.departureTime}'),
              Text('${localizations.translate('arrivalTime')}: ${flight.arrivalTime}'),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlightFormScreen(flight: flight),
                    ),
                  );
                },
                child: Text(localizations.translate('edit')!),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(localizations.translate('confirmDelete') ?? 'Confirm Delete'),
                        content: Text(localizations.translate('areYouSure') ?? 'Are you sure?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(localizations.translate('cancel') ?? 'Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(localizations.translate('delete') ?? 'Delete'),
                            style: TextButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await Provider.of<FlightProvider>(context, listen: false).deleteFlight(flight.id!);
                    Navigator.of(context).pop();
                  }
                },
                child: Text(localizations.translate('delete') ?? 'Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
