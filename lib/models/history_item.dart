import 'package:intl/intl.dart';

class HistoryItem {
  final String isoTimestamp;
  final String oldStatus;
  final String newStatus;
  final String componentName;
  final List<String> oldMessages;
  final List<String> newMessages;
  String formatedTimestamp = '';

  HistoryItem({
    required this.isoTimestamp,
    required this.oldStatus,
    required this.newStatus,
    required this.componentName,
    required this.oldMessages,
    required this.newMessages,
    required this.formatedTimestamp,

  });

  // Factory method to create a HistoryItem instance from JSON
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    String _isoTimestamp = json['isoTimestamp'] as String;
    return HistoryItem(
      isoTimestamp: _isoTimestamp,
      oldStatus: json['oldStatus'] as String,
      newStatus: json['newStatus'] as String,
      componentName: json['componentName'] as String,
      oldMessages: (json['oldMessages'] as List<dynamic>).map((e) => e as String).toList(),
      newMessages: (json['newMessages'] as List<dynamic>).map((e) => e as String).toList(),
      formatedTimestamp: formatIsoTimestamp(_isoTimestamp) ?? 'No timestamp',
    );
  }

  static String formatIsoTimestamp(String isoTimestamp) {
    // Konvertiere den ISO-Timestamp in ein DateTime-Objekt
    final DateTime dateTime = DateTime.parse(isoTimestamp);

    // Definiere das gewünschte Format
    final DateFormat formatter = DateFormat('dd.MM HH:mm:ss');

    // Formatiere das Datum
    return formatter.format(dateTime);
  }
}