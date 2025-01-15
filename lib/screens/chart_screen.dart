import 'package:flutter/material.dart';
import 'package:moskito_control/models/chart_point.dart';
import 'package:moskito_control/screens/base_page.dart';
import 'dart:async';
import 'package:moskito_control/services/api_service.dart';
import 'package:moskito_control/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/view.dart';
import '../states/view_state.dart';
import 'package:moskito_control/main.dart';
import '../widgets/chart_widget.dart';

class ChartScreen extends BasePage {
  const ChartScreen({Key? key})
      : super(
    key: key,
    helpFilePath: 'assets/help/charts.html',
    appBarTitle: 'Charts',
  );

  @override
  BasePageState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends BasePageState<ChartScreen> {
  List<MultiChart> charts = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh(); // Start the timer
  }//initState

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData(); // Load data.
  }

  @override
  void dispose() {
    _timer?.cancel(); // Remove timer when closed.
    super.dispose();
  }

  Future<void> fetchData() async {
    final viewItemState = Provider.of<ViewItemState>(context, listen: false);
    String selectedItemName = viewItemState.getSelectedViewName();

    final _charts = await ApiService.fetchChartsForView(selectedItemName);

    setState(() {
      charts = _charts ?? [];
      isLoading = false;
    });
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchData(); // Refresh data every 60 seconds
    });
  }

  @override
  Widget buildPageContent(BuildContext context) {
    final viewItemState = Provider.of<ViewItemState>(context, listen: false);

    return Column(
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
                }),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                Text(
                                  charts[index].name,
                                  style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                  IconButton(
                                    icon:  const Icon(Icons.info_outline, color: Colors.white),
                                    onPressed: () {
                                      _showInfoDialog(context, charts[index]);
                                    },
                                  ),

                                ],
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
      );
  }//buildPageContent


  void _showInfoDialog(BuildContext context, MultiChart chart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(chart.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(chart.lineNames.length, (index) {
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppUtils.getChartColor(index),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chart.lineNames[index],
                      style: const TextStyle( overflow: TextOverflow.ellipsis),
                      maxLines: 1, // Nur eine Zeile anzeigen
                    ),
                  ),

                ],
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }//_showInfoDialog
}//_ChartScreenState