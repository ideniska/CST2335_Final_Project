import 'package:airplane_list/providers/customer_provider.dart';
import 'package:airplane_list/screens/customer_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/localization_delegate.dart';
import 'providers/airplane_provider.dart';
import 'screens/airplane_list_screen.dart';


void main() {
  runApp(
    // Use MultiProvider to provide multiple ChangeNotifierProviders
    MultiProvider(
      providers: [
        // Provide AirplaneProvider for managing airplane data
        ChangeNotifierProvider(create: (context) => AirplaneProvider()),
        // Provide LocaleProvider for managing app locale
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        // Provide CustomerProvider for managing customer data
        ChangeNotifierProvider(create: (context) => CustomerProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// Define the root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current locale from the LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      // Set the title of the application
      title: 'Airplane List App',
      // Define the theme of the application
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set the locale of the application
      locale: localeProvider.locale,
      // Define the supported locales
      supportedLocales: L10n.all,
      // Define the localization delegates
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Set the home screen of the application
      home: CustomerListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}