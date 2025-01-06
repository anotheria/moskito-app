import 'package:flutter/material.dart';
import 'package:moskito_control/main.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/item_list.dart';
import '../models/view.dart';
import 'base_page.dart';
import 'system_selection.dart';
import 'dart:async';
import '../states/view_state.dart';

class MyHomePage extends BasePage {
  const MyHomePage({Key? key})
      : super(
    key: key,
    helpFilePath: 'assets/help/home.html',
    appBarTitle: 'Statuses',
  );

  @override
  BasePageState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends BasePageState<MyHomePage> {
  List<MoSKitoView> views = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _startAutoRefresh(); // Starte den Timer
  }

  @override
  void dispose() {
    _timer?.cancel(); // Beende den Timer beim Verlassen des Widgets
    super.dispose();
  }

  Future<void> fetchData() async {
    final List<MoSKitoView> _views = await ApiService.fetchViews();
    // Convert MoSKitoViews to ViewItems
    final List<ViewItem> viewItems = _views.map((view) => ViewItem(name: view.name)).toList();

    final viewItemState = Provider.of<ViewItemState>(context, listen: false);
    viewItemState.setViewItems(viewItems);

    setState(() {
      views = _views ?? [];
      isLoading = false;
    });
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchData(); // Aktualisiere die Daten alle 60 Sekunden
    });
  }

  @override
  Widget buildPageContent(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ItemList(data: views),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedSystemURL = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SystemSelectionPage()),
          );

          if (selectedSystemURL != null) {
            // Aktualisiere den ApiService
            ApiService.setBaseUrl(selectedSystemURL);
            fetchData(); // Daten neu laden
          }
        },
        backgroundColor: Color(0xFF6C9FD7),
        tooltip: 'Settings',
        child: const Icon(Icons.swap_horiz_outlined),
      ),
    );
  }
}