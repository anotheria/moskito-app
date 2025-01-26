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
              color: AppUtils.getAppBarColor(), //Color(0xFF6C9FD7),
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

    return

      Padding(
        padding: const EdgeInsets.all(2.0),
    child: SingleChildScrollView(
      child: Column(
        children: [
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child:
                    Text('Thresholds',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                )
              ]), // Nur eine Spalte für den Namen
          Align(
            alignment: Alignment.centerLeft,
            child:
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.start,
            children: thresholds.map((threshold) {
              final componentColor = AppUtils.parseColor(threshold.status);

              return
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0), // Subtle padding for balance
                  child:
                    GestureDetector(

                onTap: () {
                  _showThresholdDetailsDialog(threshold);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, color: componentColor, size: 8),
                    const SizedBox(width: 4),
                    Text(
                      "${threshold.name} (${threshold.lastValue})",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                    )
                );
            }).toList(),
          ),)
  ])
    )
    )
    ;
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
                      Text('Charts',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )
                )
              ]), // Nur eine Spalte für den Namen
         ...accumulators.map((accumulator) {
          return
                GestureDetector(
                child:
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          accumulator.name,
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                          maxLines: 1, // Nur eine Zeile anzeigen
                        ),
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
                              fullscreenDialog: true,
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
            child: GestureDetector(
                    onTap: () {
                      _showHistoryDetailsDialog(item);
                    },
                child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                AppUtils.getSmallStatusCircle(item.oldStatus),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: AppUtils.smallCircleBoxSize,), // Arrow icon
                const SizedBox(width: 4),
                AppUtils.getSmallStatusCircle(item.newStatus),
                const SizedBox(width: AppUtils.circleBoxSize), // Space between status circles
                Text(item.isoTimestamp), // Display the timestamp

              ],
            ),
          )
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
              _buildDetailRowWithWidget('Status', AppUtils.getStatusCircle(threshold.status)),
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

  void _showHistoryDetailsDialog(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.componentName, textAlign: TextAlign.left),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      AppUtils.getSmallStatusCircle(item.oldStatus),
                      const SizedBox(width: AppUtils.circleBoxSize-1),
                      AppUtils.getSmallRightArrow(),
                      const SizedBox(width: AppUtils.circleBoxSize-1),
                      AppUtils.getSmallStatusCircle(item.newStatus),
                    ],
                  )),
              Padding(padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text("Old Messages: ${item.oldMessages.join(", ")}"),),
              Padding(padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text("New Messages: ${item.newMessages.join(", ")}"),),
              Padding(padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text("Timestamp: ${item.isoTimestamp}"),)
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

  Widget _buildDetailRowWithWidget(String label, Widget widget) {
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
            child: widget
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Component Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoSection(componentInfo!.data),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Connector Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
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
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow,),

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