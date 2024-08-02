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
  List<Customer> customers = [];
  List<Flight> flights = [];

  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      customerId = widget.reservation!.customerId;
      flightId = widget.reservation!.flightId;
      date = widget.reservation!.date;
    } else {
      customerId = 0;
      flightId = 0;
      date = DateTime.now();
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              buildDropdownField(
                localizations,
                'customer',
                customers,
                    (Customer? value) {
                  customerId = value?.id ?? 0;
                },
                    (Customer? value) => value != null ? value.fullName : '',
                validator: (value) => value == null ? localizations.translate('pleaseSelectCustomer') ?? 'Please select a customer' : null,
              ),
              buildDropdownField(
                localizations,
                'flight',
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
            ],
          ),
        ),
      ),
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
          );
          if (widget.reservation != null) {
            await Provider.of<ReservationProvider>(context, listen: false).updateReservation(reservation);
          } else {
            await Provider.of<ReservationProvider>(context, listen: false).addReservation(reservation);
          }
          Navigator.of(context).pop();
        }
      },
      child: Text(localizations.translate(widget.reservation != null ? 'update' : 'submit') ?? 'Submit'),
    );
  }
}
