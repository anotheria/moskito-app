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
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.grey), // Ersetzt bodyText1
        bodyMedium: TextStyle(color: Colors.grey), // Ersetzt bodyText2
        headlineSmall: TextStyle(color: Colors.white), // Ersetzt headline6
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