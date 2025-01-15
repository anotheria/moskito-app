import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'states/view_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


ValueNotifier<String> selectedSystemNameGlobal = ValueNotifier<String>("Default System");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initialize(); // URLs laden

  // Load saved System name.
  final prefs = await SharedPreferences.getInstance();
  final savedSystemName = prefs.getString('selectedSystemName') ?? "Default System";
  selectedSystemNameGlobal.value = savedSystemName;

  testAssetLoading();


  runApp(
    ChangeNotifierProvider(
      create: (_) => ViewItemState(),
      child: const MyApp(),
    ),
  );

}

void testAssetLoading() async {
  print("Loading asset...");
  try {
    String content = await rootBundle.loadString('assets/help/settings.html');

  } catch (e) {
    print('Error loading asset: $e');
  }
}
