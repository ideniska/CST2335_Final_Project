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
      body: OrientationBuilder(
        builder: (context, orientation) {
          return buildBody(airplaneProvider, localizations, orientation);
        },
      ),
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

  Widget buildBody(AirplaneProvider airplaneProvider, AppLocalizations localizations, Orientation orientation) {
    return airplaneProvider.airplanes.isEmpty
        ? Center(child: Text(localizations.translate('noItemsAvailable')!))
        : LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 || orientation == Orientation.landscape) {
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
                  await Provider.of<AirplaneProvider>(context, listen: false).deleteAirplane(airplane.id!);
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizations.translate('delete') ?? 'Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
