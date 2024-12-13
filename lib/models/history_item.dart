class HistoryItem {
  final String isoTimestamp;
  final String oldStatus;
  final String newStatus;

  HistoryItem({
    required this.isoTimestamp,
    required this.oldStatus,
    required this.newStatus,
  });

  // Factory method to create a HistoryItem instance from JSON
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      isoTimestamp: json['isoTimestamp'] as String,
      oldStatus: json['oldStatus'] as String,
      newStatus: json['newStatus'] as String,
    );
  }
}