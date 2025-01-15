class MoSKitoThreshold {
  final String name;
  final String status;
  String lastValue;
  final String statusChangeTimestamp;
  double? lastValueAsDouble;

  MoSKitoThreshold({
    required this.name,
    required this.status,
    required this.lastValue,
    required this.statusChangeTimestamp
  }){
    lastValueAsDouble = double.tryParse(lastValue) ?? 0.0;
    if (lastValueAsDouble != null && lastValueAsDouble!=0.0) {
      lastValue = lastValueAsDouble!.toStringAsFixed(2);
    }

  }

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