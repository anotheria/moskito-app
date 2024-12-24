import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'states/view_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<String> selectedSystemNameGlobal = ValueNotifier<String>("Default System");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initialize(); // URLs laden

  // Load saved System name.
  final prefs = await SharedPreferences.getInstance();
  final savedSystemName = prefs.getString('selectedSystemName') ?? "Default System";
  selectedSystemNameGlobal.value = savedSystemName;


  runApp(
    ChangeNotifierProvider(
      create: (_) => ViewItemState(),
      child: MyApp(),
    ),
  );
}

