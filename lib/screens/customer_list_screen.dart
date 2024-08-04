import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import 'customer_form_screen.dart';
import '../models/customer.dart';
import '../l10n/app_localizations.dart';

class CustomerListScreen extends StatefulWidget {
  @override
  CustomerListScreenState createState() => CustomerListScreenState();
}

class CustomerListScreenState extends State<CustomerListScreen> {
  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<CustomerProvider>(context, listen: false).loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('customers')!),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return buildBody(context, orientation, localizations);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomerFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildBody(BuildContext context, Orientation orientation, AppLocalizations localizations) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.customers.isEmpty) {
          return Center(child: Text(localizations.translate('noItemsAvailable')!));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600 || orientation == Orientation.landscape) {
                return buildTabletLayout(customerProvider, localizations);
              } else {
                return buildMobileLayout(customerProvider, localizations);
              }
            },
          );
        }
      },
    );
  }

  Widget buildTabletLayout(CustomerProvider customerProvider, AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: customerProvider.customers.length,
            itemBuilder: (context, index) {
              final customer = customerProvider.customers[index];
              return ListTile(
                title: Text('${customer.firstName} ${customer.lastName}'),
                subtitle: Text(localizations.translate('address')! + ': ' + customer.address),
                onTap: () {
                  setState(() {
                    selectedCustomer = customer;
                  });
                },
              );
            },
          ),
        ),
        if (selectedCustomer != null)
          Expanded(
            child: CustomerDetail(customer: selectedCustomer!),
          ),
      ],
    );
  }

  Widget buildMobileLayout(CustomerProvider customerProvider, AppLocalizations localizations) {
    return ListView.builder(
      itemCount: customerProvider.customers.length,
      itemBuilder: (context, index) {
        final customer = customerProvider.customers[index];
        return ListTile(
          title: Text('${customer.firstName} ${customer.lastName}'),
          subtitle: Text(localizations.translate('address')! + ': ' + customer.address),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerFormScreen(customer: customer),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomerDetail extends StatelessWidget {
  final Customer customer;

  const CustomerDetail({required this.customer});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${customer.firstName} ${customer.lastName}', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 8.0),
            Text(localizations.translate('address')! + ': ' + customer.address),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerFormScreen(customer: customer),
                  ),
                );
              },
              child: Text(localizations.translate('edit')!),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
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

                if (confirm == true) {
                  await Provider.of<CustomerProvider>(context, listen: false).deleteCustomer(customer.id!);
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizations.translate('delete') ?? 'Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
