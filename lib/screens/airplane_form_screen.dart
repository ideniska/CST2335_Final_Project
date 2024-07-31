import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/airplane.dart';
import '../providers/airplane_provider.dart';
import '../l10n/app_localizations.dart';

class AirplaneFormScreen extends StatefulWidget {
  final Airplane? airplane;

  AirplaneFormScreen({this.airplane});

  @override
  _AirplaneFormScreenState createState() => _AirplaneFormScreenState();
}

class _AirplaneFormScreenState extends State<AirplaneFormScreen> {
  final formKey = GlobalKey<FormState>();
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
      type = '';
      passengers = 0;
      maxSpeed = 0.0;
      range = 0.0;
    }
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
          final parsedValue = num.tryParse(value);
          if (parsedValue == null || parsedValue <= 0) {
            return localizations.translate('pleaseEnterValidNumber');
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
        await Provider.of<AirplaneProvider>(context, listen: false).deleteAirplane(widget.airplane!.id!);
        Navigator.of(context).pop();
      },
      child: Text(localizations.translate('delete')!),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }

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
          await Provider.of<AirplaneProvider>(context, listen: false).addAirplane(newAirplane);
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate('submit')!),
    );
  }
}
