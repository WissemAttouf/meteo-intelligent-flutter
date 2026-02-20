// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // NOUVEAU: Pour initializeDateFormatting
import 'package:flutter_localizations/flutter_localizations.dart'; // NOUVEAU: Pour les délégués
import 'screens/home_screen.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized(); est implicite dans Flutter 3.0+ mais préférable si async.
  // FIX 2: Initialisation des données de localisation pour 'fr_FR' avant runApp
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo Simple',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      // FIX 2: Ajout des configurations de localisation
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'), // Locale par défaut en cas de besoin
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}