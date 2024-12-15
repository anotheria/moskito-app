class ChartPoint {
  final String caption;
  final int timestamp;
  final String value;

  ChartPoint({required this.caption, required this.timestamp, required this.value});

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      caption: json['caption'] as String,
      timestamp: json['timestamp'] as int,
      value: (json['values'][0] as String),
    );
  }
}