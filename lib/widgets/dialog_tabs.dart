import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/history_item.dart';
import '../models/component_info.dart';
import '../models/threshold.dart';
import '../models/accumulator.dart';
import '../utils/utils.dart';
import 'chart_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart'; // Für Clipboard

class DialogTabs extends StatefulWidget {
  final String componentName;

  const DialogTabs({super.key, required this.componentName});

  @override
  State<DialogTabs> createState() => _DialogTabsState();
}

class _DialogTabsState extends State<DialogTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MoSKitoThreshold> thresholds = [];
  List<MoSKitoAccumulator> accumulators = [];
  List<HistoryItem> historyItems = [];
  ComponentInfo? componentInfo;
  ComponentInfo? connectorInfo;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    //TODO actually we should check for capabilities of the component here first.

    _tabController = TabController(length: 4, vsync: this);


    // Add a listener to detect tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) { // Only fetch data when the tab settles
        fetchDataForTab(_tabController.index);
      }
    });

    // Fetch data for the initial tab
    fetchDataForTab(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDataForTab(int tabIndex) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (tabIndex == 0) { // Thresholds tab
        final data = await ApiService.fetchThresholds(widget.componentName);
        setState(() {
          thresholds = data;
        });
      } else if (tabIndex == 1) { // Accumulators tab
        final data = await ApiService.fetchAccumulators(widget.componentName);
        setState(() {
          accumulators = data;
        });
      } else if (tabIndex == 3) { // History tab
        final data = await ApiService.fetchHistory(widget.componentName);
        setState(() {
          historyItems = data;
        });
      }else if (tabIndex == 2) { // Info tab
        final fetchedComponentInfo = await ApiService.fetchComponentInfo(widget.componentName);
        final fetchedConnectorInfo = await ApiService.fetchConnectorInfo(widget.componentName);
        setState(() {
          componentInfo = fetchedComponentInfo;
          connectorInfo = fetchedConnectorInfo;
        });
      }
    } catch (e) {
      print('Error fetching data for tab $tabIndex: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return
        Dialog(
            shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),

      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Component Name with Background
          Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFF6C9FD7), // Hintergrundfarbe
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              widget.componentName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Textfarbe
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: FaIcon(FontAwesomeIcons.circleDot)), // Thresholds
              Tab(icon: FaIcon(FontAwesomeIcons.chartLine)), // Accumulators
              Tab(icon: FaIcon(FontAwesomeIcons.circleInfo)), // Info
              Tab(icon: FaIcon(FontAwesomeIcons.clockRotateLeft)), // History
             ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThresholdsTab(),
                _buildAccumulatorsTab(),
                _buildInfoTab(), // Info
                _buildHistoryTab(), // History
              ],
            ),
          ),
        ],
      ),
    )
    ;
  }

  Widget _buildThresholdsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
        padding: const EdgeInsets.all(2.0),
    child: SingleChildScrollView(
      child: DataTable(
        showCheckboxColumn: false,
          columnSpacing: 0,

        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Value')),
        ],
        rows: thresholds.map((threshold) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [

                Container(
                  width: 12, // Size of the circle
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppUtils.parseColor(threshold.status),
                    shape: BoxShape.circle, // Make it circular
                  ),

                ),
                  Text(' '+threshold.name,
                    overflow: TextOverflow.ellipsis, // Hier anwenden, um den Text abzuschneiden
                  )
                  ]
                ),
              ),

              DataCell(Text(threshold.lastValue)),
            ],
            onSelectChanged: (selected) {
              if (selected ?? false) {
                _showThresholdDetailsDialog(threshold);
              }
            },
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildAccumulatorsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (accumulators.isEmpty) {
      return const Center(
        child: Text('No accumulators available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [

          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child:
                      Text('Chart name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )
                )
              ]), // Nur eine Spalte für den Namen
         ...accumulators.map((accumulator) {
          return
                GestureDetector(
                child:
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(accumulator.name,
                        style: TextStyle(overflow: TextOverflow.ellipsis),
                      ),

                    ],
                  ),
                ),

                  onTap: () async {
                    try {
                      final chartDataSource = await ApiService.fetchChart(widget.componentName, accumulator.name);
                      final chartData = chartDataSource.map<FlSpot>((point) {
                        final timestamp = point.timestamp ?? 0; // Standardwert für Null
                        final value = point.value != null ?
                            point.value == 'NaN' ? 0.0 : double.parse(point.value)
                            : 0.0;
                        return FlSpot(timestamp.toDouble(), value);
                      }).toList();
                      if (mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ChartDialog(
                                title: accumulator.name,
                                chartData: chartData,
                              ),
                          ),
                        );
                      }else{
                        print('Widget is not mounted. Cannot open dialog.');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
                        SnackBar(content: Text('Failed to load chart: $e')),
                      );

                    }

                },
              );


        }).toList(),
        ]),
    );
  }

  Widget _buildHistoryTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child:
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          )
                      ]),
            ),
          ...historyItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(item.isoTimestamp), // Display the timestamp
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppUtils.parseColor(item.oldStatus), // Map the old status to a color
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(Icons.arrow_forward), // Arrow icon
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppUtils.parseColor(item.newStatus), // Map the new status to a color
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ]),
    );
  }

  void _showThresholdDetailsDialog(MoSKitoThreshold threshold) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(threshold.name, textAlign: TextAlign.left),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', threshold.status),
              _buildDetailRow('Last Value', threshold.lastValue),
              _buildDetailRow('Timestamp', threshold.statusChangeTimestamp),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInfoTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (componentInfo == null || connectorInfo == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Component Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoSection(componentInfo!.data),

            const SizedBox(height: 16),
            const Text(
              'Connector Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoSection(connectorInfo!.data),
            const SizedBox(height: 16),
            const Text(
              'Tap a value to copy it to the clipboard.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return GestureDetector(
            onTap: () {
          Clipboard.setData(ClipboardData(text: '${entry.value}'));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied "${entry.key}: ${entry.value}" to clipboard')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(entry.value.toString(),
                  overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ));
      }).toList(),
    );
  }


}