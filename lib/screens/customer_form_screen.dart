import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import 'package:intl/intl.dart'; // For formatting the date

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  CustomerFormScreen({this.customer});

  @override
  _CustomerFormScreenState createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String firstName;
  late String lastName;
  late String address;
  late DateTime birthday;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _birthdayController;

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
      _promptUsePreviousData();
    }
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _addressController = TextEditingController(text: address);
    _birthdayController = TextEditingController(text: DateFormat.yMd().format(birthday));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _promptUsePreviousData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('firstName')) {
      bool useData = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Use previous customer data?'),
          content: Text('Do you want to reuse the data of the last customer you entered?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
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
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
          _addressController.text = address;
          _birthdayController.text = DateFormat.yMd().format(birthday);
        });
      }
    }
  }

  Future<void> _saveCustomerData(Customer customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', customer.firstName);
    await prefs.setString('lastName', customer.lastName);
    await prefs.setString('address', customer.address);
    await prefs.setString('birthday', customer.birthday.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a first name' : null,
                onSaved: (value) => firstName = value!,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a last name' : null,
                onSaved: (value) => lastName = value!,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
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
                      _birthdayController.text = DateFormat.yMd().format(birthday);
                    });
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _birthdayController,
                    decoration: InputDecoration(
                      labelText: 'Birthday',
                      hintText: DateFormat.yMd().format(birthday),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a birthday' : null,
                    onSaved: (value) => birthday = DateFormat.yMd().parse(_birthdayController.text),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (isEditing) ...[
                    ElevatedButton(
                      onPressed: _updateCustomer,
                      child: Text('Update'),
                    ),
                    ElevatedButton(
                      onPressed: _deleteCustomer,
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                  if (!isEditing)
                    ElevatedButton(
                      onPressed: _submitCustomer,
                      child: Text('Submit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitCustomer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newCustomer = Customer(
        firstName: firstName,
        lastName: lastName,
        address: address,
        birthday: birthday,
      );
      await Provider.of<CustomerProvider>(context, listen: false).addCustomer(newCustomer);
      await _saveCustomerData(newCustomer);
      Navigator.of(context).pop();
    }
  }

  void _updateCustomer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedCustomer = Customer(
        id: widget.customer!.id,
        firstName: firstName,
        lastName: lastName,
        address: address,
        birthday: birthday,
      );
      await Provider.of<CustomerProvider>(context, listen: false).updateCustomer(updatedCustomer);
      await _saveCustomerData(updatedCustomer);
      Navigator.of(context).pop();
    }
  }

  void _deleteCustomer() async {
    await Provider.of<CustomerProvider>(context, listen: false).deleteCustomer(widget.customer!.id!);
    Navigator.of(context).pop();
  }
}
