import 'package:flutter/material.dart';
import 'package:moskito_control/models/history_item.dart';
import 'package:moskito_control/utils/utils.dart';

class HistoryWidget extends StatelessWidget {
  final List<HistoryItem> data;

  const HistoryWidget({super.key, required this.data});


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
                      AppUtils.getSmallStatusCircle(item.oldStatus),
                      const SizedBox(width: 8),
                      AppUtils.getSmallRightArrow(),
                      const SizedBox(width: 8),
                      AppUtils.getSmallStatusCircle(item.newStatus),
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
          title: Text("${item.componentName} status change"),
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