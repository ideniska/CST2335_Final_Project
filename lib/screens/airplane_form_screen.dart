import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/airplane.dart';
import '../providers/airplane_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../l10n/localization_delegate.dart';

class AirplaneFormScreen extends StatefulWidget {
  final Airplane? airplane;

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
  Future<void> _loadPreviousFields() async {
    type = await encryptedPrefs.getString('type') ?? '';
    passengers = int.tryParse(await encryptedPrefs.getString('passengers') ?? '0') ?? 0;
    maxSpeed = double.tryParse(await encryptedPrefs.getString('maxSpeed') ?? '0.0') ?? 0.0;
    range = double.tryParse(await encryptedPrefs.getString('range') ?? '0.0') ?? 0.0;
    setState(() {});
  }

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
        actions: [
          buildLanguageDropdown(context),
          buildInfoButton(context, localizations),
        ],
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
  DropdownButton<Locale> buildLanguageDropdown(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return DropdownButton<Locale>(
      value: localeProvider.locale,
      icon: Icon(Icons.language, color: Colors.white),
      items: L10n.all.map((locale) {
        final flag = L10n.getFlag(locale.languageCode);
        return DropdownMenuItem(
          child: Center(child: Text(flag, style: TextStyle(fontSize: 24))),
          value: locale,
          onTap: () {
            localeProvider.setLocale(locale);
          },
        );
      }).toList(),
      onChanged: (_) {},
    );
  }

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
                Text(localizations.translate('airplaneFormInstruction1')!),
                SizedBox(height: 8),
                Text(localizations.translate('airplaneFormInstruction2')!),
                SizedBox(height: 8),
                Text(localizations.translate('airplaneFormInstruction3')!),
                SizedBox(height: 8),
                Text(localizations.translate('airplaneFormInstruction4')!),
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
        }
      },
      child: Text(localizations.translate('submit')!),
    );
  }
}
