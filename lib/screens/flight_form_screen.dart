import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../providers/flight_provider.dart';
import '../providers/locale_provider.dart';  // Add this line
import '../l10n/app_localizations.dart';
import '../l10n/localization_delegate.dart';

class FlightFormScreen extends StatefulWidget {
  final Flight? flight;

  FlightFormScreen({this.flight});

  @override
  _FlightFormScreenState createState() => _FlightFormScreenState();
}

class _FlightFormScreenState extends State<FlightFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _flightData = {
    'departureCity': '',
    'destinationCity': '',
    'departureTime': '',
    'arrivalTime': ''
  };

  @override
  void initState() {
    if (widget.flight != null) {
      _flightData['departureCity'] = widget.flight!.departureCity;
      _flightData['destinationCity'] = widget.flight!.destinationCity;
      _flightData['departureTime'] = widget.flight!.departureTime;
      _flightData['arrivalTime'] = widget.flight!.arrivalTime;
    }
    super.initState();
  }

  void _saveForm() {
    final localizations = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final flight = Flight(
        id: widget.flight?.id,
        departureCity: _flightData['departureCity']!,
        destinationCity: _flightData['destinationCity']!,
        departureTime: _flightData['departureTime']!,
        arrivalTime: _flightData['arrivalTime']!,
      );
      if (widget.flight == null) {
        Provider.of<FlightProvider>(context, listen: false).addFlight(flight);
      } else {
        Provider.of<FlightProvider>(context, listen: false).updateFlight(flight);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flight == null ? localizations.translate('addFlight') ?? 'Add Flight' : localizations.translate('editFlight') ?? 'Edit Flight'),
        actions: [
          buildLanguageDropdown(context),
          buildInfoButton(context, localizations),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextFormField(localizations, 'departureCity', _flightData['departureCity']!, (value) => _flightData['departureCity'] = value!),
              buildTextFormField(localizations, 'destinationCity', _flightData['destinationCity']!, (value) => _flightData['destinationCity'] = value!),
              buildTextFormField(localizations, 'departureTime', _flightData['departureTime']!, (value) => _flightData['departureTime'] = value!),
              buildTextFormField(localizations, 'arrivalTime', _flightData['arrivalTime']!, (value) => _flightData['arrivalTime'] = value!),
              SizedBox(height: 20),
              buildButtonRow(context, localizations, widget.flight != null),
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
      onPressed: () {
        _saveForm();
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

        if (confirm == true && widget.flight != null) {
          await Provider.of<FlightProvider>(context, listen: false).deleteFlight(widget.flight!.id!);
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate('delete') ?? 'Delete'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }

  ElevatedButton buildSubmitButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () {
        _saveForm();
      },
      child: Text(localizations.translate('submit')!),
    );
  }
}