import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importa il file che contiene la HomeScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTEDx App',
      theme: ThemeData(
        // Imposta il tema scuro come base
        brightness: Brightness.dark,
        // Definisce i colori principali del tema
        primaryColor: Colors.black,
        hintColor: Colors.greenAccent[400],
        scaffoldBackgroundColor: Colors.black,

        // Imposta lo stile per AppBar e altri componenti comuni
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Stile generale per i testi
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
          headlineSmall: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.greenAccent, fontSize: 16),
        ),
        colorScheme: ColorScheme(
          primary: Colors.greenAccent[400]!,
          primaryContainer: Colors.green[900]!,
          secondary: const Color(0xFFEB0028), // Rosso per accenti
          secondaryContainer: const Color(0xFFEB0028),
          surface: Colors.grey[900]!,
          onSurface: Colors.white,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark,
          error: Colors.redAccent,
        ).copyWith(surface: Colors.black),
      ),
      home: const HomeScreen(), // Utilizza la HomeScreen come home dell'app
    );
  }
}
