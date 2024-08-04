import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import 'package:intl/intl.dart'; // For formatting the date
import '../l10n/app_localizations.dart';

/// A screen for adding or editing a customer.
class CustomerFormScreen extends StatefulWidget {
  /// The customer to be edited. If null, a new customer will be added.
  final Customer? customer;

  /// Creates a [CustomerFormScreen] widget.
  CustomerFormScreen({this.customer});

  @override
  CustomerFormScreenState createState() => CustomerFormScreenState();
}

class CustomerFormScreenState extends State<CustomerFormScreen> {
  final formKey = GlobalKey<FormState>();
  late String firstName;
  late String lastName;
  late String address;
  late DateTime birthday;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController addressController;
  late TextEditingController birthdayController;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      firstName = widget.customer!.firstName;
      lastName = widget.customer!.lastName;
      address = widget.customer!.address;
      birthday = widget.customer!.birthday;
    } else {
      firstName = '';
      lastName = '';
      address = '';
      birthday = DateTime.now();
      promptUsePreviousData();
    }
    firstNameController = TextEditingController(text: firstName);
    lastNameController = TextEditingController(text: lastName);
    addressController = TextEditingController(text: address);
    birthdayController = TextEditingController(text: DateFormat.yMd().format(birthday));
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  /// Prompts the user to use previous customer data if available.
  ///
  /// If previous customer data is available in [SharedPreferences], the user is prompted with a dialog
  /// this allows to reuse the data
  Future<void> promptUsePreviousData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('firstName')) {
      bool useData = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('usePreviousData') ?? 'Use previous customer data?'),
          content: Text(AppLocalizations.of(context)?.translate('reuseDataMessage') ?? 'Do you want to reuse the data of the last customer you entered?'),
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
        setState(() {
          firstName = prefs.getString('firstName') ?? '';
          lastName = prefs.getString('lastName') ?? '';
          address = prefs.getString('address') ?? '';
          birthday = DateTime.parse(prefs.getString('birthday') ?? DateTime.now().toString());
          firstNameController.text = firstName;
          lastNameController.text = lastName;
          addressController.text = address;
          birthdayController.text = DateFormat.yMd().format(birthday);
        });
      }
    }
  }


  /// Saves the given [Customer] data to [SharedPreferences].
  Future<void> saveCustomerData(Customer customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', customer.firstName);
    await prefs.setString('lastName', customer.lastName);
    await prefs.setString('address', customer.address);
    await prefs.setString('birthday', customer.birthday.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? localizations.translate('editCustomer') ?? 'Edit Customer' : localizations.translate('addCustomer') ?? 'Add Customer'),
      ),
      body: SingleChildScrollView(  // <-- Added SingleChildScrollView
        child: Padding(  // <-- Added Padding
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: localizations.translate('firstName') ?? 'First Name'),
                  validator: (value) => value!.isEmpty ? localizations.translate('pleaseEnterFirstName') ?? 'Please enter a first name' : null,
                  onSaved: (value) => firstName = value!,
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: localizations.translate('lastName') ?? 'Last Name'),
                  validator: (value) => value!.isEmpty ? localizations.translate('pleaseEnterLastName') ?? 'Please enter a last name' : null,
                  onSaved: (value) => lastName = value!,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: localizations.translate('address') ?? 'Address'),
                  validator: (value) => value!.isEmpty ? localizations.translate('pleaseEnterAddress') ?? 'Please enter an address' : null,
                  onSaved: (value) => address = value!,
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: birthday,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != birthday)
                      setState(() {
                        birthday = pickedDate;
                        birthdayController.text = DateFormat.yMd().format(birthday);
                      });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: birthdayController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('birthday') ?? 'Birthday',
                        hintText: DateFormat.yMd().format(birthday),
                      ),
                      validator: (value) => value!.isEmpty ? localizations.translate('pleaseEnterBirthday') ?? 'Please enter a birthday' : null,
                      onSaved: (value) => birthday = DateFormat.yMd().parse(birthdayController.text),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (isEditing) ...[
                      ElevatedButton(
                        onPressed: updateCustomer,
                        child: Text(localizations.translate('update') ?? 'Update'),
                      ),
                      ElevatedButton(
                        onPressed: deleteCustomer,
                        child: Text(localizations.translate('delete') ?? 'Delete'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                    if (!isEditing)
                      ElevatedButton(
                        onPressed: submitCustomer,
                        child: Text(localizations.translate('submit') ?? 'Submit'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Submits the customer form and adds a new customer to the provider.
  ///
  /// This method validates the form, saves the form data, creates a new [Customer] object
  void submitCustomer() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final newCustomer = Customer(
        firstName: firstName,
        lastName: lastName,
        address: address,
        birthday: birthday,
      );
      await Provider.of<CustomerProvider>(context, listen: false).addCustomer(newCustomer);
      await saveCustomerData(newCustomer);
      Navigator.of(context).pop();
    }
  }

  /// Updates an existing customer in the provider.
  ///
  /// This method validates the form, saves the form data, updates the [Customer] object.
  void updateCustomer() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final updatedCustomer = Customer(
        id: widget.customer!.id,
        firstName: firstName,
        lastName: lastName,
        address: address,
        birthday: birthday,
      );
      await Provider.of<CustomerProvider>(context, listen: false).updateCustomer(updatedCustomer);
      await saveCustomerData(updatedCustomer);
      Navigator.of(context).pop();
    }
  }
  /// Deletes the customer from the provider.
  void deleteCustomer() async {
    await Provider.of<CustomerProvider>(context, listen: false).deleteCustomer(widget.customer!.id!);
    Navigator.of(context).pop();
  }
}
