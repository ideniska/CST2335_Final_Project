import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/customer.dart';

/// A provider class for managing customer data and notifying listeners of changes.
class CustomerProvider with ChangeNotifier {
  /// A list of [Customer] objects managed by this provider.
  List<Customer> customers = [];
  /// An instance of [DatabaseHelper] for database operations.
  final dbHelper = DatabaseHelper();


  /// Loads customers from the database and notifies listeners.
  Future<void> loadCustomers() async {
    customers = await dbHelper.getCustomers();
    notifyListeners();
  }

  /// Returns a list of customers from the database.
  Future<List<Customer>> listCustomers() async {
    return await DatabaseHelper().getCustomers();
    notifyListeners();
  }

  /// Adds a new [Customer] to the database and reloads the customer list.
  Future<void> addCustomer(Customer customer) async {
    await dbHelper.insertCustomer(customer);
    await loadCustomers();
  }

  /// Updates an existing [Customer] in the database and reloads the customer list.
  Future<void> updateCustomer(Customer customer) async {
    await dbHelper.updateCustomer(customer);
    await loadCustomers();
  }

  /// Deletes a [Customer] from the database and reloads the customer list.
  Future<void> deleteCustomer(int id) async {
    await dbHelper.deleteCustomer(id);
    await loadCustomers();
  }
  /// Retrieves a [Customer] by its [id] from the database.
  Future<Customer?> getCustomerById(int id) async {
    final customers = await dbHelper.getCustomers();
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }
}
