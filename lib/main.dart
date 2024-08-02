import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/localization_delegate.dart';
import 'providers/airplane_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/flight_provider.dart';  // Import the FlightProvider
import 'providers/locale_provider.dart';  // Import the LocaleProvider
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
                // Placeholder button, you can add functionality here
              },
              child: Text(AppLocalizations.of(context)?.translate('placeholderButton')?.replaceFirst('{0}', '4') ?? 'Placeholder Button 4'),
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
}
