import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../providers/flight_provider.dart';

class FlightFormScreen extends StatefulWidget {
  final Flight? flight;

  FlightFormScreen({this.flight});

  @override
  _FlightFormScreenState createState() => _FlightFormScreenState();
}

class _FlightFormScreenState extends State<FlightFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _flightData = {
    'departureCity': '',
    'destinationCity': '',
    'departureTime': '',
    'arrivalTime': ''
  };

  @override
  void initState() {
    if (widget.flight != null) {
      _flightData['departureCity'] = widget.flight!.departureCity;
      _flightData['destinationCity'] = widget.flight!.destinationCity;
      _flightData['departureTime'] = widget.flight!.departureTime;
      _flightData['arrivalTime'] = widget.flight!.arrivalTime;
    }
    super.initState();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final flight = Flight(
        id: widget.flight?.id,
        departureCity: _flightData['departureCity']!,
        destinationCity: _flightData['destinationCity']!,
        departureTime: _flightData['departureTime']!,
        arrivalTime: _flightData['arrivalTime']!,
      );
      if (widget.flight == null) {
        Provider.of<FlightProvider>(context, listen: false).addFlight(flight);
      } else {
        Provider.of<FlightProvider>(context, listen: false).updateFlight(flight);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flight == null ? 'Add Flight' : 'Edit Flight'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _flightData['departureCity'],
                decoration: InputDecoration(labelText: 'Departure City'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _flightData['departureCity'] = value!;
                },
              ),
              TextFormField(
                initialValue: _flightData['destinationCity'],
                decoration: InputDecoration(labelText: 'Destination City'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _flightData['destinationCity'] = value!;
                },
              ),
              TextFormField(
                initialValue: _flightData['departureTime'],
                decoration: InputDecoration(labelText: 'Departure Time'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _flightData['departureTime'] = value!;
                },
              ),
              TextFormField(
                initialValue: _flightData['arrivalTime'],
                decoration: InputDecoration(labelText: 'Arrival Time'),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a value.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _flightData['arrivalTime'] = value!;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
