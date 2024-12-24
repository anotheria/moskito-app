import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({Key? key}) : super(key: key);

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  final List<Map<String, String>> systems = [
    {"Name": "TCL", "URL": "https://moskito-control.thecasuallounge.com/api/v2"},
    {"Name": "SXT", "URL": "https://moskito-control.cherotic.com/api/v2"},
    {"Name": "FCT", "URL": "https://moskito-control.neueliebe.info/api/v2"},
    {"Name": "Sites", "URL": "https://moskito-control-websites.anotheria-services.net/api/v2"},
    {"Name": "BGS", "URL": "https://burgershop-control.demo.moskito.org/api/v2"},
  ];

  String? selectedSystemName;

  @override
  void initState() {
    super.initState();
    _loadSelectedSystem();
  }

  Future<void> _loadSelectedSystem() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSystemName = prefs.getString('selectedSystemName');
    });
  }

  Future<void> _saveSelectedSystem(String name, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSystemName', name);
    await prefs.setString('baseUrl', url);
    setState(() {
      selectedSystemName = name;
      selectedSystemNameGlobal.value = name;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6C9FD7),
        title: const Text("Select System"),
      ),
      body: ListView.builder(
        itemCount: systems.length,
        itemBuilder: (context, index) {
          final system = systems[index];
          return ListTile(
            title: Text(system['Name']!),
            trailing: selectedSystemName == system["Name"]
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              _saveSelectedSystem(system["Name"]!, system["URL"]!);
              Navigator.pop(context, system["URL"]);
            },
          );
        },
      ),
    );
  }
}