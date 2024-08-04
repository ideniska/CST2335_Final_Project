import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/reservation.dart';
import '../models/customer.dart';
import '../models/flight.dart';
import '../providers/customer_provider.dart';
import '../providers/flight_provider.dart';
import '../providers/reservation_provider.dart';
import '../l10n/app_localizations.dart';

/// Screen for adding or editing a reservation.
///
/// Displays a form with fields for reservation details and options to submit or delete a reservation.
class ReservationFormScreen extends StatefulWidget {
  /// The reservation to be edited, if any.
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
  late TextEditingController nameController;
  List<Customer> customers = [];
  List<Flight> flights = [];
  late EncryptedSharedPreferences encryptedSharedPreferences;

  @override
  void initState() {
    super.initState();
    encryptedSharedPreferences = EncryptedSharedPreferences();
    nameController = TextEditingController(text: widget.reservation?.name ?? '');

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
    if (widget.reservation == null) {
      _checkForAutofill(); // Check for autofill only if adding a new reservation
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  /// Loads the list of customers and flights from their respective providers.
  Future<void> loadData() async {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);

    customers = await customerProvider.listCustomers() ?? [];
    flights = await flightProvider.listFlights() ?? [];
    setState(() {});
  }

  /// Checks for and applies autofill data from encrypted shared preferences.
  Future<void> _checkForAutofill() async {
    final storedName = await encryptedSharedPreferences.getString('reservation_name');
    if (storedName != null && storedName.isNotEmpty) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.translate('autofillPrompt') ?? 'Would you like to autofill the name field?'),
          action: SnackBarAction(
            label: localizations?.translate('autofill') ?? 'Autofill',
            onPressed: () {
              setState(() {
                name = storedName;
                nameController.text = storedName; // Update the controller
              });
            },
          ),
        ),
      );
    }
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
        child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: localizations.translate('name') ?? 'Name'),
                      onSaved: (value) => name = value ?? '',
                      validator: (value) => value!.isEmpty ? localizations.translate('pleaseEnterName') ?? 'Please enter a name' : null,
                    ),
                    buildDropdownField<Customer>(
                      localizations,
                      'customers',
                      customers,
                          (Customer? value) {
                        customerId = value?.id ?? 0;
                      },
                          (Customer? value) => value != null ? value.fullName : '',
                      initialValue: firstWhereOrNull(customers, (customer) => customer.id == customerId),
                      validator: (value) => value == null ? localizations.translate('pleaseSelectCustomer') ?? 'Please select a customer' : null,
                    ),
                    buildDropdownField<Flight>(
                      localizations,
                      'flights',
                      flights,
                          (Flight? value) {
                        flightId = value?.id ?? 0;
                      },
                          (Flight? value) => value != null ? '${value.departureCity} to ${value.destinationCity}' : '',
                      initialValue: firstWhereOrNull(flights, (flight) => flight.id == flightId),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Displays a dialog with instructions for using the reservation form.
  ///
  /// [context] - The build context to use for showing the dialog.
  /// [localizations] - Provides localized strings for the dialog content.
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

  /// Builds a dropdown field for selecting an item from a list.
  ///
  /// [localizations] - Provides localized strings for the dropdown label.
  /// [label] - The label for the dropdown field.
  /// [items] - The list of items to display in the dropdown.
  /// [onChanged] - Callback for when an item is selected.
  /// [displayValue] - Function to get the display value of an item.
  /// [validator] - Optional validator function for the dropdown.
  /// [initialValue] - The initial value for the dropdown.
  Widget buildDropdownField<T>(
      AppLocalizations localizations,
      String label,
      List<T> items,
      Function(T?) onChanged,
      String Function(T?) displayValue, {
        FormFieldValidator<T?>? validator,
        T? initialValue,
      }) {
    return DropdownButtonFormField<T>(
      value: initialValue,
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

  /// Builds a date picker field for selecting a date.
  ///
  /// [localizations] - Provides localized strings for the date picker label.
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

  /// Builds a submit button for the form.
  ///
  /// [context] - The build context to use for form submission.
  /// [localizations] - Provides localized strings for the button text.
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
          if (widget.reservation == null) {
            reservationProvider.addReservation(reservation);
          } else {
            reservationProvider.updateReservation(reservation);
          }

          // Save the name to encrypted shared preferences
          await encryptedSharedPreferences.setString('reservation_name', name);

          Navigator.pop(context);
        }
      },
      child: Text(localizations.translate('submit') ?? 'Submit'),
    );
  }

  /// Returns the first element that matches the given test function, or null if no match is found.
  ///
  /// [items] - The list of items to search through.
  /// [test] - The test function to apply to each item.
  T? firstWhereOrNull<T>(List<T> items, bool Function(T) test) {
    for (var item in items) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }
}
