import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/customer.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> customers = [];
  final dbHelper = DatabaseHelper();

  Future<void> loadCustomers() async {
    customers = await dbHelper.getCustomers();
    notifyListeners();
  }

  Future<List<Customer>> listCustomers() async {
    return await DatabaseHelper().getCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await dbHelper.insertCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await dbHelper.updateCustomer(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await dbHelper.deleteCustomer(id);
    await loadCustomers();
  }
}
