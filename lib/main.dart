import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'states/view_state.dart';
import 'models/mute_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

ValueNotifier<String> selectedSystemNameGlobal = ValueNotifier<String>("Default System");
ValueNotifier<MuteStatus?> muteStatusGlobal = ValueNotifier<MuteStatus?>(null);

Uri? initialLinkUri;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ApiService.initialize(); // URLs laden

  // Load saved System name.
  final prefs = await SharedPreferences.getInstance();
  final savedSystemName = prefs.getString('selectedSystemName') ?? "Default System";
  selectedSystemNameGlobal.value = savedSystemName;

  try {
    initialLinkUri = await getInitialUri();
  } catch (e) {
    print('Fehler beim Laden des Initial-Links: $e');
  }


  runApp(
    ChangeNotifierProvider(
      create: (_) => ViewItemState(),
      child: const MyApp(),
    ),
  );



}
