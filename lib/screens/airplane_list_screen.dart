import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/airplane_provider.dart';
import 'airplane_form_screen.dart';
import '../models/airplane.dart';
import '../l10n/app_localizations.dart';

class AirplaneListScreen extends StatefulWidget {
  @override
  AirplaneListScreenState createState() => AirplaneListScreenState();
}

class AirplaneListScreenState extends State<AirplaneListScreen> {
  Airplane? selectedAirplane;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<AirplaneProvider>(context, listen: false).loadAirplanes());
  }

  @override
  Widget build(BuildContext context) {
    final airplaneProvider = Provider.of<AirplaneProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('airplanes')!),
      ),
      body: buildBody(airplaneProvider, localizations),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AirplaneFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildBody(AirplaneProvider airplaneProvider, AppLocalizations localizations) {
    return airplaneProvider.airplanes.isEmpty
        ? Center(child: Text(localizations.translate('noItemsAvailable')!))
        : LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return buildTabletLayout(airplaneProvider, localizations);
        } else {
          return buildMobileLayout(airplaneProvider, localizations);
        }
      },
    );
  }

  Widget buildTabletLayout(AirplaneProvider airplaneProvider, AppLocalizations localizations) {
    return Row(
      children: [
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
                    selectedAirplane = airplane;
                  });
                },
              );
            },
          ),
        ),
        if (selectedAirplane != null)
          Expanded(
            child: AirplaneDetail(airplane: selectedAirplane!),
          ),
      ],
    );
  }

  Widget buildMobileLayout(AirplaneProvider airplaneProvider, AppLocalizations localizations) {
    return ListView.builder(
      itemCount: airplaneProvider.airplanes.length,
      itemBuilder: (context, index) {
        final airplane = airplaneProvider.airplanes[index];
        return ListTile(
          title: Text(airplane.type),
          subtitle: Text('${localizations.translate('passengers')}: ${airplane.passengers}'),
          onTap: () {
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
