import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/reservation_provider.dart';
import 'screens/reservation_list_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ReservationProvider()),
      ],
      child: MaterialApp(
        title: 'Airplane Reservations',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ReservationListScreen(),
        localizationsDelegates: [
          // ... other delegates
          AppLocalizations.delegate, // Ensure this is included
        ],
        supportedLocales: [
          const Locale('en', ''), // Add other supported locales
        ],
      ),
    );
  }
}