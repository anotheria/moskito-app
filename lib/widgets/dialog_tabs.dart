import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_first_app/models/history_item.dart';
import '../models/component_info.dart';

class DialogTabs extends StatefulWidget {
  final String componentName;

  const DialogTabs({super.key, required this.componentName});

  @override
  State<DialogTabs> createState() => _DialogTabsState();
}

class _DialogTabsState extends State<DialogTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> thresholds = [];
  List<HistoryItem> historyItems = [];
  ComponentInfo? componentInfo;
  ComponentInfo? connectorInfo;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: FaIcon(FontAwesomeIcons.dotCircle)), // Thresholds
              Tab(icon: FaIcon(FontAwesomeIcons.chartLine)), // Accumulators
              Tab(icon: FaIcon(FontAwesomeIcons.infoCircle)), // Info
              Tab(icon: FaIcon(FontAwesomeIcons.history)), // History
             ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThresholdsTab(),
                Center(child: Text('Content for Tab 2')), // Accumulators
                _buildInfoTab(), // Info
                _buildHistoryTab(), // History
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Value')),
        ],
        rows: thresholds.map((threshold) {
          return DataRow(
            cells: [
              DataCell(Text(threshold['name'])),
              DataCell(
                Container(
                  width: 16, // Size of the circle
                  height: 16,
                  decoration: BoxDecoration(
                    color: _parseColor(threshold['status']), // Use your _parseColor function
                    shape: BoxShape.circle, // Make it circular
                  ),
                ),
              ),
              DataCell(Text(threshold['lastValue'])),
            ],
            onSelectChanged: (selected) {
            if (selected ?? false) {
              _showTimestampDialog(threshold['statusChangeTimestamp']);
            }
          },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: historyItems.map((item) {
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
                    color: _parseColor(item.oldStatus), // Map the old status to a color
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(Icons.arrow_forward), // Arrow icon
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _parseColor(item.newStatus), // Map the new status to a color
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showTimestampDialog(String timestamp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Status Change Timestamp'),
          content: Text(timestamp),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text(
                '${entry.key}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(entry.value.toString()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String colorString) {
    colorString = colorString.toLowerCase();
    switch (colorString) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}