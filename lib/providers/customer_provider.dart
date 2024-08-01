import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/customer.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> customers = [];
  final dbHelper = DatabaseHelper();

  Future<List<Customer>> getCustomers() async {
    return await DatabaseHelper().getCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await dbHelper.insertCustomer(customer);
    await getCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await dbHelper.updateCustomer(customer);
    await getCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await dbHelper.deleteCustomer(id);
    await getCustomers();
  }
}