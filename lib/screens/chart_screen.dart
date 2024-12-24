import 'package:flutter/material.dart';
import 'package:moskito_control/models/chart_point.dart';
import 'package:moskito_control/widgets/history_widget.dart';
import 'dart:async';
import 'package:moskito_control/services/api_service.dart';
import 'package:moskito_control/models/history_item.dart';
import 'package:provider/provider.dart';

import '../models/view.dart';
import '../states/view_state.dart';
import 'package:moskito_control/main.dart';
import '../widgets/chart_widget.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<MultiChart> charts = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh(); // Starte den Timer
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData(); // Daten laden, wenn Abhängigkeiten verfügbar sind
  }

  @override
  void dispose() {
    _timer?.cancel(); // Beende den Timer beim Verlassen des Widgets
    super.dispose();
  }

  Future<void> fetchData() async {
    final viewItemState = Provider.of<ViewItemState>(context, listen: false);
    String selectedItemName = viewItemState.getSelectedViewName();

    final _charts = await ApiService.fetchChartsForView(selectedItemName);
    print("Loaded charts: $_charts");

    setState(() {
      charts = _charts ?? [];
      isLoading = false;
    });
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchData(); // Aktualisiere die Daten alle 60 Sekunden
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewItemState = Provider.of<ViewItemState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF6C9FD7),
          title: ValueListenableBuilder<String>(
            valueListenable: selectedSystemNameGlobal,
            builder: (context, value, child) {
              return Text('$value :: Charts'); // Zeigt den aktuellen Systemnamen
            },
          )

      ),
      body: Column(
        children: [
          // Dropdown for selecting a view
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<ViewItem>(
              isExpanded: true,
              value: viewItemState.selectedViewItem != null &&
                  viewItemState.viewItems.contains(viewItemState.selectedViewItem)
                  ? viewItemState.selectedViewItem
                  : ViewItem(name: "ALL"),
              items: [
                DropdownMenuItem<ViewItem>(
                  value: ViewItem(name: "ALL"),
                  child: const Text("ALL"),
                ),
                ...viewItemState.viewItems.map((viewItem) {
                  return DropdownMenuItem<ViewItem>(
                    value: viewItem,
                    child: Text(viewItem.name),
                  );
                }).toList(),
              ],
              onChanged: (ViewItem? newValue) {
                if (newValue != null) {
                  setState(() {
                    isLoading = true;
                  });
                  if (newValue.name == "ALL") {
                    viewItemState.selectViewItem(new ViewItem(name: 'ALL')); // Set "ALL"
                    fetchData(); // Reload global data
                  } else {
                    viewItemState.selectViewItem(newValue);
                    fetchData(); // Reload data for selected view
                  }
                }
              },
            ),
          ),
          // History list or loading indicator
          Expanded(
            child: isLoading
             ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: charts.length,
                itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                  charts[index].name,
                                  style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 300,
                                  child: MultiChartWidget(chart: charts[index]),
                                ),
                            ],
                        ),
                    );
                },
            ),
    )],
      ),
    );
  }
}