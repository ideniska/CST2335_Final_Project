import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/airplane.dart';
import '../providers/airplane_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../l10n/localization_delegate.dart';

/// A screen for adding or editing an airplane.
class AirplaneFormScreen extends StatefulWidget {
  /// The airplane to edit. If null, the form will be for adding a new airplane.
  final Airplane? airplane;

  /// Creates an [AirplaneFormScreen].
  AirplaneFormScreen({this.airplane});

  @override
  _AirplaneFormScreenState createState() => _AirplaneFormScreenState();
}

class _AirplaneFormScreenState extends State<AirplaneFormScreen> {
  final formKey = GlobalKey<FormState>();
  final encryptedPrefs = EncryptedSharedPreferences();

  late String type;
  late int passengers;
  late double maxSpeed;
  late double range;

  @override
  void initState() {
    super.initState();
    if (widget.airplane != null) {
      type = widget.airplane?.type ?? '';
      passengers = widget.airplane?.passengers ?? 0;
      maxSpeed = widget.airplane?.maxSpeed ?? 0.0;
      range = widget.airplane?.range ?? 0.0;
    } else {
      _loadPreviousFields();
    }
  }

  /// Loads previously saved form fields from encrypted shared preferences.
  Future<void> _loadPreviousFields() async {
    type = await encryptedPrefs.getString('type') ?? '';
    passengers = int.tryParse(await encryptedPrefs.getString('passengers') ?? '0') ?? 0;
    maxSpeed = double.tryParse(await encryptedPrefs.getString('maxSpeed') ?? '0.0') ?? 0.0;
    range = double.tryParse(await encryptedPrefs.getString('range') ?? '0.0') ?? 0.0;
    setState(() {});
  }

  /// Saves the current form fields to encrypted shared preferences.
  Future<void> _saveFields() async {
    await encryptedPrefs.setString('type', type);
    await encryptedPrefs.setString('passengers', passengers.toString());
    await encryptedPrefs.setString('maxSpeed', maxSpeed.toString());
    await encryptedPrefs.setString('range', range.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.airplane != null;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? localizations.translate('editAirplane')! : localizations.translate('addAirplane')!),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              buildTextFormField(localizations, 'type', type, (value) => type = value!),
              buildTextFormField(localizations, 'passengers', passengers.toString(), (value) => passengers = int.parse(value!), keyboardType: TextInputType.number),
              buildTextFormField(localizations, 'maxSpeed', maxSpeed.toString(), (value) => maxSpeed = double.parse(value!), keyboardType: TextInputType.number),
              buildTextFormField(localizations, 'range', range.toString(), (value) => range = double.parse(value!), keyboardType: TextInputType.number),
              SizedBox(height: 20),
              buildButtonRow(context, localizations, isEditing),
            ],
          ),
        ),
      ),
    );
  }



  /// Builds a text form field with validation and saving logic.
  TextFormField buildTextFormField(AppLocalizations localizations, String label, String initialValue, Function(String?) onSaved, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      initialValue: initialValue,
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

  /// Builds a button for updating an existing airplane.
  ElevatedButton buildEditButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await _saveFields();
          final updatedAirplane = Airplane(
            id: widget.airplane!.id,
            type: type,
            passengers: passengers,
            maxSpeed: maxSpeed,
            range: range,
          );
          await Provider.of<AirplaneProvider>(context, listen: false).updateAirplane(updatedAirplane);
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate('update')!),
    );
  }

  /// Builds a button for deleting an existing airplane.
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

        if (confirm == true && widget.airplane != null) {
          await Provider.of<AirplaneProvider>(context, listen: false).deleteAirplane(widget.airplane!.id!);
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate('delete') ?? 'Delete'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }

  /// Builds a button for submitting a new airplane.
  ElevatedButton buildSubmitButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          await _saveFields();
          final newAirplane = Airplane(
            type: type,
            passengers: passengers,
            maxSpeed: maxSpeed,
            range: range,
          );
          await Provider.of<AirplaneProvider>(context, listen: false).addAirplane(newAirplane);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.translate('airplaneAdded')!)),
          );
        }
      },
      child: Text(localizations.translate('submit')!),
    );
  }
}
