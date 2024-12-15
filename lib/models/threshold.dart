class MoSKitoThreshold {
  final String name;
  final String status;
  final String lastValue;
  final String statusChangeTimestamp;

  MoSKitoThreshold({
    required this.name,
    required this.status,
    required this.lastValue,
    required this.statusChangeTimestamp
  });

  // Factory method to create a HistoryItem instance from JSON
  factory MoSKitoThreshold.fromJson(Map<String, dynamic> json) {
    return MoSKitoThreshold(
      name: json['name'] as String,
      status: json['status'] as String,
      lastValue: json['lastValue'] as String? ?? "none",
      statusChangeTimestamp: json['statusChangeTimestamp'] as String,
    );
  }
}