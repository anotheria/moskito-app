import 'package:flutter/material.dart';
import 'package:moskito_control/screens/main_screen.dart';
import 'screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    ThemeData appTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.grey.shade800,
      scaffoldBackgroundColor: Colors.grey.shade900,
      dialogBackgroundColor: Colors.grey.shade800,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF6C9FD7),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'PTMono'),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.grey, fontFamily: 'PTMono',  fontSize: 14), // Ersetzt bodyText1
        bodyMedium: TextStyle(color: Colors.grey, fontFamily: 'PTMono', fontSize: 12), // Ersetzt bodyText2
        bodySmall: TextStyle(fontFamily: 'PTMono'),
        headlineSmall: TextStyle(color: Colors.white, fontFamily: 'PTMono'), // Ersetzt headline6
        titleLarge: TextStyle(fontFamily: 'PTMono'),
        titleMedium: TextStyle(fontFamily: 'PTMono'),
        titleSmall: TextStyle(fontFamily: 'PTMono'),
      ),
      iconTheme: IconThemeData(color: Colors.grey.shade300),
      cardColor: Colors.grey.shade800,
    );

    return MaterialApp(
      title: 'MoSKito',
      /*theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),*/
      theme: appTheme,
      home: MainScreen(),
    );
  }
}