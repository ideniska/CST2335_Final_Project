import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/airplane_provider.dart';
import 'airplane_form_screen.dart';
import '../models/airplane.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localization_delegate.dart';

// Define a stateful widget for displaying the list of airplanes
class AirplaneListScreen extends StatefulWidget {
  @override
  AirplaneListScreenState createState() => AirplaneListScreenState();
}

// Define the state for the AirplaneListScreen widget
class AirplaneListScreenState extends State<AirplaneListScreen> {
  // Variable to hold the selected airplane
  Airplane? selectedAirplane;

  // Initialize state and load airplanes from the database
  @override
  void initState() {
    super.initState();
    Provider.of<AirplaneProvider>(context, listen: false).loadAirplanes();
  }

  // Build the UI of the screen
  @override
  Widget build(BuildContext context) {
    // Get the airplane provider, localizations, and locale provider from the context
    final airplaneProvider = Provider.of<AirplaneProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // Set the title of the app bar using localized text
        title: Text(localizations.translate('airplanes')!),
        actions: [
          // Add a dropdown for changing language
          buildLanguageDropdown(localeProvider),
          // Add an info button to show instructions
          buildInfoButton(localizations),
        ],
      ),
      // Build the main body of the screen
      body: buildBody(airplaneProvider, localizations),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the airplane form screen when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AirplaneFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Build the language dropdown menu
  DropdownButton<Locale> buildLanguageDropdown(LocaleProvider localeProvider) {
    return DropdownButton<Locale>(
      value: localeProvider.locale,
      icon: Icon(Icons.language, color: Colors.white),
      items: L10n.all.map((locale) {
        final flag = L10n.getFlag(locale.languageCode);
        return DropdownMenuItem(
          child: Center(child: Text(flag, style: TextStyle(fontSize: 24))),
          value: locale,
          onTap: () {
            // Set the selected locale
            localeProvider.setLocale(locale);
          },
        );
      }).toList(),
      onChanged: (_) {},
    );
  }

  // Build the info button to show instructions
  IconButton buildInfoButton(AppLocalizations localizations) {
    return IconButton(
      icon: Icon(Icons.info),
      onPressed: () {
        // Show a dialog with instructions
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.translate('instructions')!),
            content: Text(localizations.translate('appInstructions')!),
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

  // Build the main body based on the screen size
  Widget buildBody(AirplaneProvider airplaneProvider, AppLocalizations localizations) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Build the tablet layout if the screen width is greater than 600 pixels
          return buildTabletLayout(airplaneProvider, localizations);
        } else {
          // Build the mobile layout if the screen width is 600 pixels or less
          return buildMobileLayout(airplaneProvider, localizations);
        }
      },
    );
  }

  // Build the layout for tablet screens
  Widget buildTabletLayout(AirplaneProvider airplaneProvider, AppLocalizations localizations) {
    return Row(
      children: [
        // List of airplanes
        Expanded(
          child: ListView.builder(
            itemCount: airplaneProvider.airplanes.length,
            itemBuilder: (context, index) {
              final airplane = airplaneProvider.airplanes[index];
              return ListTile(
                title: Text(airplane.type),
                subtitle: Text('${localizations.translate('passengers')}: ${airplane.passengers}'),
                onTap: () {
                  setState(() {
                    // Set the selected airplane
                    selectedAirplane = airplane;
                  });
                },
              );
            },
          ),
        ),
        // Display details of the selected airplane if one is selected
        if (selectedAirplane != null)
          Expanded(
            child: AirplaneDetail(airplane: selectedAirplane!),
          ),
      ],
    );
  }

  // Build the layout for mobile screens
  Widget buildMobileLayout(AirplaneProvider airplaneProvider, AppLocalizations localizations) {
    return ListView.builder(
      itemCount: airplaneProvider.airplanes.length,
      itemBuilder: (context, index) {
        final airplane = airplaneProvider.airplanes[index];
        return ListTile(
          title: Text(airplane.type),
          subtitle: Text('${localizations.translate('passengers')}: ${airplane.passengers}'),
          onTap: () {
            // Navigate to the airplane form screen with the selected airplane
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AirplaneFormScreen(airplane: airplane),
              ),
            );
          },
        );
      },
    );
  }
}

// Define a stateless widget for displaying details of an airplane
class AirplaneDetail extends StatelessWidget {
  final Airplane airplane;

  const AirplaneDetail({required this.airplane});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(airplane.type, style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 8.0),
            Text('${localizations.translate('passengers')}: ${airplane.passengers}'),
            Text('${localizations.translate('maxSpeed')}: ${airplane.maxSpeed} km/h'),
            Text('${localizations.translate('range')}: ${airplane.range} km'),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the airplane form screen with the selected airplane for editing
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AirplaneFormScreen(airplane: airplane),
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