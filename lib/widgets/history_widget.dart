import 'package:flutter/material.dart';
import 'package:moskito_control/models/history_item.dart';

class HistoryWidget extends StatelessWidget {
  final List<HistoryItem> data;

  const HistoryWidget({super.key, required this.data});

  Color _parseColor(String colorString) {
    switch (colorString) {
      case 'RED':
        return Colors.red;
      case 'GREEN':
        return Colors.green;
      case 'ORANGE':
        return Colors.orange;
      case 'YELLOW':
        return Colors.yellow;
      case 'PURPLE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: data.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    _showInfoDialog(context, item);
                  },
                  child: Row(
                    children: [
                      Text(item.formatedTimestamp),
                      const SizedBox(width: 16),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(item.oldStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 12),
                      const SizedBox(width: 8),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(item.newStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(item.componentName),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${item.componentName} Status Change"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _parseColor(item.oldStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 16),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _parseColor(item.newStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Text("Old Messages: ${item.oldMessages.join(", ")}"),
              Text("New Messages: ${item.newMessages.join(", ")}"),
              Text("Timestamp: ${item.isoTimestamp}"),
            ],
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
  }
}