import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/airplane.dart';
import '../providers/airplane_provider.dart';
import '../l10n/app_localizations.dart';

// Define a stateful widget for the airplane form screen
class AirplaneFormScreen extends StatefulWidget {
  final Airplane? airplane;

  // Constructor to optionally accept an airplane for editing
  AirplaneFormScreen({this.airplane});

  @override
  _AirplaneFormScreenState createState() => _AirplaneFormScreenState();
}

// Define the state for the AirplaneFormScreen widget
class _AirplaneFormScreenState extends State<AirplaneFormScreen> {
  // Form key to validate and save the form
  final formKey = GlobalKey<FormState>();
  late String type;
  late int passengers;
  late double maxSpeed;
  late double range;

  // Initialize state and set initial values for form fields
  @override
  void initState() {
    super.initState();
    if (widget.airplane != null) {
      // If editing, set initial values from the airplane
      type = widget.airplane!.type;
      passengers = widget.airplane!.passengers;
      maxSpeed = widget.airplane!.maxSpeed;
      range = widget.airplane!.range;
    } else {
      // If adding a new airplane, set initial values to defaults
      type = '';
      passengers = 0;
      maxSpeed = 0;
      range = 0;
    }
  }

  // Build the UI of the form screen
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.airplane != null;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Set the title of the app bar based on whether editing or adding
        title: Text(isEditing ? localizations.translate('editAirplane')! : localizations.translate('addAirplane')!),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Build form fields for airplane attributes
              buildTextFormField(localizations, 'type', type, (value) => type = value!),
              buildTextFormField(localizations, 'passengers', passengers.toString(), (value) => passengers = int.parse(value!), keyboardType: TextInputType.number),
              buildTextFormField(localizations, 'maxSpeed', maxSpeed.toString(), (value) => maxSpeed = double.parse(value!), keyboardType: TextInputType.number),
              buildTextFormField(localizations, 'range', range.toString(), (value) => range = double.parse(value!), keyboardType: TextInputType.number),
              SizedBox(height: 20),
              // Build the row of buttons (submit, update, delete)
              buildButtonRow(context, localizations, isEditing),
            ],
          ),
        ),
      ),
    );
  }

  // Build a text form field with validation and saving
  TextFormField buildTextFormField(AppLocalizations localizations, String label, String initialValue, Function(String?) onSaved, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: localizations.translate(label)),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return localizations.translate('pleaseEnter$label');
        }
        if (keyboardType == TextInputType.number) {
          final parsedValue = keyboardType == TextInputType.number ? num.tryParse(value) : null;
          if (parsedValue == null || parsedValue <= 0) {
            return localizations.translate('pleaseEnterValidNumber');
          }
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  // Build the row of buttons at the bottom of the form
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

  // Build the edit button for updating an existing airplane
  ElevatedButton buildEditButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          final updatedAirplane = Airplane(
            id: widget.airplane!.id,
            type: type,
            passengers: passengers,
            maxSpeed: maxSpeed,
            range: range,
          );
          // Update the airplane in the provider and navigate back
          await Provider.of<AirplaneProvider>(context, listen: false).updateAirplane(updatedAirplane);
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate('update')!),
    );
  }

  // Build the delete button for removing an existing airplane
  ElevatedButton buildDeleteButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () async {
        // Delete the airplane in the provider and navigate back
        await Provider.of<AirplaneProvider>(context, listen: false).deleteAirplane(widget.airplane!.id!);
        Navigator.of(context).pop();
      },
      child: Text(localizations.translate('delete')!),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }

  // Build the submit button for adding a new airplane
  ElevatedButton buildSubmitButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          final newAirplane = Airplane(
            type: type,
            passengers: passengers,
            maxSpeed: maxSpeed,
            range: range,
          );
          // Add the new airplane in the provider and navigate back
          await Provider.of<AirplaneProvider>(context, listen: false).addAirplane(newAirplane);
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate('submit')!),
    );
  }
}