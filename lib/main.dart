import 'package:airplane_list/screens/reservation_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/localization_delegate.dart';
import 'providers/airplane_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/flight_provider.dart';  // Import the FlightProvider
import 'providers/locale_provider.dart';  // Import the LocaleProvider
import 'providers/reservation_provider.dart';
import 'screens/airplane_list_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/flight_list_screen.dart';  // Import the FlightListScreen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AirplaneProvider()..loadAirplanes()),
        ChangeNotifierProvider(create: (context) => CustomerProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => FlightProvider()),
        ChangeNotifierProvider(create: (context) => ReservationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Main Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: localeProvider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('mainMenu') ?? 'Main Menu'),
        actions: [
          buildLanguageDropdown(context),
          buildInfoButton(context, AppLocalizations.of(context)!),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AirplaneListScreen()),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToAirplaneApp') ?? 'Go to Airplane App'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerListScreen()),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToCustomerApp') ?? 'Go to Customer App'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlightListScreen()),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('goToFlightListApp') ?? 'Go to Flight List App'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationListScreen()),
                );
              },
              child: Text(AppLocalizations.of(context)?.translate('gotoReservationApp') ?? 'Go to Reservation App'),
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton<Locale> buildLanguageDropdown(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return DropdownButton<Locale>(
      value: localeProvider.locale,
      icon: Icon(Icons.language, color: Colors.white),
      items: L10n.all.map((locale) {
        final flag = L10n.getFlag(locale.languageCode);
        return DropdownMenuItem(
          child: Center(child: Text(flag, style: TextStyle(fontSize: 24))),
          value: locale,
          onTap: () {
            localeProvider.setLocale(locale);
          },
        );
      }).toList(),
      onChanged: (_) {},
    );
  }

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
                Text(localizations.translate('appInstruction1')!),
                SizedBox(height: 8),
                Text(localizations.translate('appInstruction2')!),
                SizedBox(height: 8),
                Text(localizations.translate('appInstruction3')!),
                SizedBox(height: 8),
                Text(localizations.translate('appInstruction4')!),
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
}
