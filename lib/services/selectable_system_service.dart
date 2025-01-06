import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/selectable_system.dart';

class SelectableSystemService {
  static const String _storageKey = 'selectable_systems';

  // Save the systems.
  Future<void> saveSystems(List<SelectableSystem> systems) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedSystems = systems.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, encodedSystems);
  }

  // Returns the systems.
  Future<List<SelectableSystem>> getSystems() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedSystems = prefs.getStringList(_storageKey) ?? [];
    return encodedSystems.map((e) => SelectableSystem.fromJson(jsonDecode(e))).toList();
  }

  // Adds a system.
  Future<void> addSystem(SelectableSystem system) async {
    final systems = await getSystems();
    systems.add(system);
    await saveSystems(systems);
  }

  // Removes a system by name.
  Future<void> removeSystem(String name) async {
    final systems = await getSystems();
    systems.removeWhere((system) => system.name == name);
    await saveSystems(systems);
  }
}

