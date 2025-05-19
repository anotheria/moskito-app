import 'package:flutter/material.dart';
import 'package:moskito_control/screens/main_screen.dart';
import 'package:uni_links/uni_links.dart';
import '../main.dart' show initialLinkUri;
import 'screens/main_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    if (initialLinkUri != null &&
        initialLinkUri!.scheme == 'moskitoapp' &&
        initialLinkUri!.host == 'config') {
      final url = initialLinkUri!.queryParameters['url'];
      final name = initialLinkUri!.queryParameters['name'];
      print('Starte Konfiguration: $url, $name');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mainScreenKey.currentState?.openSettingsAndConfigure(name!, url!);
      });
    }

    uriLinkStream.listen((Uri? uri) {
      String uriString = uri.toString();
      print("Click: "+uriString );
      if (uri != null && uri.scheme == 'moskitoapp' && uri.host == 'config') {
        print("In the IF");
        final url = uri.queryParameters['url'];
        final name = uri.queryParameters['name'];
        print('Live-Link empfangen: $url, $name');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          mainScreenKey.currentState?.openSettingsAndConfigure(name!, url!);
        });
      }
    });
  }

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
        bodyMedium: TextStyle(color: Colors.white, fontFamily: 'PTMono', fontSize: 12), // Ersetzt bodyText2
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
      debugShowCheckedModeBanner: false,
      title: 'MoSKito',
      /*theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),*/
      theme: appTheme,
      navigatorKey: navigatorKey,
      home: MainScreen(key: mainScreenKey),
    );
  }
}