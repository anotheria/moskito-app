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

class MultiChartPoint{
  final String caption;
  final int timestamp;
  final List<String> values;

  MultiChartPoint({required this.caption, required this.timestamp, required this.values});

  factory MultiChartPoint.fromJson(Map<String, dynamic> json) {
    return MultiChartPoint(
      caption: json['caption'] as String,
      timestamp: json['timestamp'] as int,
      values: (json['values'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  @override
  String toString() {
    return 'Point {caption: $caption, timestamp: $timestamp, values: $values}';
  }
}

class MultiChart{
  final String name;
  final List<MultiChartPoint> points;
  final List<String> lineNames;

  MultiChart({required this.name, required this.points, required this.lineNames});

  factory MultiChart.fromJson(Map<String, dynamic> json) {
    return MultiChart(
      name: json['name'] as String,
      points: (json['points'] as List<dynamic>).map((e) => MultiChartPoint.fromJson(e)).toList(),
      lineNames: (json['lineNames'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  @override
  String toString() {
    return 'MultiChart{name: $name, points: $points, lineNames: $lineNames}';
  }
}