import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../providers/flight_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// A screen for adding or editing a flight.
class FlightFormScreen extends StatefulWidget {
  /// The flight to edit.
  final Flight? flight;

  /// Creates a [FlightFormScreen].
  FlightFormScreen({this.flight});

  @override
  _FlightFormScreenState createState() => _FlightFormScreenState();
}

class _FlightFormScreenState extends State<FlightFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final encryptedPrefs = EncryptedSharedPreferences();

  late String departureCity;
  late String destinationCity;
  late String departureTime;
  late String arrivalTime;

  late TextEditingController departureCityController;
  late TextEditingController destinationCityController;
  late TextEditingController departureTimeController;
  late TextEditingController arrivalTimeController;


  @override
  void initState() {
    super.initState();
    if (widget.flight != null) {
      departureCity = widget.flight?.departureCity ?? '';
      destinationCity = widget.flight?.destinationCity ?? '';
      departureTime = widget.flight?.departureTime ?? '';
      arrivalTime = widget.flight?.arrivalTime ?? '';
    } else {
      departureCity = '';
      destinationCity = '';
      departureTime = '';
      arrivalTime = '';
      promptUsePreviousData();
    }
    departureCityController = TextEditingController(text: departureCity);
    destinationCityController = TextEditingController(text: destinationCity);
    departureTimeController = TextEditingController(text: departureTime);
    arrivalTimeController = TextEditingController(text: arrivalTime);
  }

  @override
  void dispose() {
    departureCityController.dispose();
    destinationCityController.dispose();
    departureTimeController.dispose();
    arrivalTimeController.dispose();
    super.dispose();
  }

  /// Prompts the user to use previous flight data if available.
  Future<void> promptUsePreviousData() async {
    final previousDepartureCity = await encryptedPrefs.getString('departureCity');
    if (previousDepartureCity != null && previousDepartureCity.isNotEmpty) {
      bool useData = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('usePreviousData') ?? 'Use previous flight data?'),
          content: Text(AppLocalizations.of(context)?.translate('reuseDataMessage') ?? 'Do you want to reuse the data of the last flight you entered?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)?.translate('no') ?? 'No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)?.translate('yes') ?? 'Yes'),
            ),
          ],
        ),
      );

      if (useData) {
        final previousDestinationCity = await encryptedPrefs.getString('destinationCity') ?? '';
        final previousDepartureTime = await encryptedPrefs.getString('departureTime') ?? '';
        final previousArrivalTime = await encryptedPrefs.getString('arrivalTime') ?? '';

        setState(() {
          departureCity = previousDepartureCity;
          destinationCity = previousDestinationCity;
          departureTime = previousDepartureTime;
          arrivalTime = previousArrivalTime;
          departureCityController.text = departureCity;
          destinationCityController.text = destinationCity;
          departureTimeController.text = departureTime;
          arrivalTimeController.text = arrivalTime;
        });
      }
    }
  }


  /// Saves the current form fields to encrypted shared preferences.
  Future<void> _saveFields() async {
    await encryptedPrefs.setString('departureCity', departureCity);
    await encryptedPrefs.setString('destinationCity', destinationCity);
    await encryptedPrefs.setString('departureTime', departureTime);
    await encryptedPrefs.setString('arrivalTime', arrivalTime);
  }

  /// Saves the form data and updates or adds the flight.
  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final flight = Flight(
        id: widget.flight?.id,
        departureCity: departureCity,
        destinationCity: destinationCity,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
      );
      if (widget.flight == null) {
        Provider.of<FlightProvider>(context, listen: false).addFlight(flight);
      } else {
        Provider.of<FlightProvider>(context, listen: false).updateFlight(flight);
      }
      await _saveFields();
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flight == null ? localizations.translate('addFlight') ?? 'Add Flight' : localizations.translate('editFlight') ?? 'Edit Flight'),

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTextFormField(localizations, 'departureCity', departureCityController, (value) => departureCity = value!),
                buildTextFormField(localizations, 'destinationCity', destinationCityController, (value) => destinationCity = value!),
                buildTextFormField(localizations, 'departureTime', departureTimeController, (value) => departureTime = value!),
                buildTextFormField(localizations, 'arrivalTime', arrivalTimeController, (value) => arrivalTime = value!),
                SizedBox(height: 20),
                buildButtonRow(context, localizations, widget.flight != null),
              ],
            ),
          ),
        ),
      ),

    );
  }



  /// Builds a text form field with validation and saving logic.
  TextFormField buildTextFormField(AppLocalizations localizations, String label, TextEditingController controller, Function(String?) onSaved, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: localizations.translate(label) ?? label),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.translate('pleaseEnter$label') ?? 'Please enter $label';
        }
        if (keyboardType == TextInputType.number) {
          final parsedValue = num.tryParse(value);
          if (parsedValue == null || parsedValue <= 0) {
            return localizations.translate('pleaseEnterValidNumber') ?? 'Please enter a valid number';
          }
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  /// Builds a row of buttons for submitting, updating, or deleting the form.
  Row buildButtonRow(BuildContext context, AppLocalizations localizations, bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (isEditing) buildEditButton(context, localizations),
        if (isEditing) buildDeleteButton(context, localizations),
        if (!isEditing) buildSubmitButton(context, localizations),
      ],
    );
  }

  /// Builds a button for updating an existing flight.
  ElevatedButton buildEditButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () {
        _saveForm();
      },
      child: Text(localizations.translate('update')!),
    );
  }

  /// Builds a button for deleting an existing flight.
  ElevatedButton buildDeleteButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
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

        if (confirm == true && widget.flight != null) {
          await Provider.of<FlightProvider>(context, listen: false).deleteFlight(widget.flight!.id!);
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate('delete') ?? 'Delete'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }

  /// Builds a button for submitting a new flight.
  ElevatedButton buildSubmitButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () {
        _saveForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.translate('flightAdded')!)),
        );
      },
      child: Text(localizations.translate('submit')!),
    );
  }
}