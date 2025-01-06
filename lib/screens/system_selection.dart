import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/selectable_system_service.dart';
import '../models/selectable_system.dart';

class SystemSelectionPage extends StatefulWidget {
  const SystemSelectionPage({Key? key}) : super(key: key);

  @override
  State<SystemSelectionPage> createState() => _SystemSelectionPageState();
}

class _SystemSelectionPageState extends State<SystemSelectionPage> {
  final SelectableSystemService _service = SelectableSystemService();
  List<SelectableSystem> systems = [];
  String? selectedSystemName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedSystem();
    _fetchSystems();
  }

  Future<void> _loadSelectedSystem() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSystemName = prefs.getString('selectedSystemName');
    });
  }

  Future<void> _fetchSystems() async {
    setState(() {
      isLoading = true;
    });
    final loadedSystems = await _service.getSystems();
    setState(() {
      systems = loadedSystems;
      isLoading = false;
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
        backgroundColor: const Color(0xFF6C9FD7),
        title: const Text("Select System"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : systems.isEmpty
          ? const Center(child: Text("No systems available"))
          : ListView.builder(
        itemCount: systems.length,
        itemBuilder: (context, index) {
          final system = systems[index];
          return ListTile(
            title: Text(system.name),
            trailing: selectedSystemName == system.name
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              _saveSelectedSystem(system.name, system.url);
              Navigator.pop(context, system.url);
            },
          );
        },
      ),
    );
  }
}