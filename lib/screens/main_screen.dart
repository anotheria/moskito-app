import 'package:flutter/material.dart';
import 'home_screen.dart'; // Dein Home Screen
import 'history_screen.dart'; // Dein History Screen
import 'chart_screen.dart'; // Der Dummy-Screen
import 'settings.dart'; // Der Dummy-Screen

class MainScreen extends StatefulWidget {
  final void Function(BuildContext settingsContext)? initialSettingsEdit;

  MainScreen({Key? key, this.initialSettingsEdit}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  BuildContext? _settingsContext;
  int _selectedIndex = 0;
  SettingsScreenState? settingsState;

  List<Widget> get _screens => [
    HomeScreen(),
    HistoryScreen(),
    ChartScreen(),
    Builder(
      builder: (context) {
        _settingsContext = context;
        // Führe initialSettingsEdit beim erstmaligen Aufbau von SettingsScreen aus
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedIndex == 3 && widget.initialSettingsEdit != null) {
            widget.initialSettingsEdit!(context);
          }
        });
        return SettingsScreen();
      },
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.yellow,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  void openSettingsAndConfigure(String name, String url) {
    setState(() {
      _selectedIndex = 3; // Settings-Tab aktivieren
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = settingsState;
      if (state != null) {
        state.showAddSystemFromDeepLink(name, url);
      } else {
        print("SettingsScreenState nicht gefunden.");
      }
    });
  }
}