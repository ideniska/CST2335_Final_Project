import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation.dart';
import '../models/customer.dart';
import '../models/flight.dart';
import '../providers/customer_provider.dart';
import '../providers/flight_provider.dart';
import '../providers/reservation_provider.dart';
import '../l10n/app_localizations.dart';

class ReservationFormScreen extends StatefulWidget {
  final Reservation? reservation;

  ReservationFormScreen({this.reservation});

  @override
  _ReservationFormScreenState createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final formKey = GlobalKey<FormState>();
  late int customerId;
  late int flightId;
  late DateTime date;
  late String name;
  List<Customer> customers = [];
  List<Flight> flights = [];

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      customerId = widget.reservation!.customerId;
      flightId = widget.reservation!.flightId;
      date = widget.reservation!.date;
      name = widget.reservation!.name;
    } else {
      customerId = 0;
      flightId = 0;
      date = DateTime.now();
      name = '';
    }
    loadData();
  }

  Future<void> loadData() async {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);

    customers = await customerProvider.listCustomers() ?? [];
    flights = await flightProvider.listFlights() ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return Scaffold(
        body: Center(child: Text('Localization not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservation != null
            ? localizations.translate('editReservation') ?? 'Edit Reservation'
            : localizations.translate('addReservation') ?? 'Add Reservation'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              _showInstructionsDialog(context, localizations);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(labelText: localizations.translate('name') ?? 'Name'),
                      onSaved: (value) => name = value ?? '',
                      validator: (value) => value!.isEmpty ? localizations.translate('pleaseEnterName') ?? 'Please enter a name' : null,
                    ),
                    buildDropdownField(
                      localizations,
                      'customers',
                      customers,
                          (Customer? value) {
                        customerId = value?.id ?? 0;
                      },
                          (Customer? value) => value != null ? value.fullName : '',
                      validator: (value) => value == null ? localizations.translate('pleaseSelectCustomer') ?? 'Please select a customer' : null,
                    ),
                    buildDropdownField(
                      localizations,
                      'flights',
                      flights,
                          (Flight? value) {
                        flightId = value?.id ?? 0;
                      },
                          (Flight? value) => value != null ? '${value.departureCity} to ${value.destinationCity}' : '',
                      validator: (value) => value == null ? localizations.translate('pleaseSelectFlight') ?? 'Please select a flight' : null,
                    ),
                    buildDatePicker(localizations),
                    SizedBox(height: 20),
                    buildSubmitButton(context, localizations),
                    if (widget.reservation != null) ...[
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Show the confirmation dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(AppLocalizations.of(context)?.translate('confirmDelete') ?? 'Confirm Delete'),
                                content: Text(AppLocalizations.of(context)?.translate('areYouSure') ?? 'Are you sure you want to delete this reservation?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Delete the reservation and pop the screen
                                      final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
                                      if (widget.reservation?.id != null) {
                                        reservationProvider.deleteReservation(widget.reservation!.id!);
                                        Navigator.of(context).pop(); // Close the dialog
                                        Navigator.of(context).pop(); // Pop the screen
                                      }
                                    },
                                    child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Color for the delete button
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructionsDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('instructions') ?? 'Instructions'),
          content: Text(localizations.translate('reservationFormInstructions') ?? 'Set your reservation and press submit to add it to the list.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(localizations.translate('ok') ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDropdownField<T>(
      AppLocalizations localizations,
      String label,
      List<T> items,
      Function(T?) onChanged,
      String Function(T?) displayValue, {
        FormFieldValidator<T?>? validator,
      }) {
    return DropdownButtonFormField<T>(
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(displayValue(item)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(labelText: localizations.translate(label) ?? label),
    );
  }

  Widget buildDatePicker(AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: Text(localizations.translate('date') ?? 'Date'),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            '${date.toLocal()}'.split(' ')[0], // Format date as needed
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null && pickedDate != date) {
              setState(() {
                date = pickedDate;
              });
            }
          },
        ),
      ],
    );
  }

  Widget buildSubmitButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          final reservation = Reservation(
            id: widget.reservation?.id,
            customerId: customerId,
            flightId: flightId,
            date: date,
            name: name,
          );
          final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
          if (widget.reservation != null) {
            if (reservation.id != null) {
              await reservationProvider.updateReservation(reservation);
            }
          } else {
            await reservationProvider.addReservation(reservation);
          }
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate(widget.reservation != null ? 'update' : 'submit') ?? 'Submit'),
    );
  }
}
