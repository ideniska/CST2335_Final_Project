import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import 'customer_form_screen.dart';
import '../models/customer.dart';
import '../l10n/app_localizations.dart';

/// A screen that displays a list of customers.
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
        actions: [
          buildInfoButton(context, localizations),
        ],
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

  /// Builds the body of the screen based on the orientation.
  ///
  /// [context] is the build context.
  /// [orientation] is the current orientation of the device.
  /// [localizations] provides localized strings for the app.
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


  /// Builds the layout for tablets and landscape orientation.
  ///
  /// [customerProvider] provides the list of customers.
  /// [localizations] provides localized strings for the app.
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

  /// Builds an info button that shows a dialog with instructions when pressed.
  IconButton buildInfoButton(BuildContext context, AppLocalizations localizations) {
    return IconButton(
      icon: Icon(Icons.info),
      onPressed: () {
        // Show a dialog with instructions
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.translate('instructions')!),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.translate('customerFormInstruction1')!),
                SizedBox(height: 8),
                Text(localizations.translate('customerFormInstruction2')!),
                SizedBox(height: 8),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localizations.translate('ok')!),
              ),
            ],
          ),
        );
      },
    );
  }


  /// Builds the layout for mobile devices and portrait orientation.
  ///
  /// [customerProvider] provides the list of customers.
  /// [localizations] provides localized strings for the app.
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


/// A widget that displays the details of a selected customer.
class CustomerDetail extends StatelessWidget {
  /// The customer whose details are to be displayed.
  final Customer customer;

  /// Creates a [CustomerDetail] widget.
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
