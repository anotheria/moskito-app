import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_point.dart';

class MultiChartWidget extends StatelessWidget {
  final MultiChart chart;

  final colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.grey,
    Colors.blueGrey,

  ];

   MultiChartWidget({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {

    double xInterval = calculateXInterval(chart);
    double yInterval = calculateVerticalInterval(chart);


    return
      LineChart(

      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 30,
              showTitles: true,
              interval: yInterval, // 5 Minuten in Millisekunden
              getTitlesWidget: (value, meta) {
                return Text(
                  formatYAxisLabel(value),
                  style: const TextStyle(fontSize: 10),
                );
            },
          ),
          ),

          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false, // Obere Beschriftungen deaktivieren
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false, // Rechte Beschriftungen deaktivieren
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: xInterval, // 5 Minuten in Millisekunden
              getTitlesWidget: (value, meta) {
                return Text(
                  formatXAxisLabel(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
        lineBarsData: _buildLineChartBars(chart),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipMargin: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  chart.lineNames[touchedSpot.barIndex] + ': ' + formatYAxisLabel(touchedSpot.y),
                   TextStyle(color: colors[touchedSpot.barIndex % colors.length],
                    fontWeight: FontWeight.bold,
                    //backgroundColor: Colors.grey, // Adjust tooltip background color here
                  ),
                );
              }).toList();
            },
          ),
        ),

      ),
    );

  }

  List<LineChartBarData> _buildLineChartBars(MultiChart chart) {
    // Assuming chart.points.values is a list of strings representing numbers
    final int numLines = chart.points.first.values.length;

    return List.generate(numLines, (lineIndex) {
      return LineChartBarData(
        spots: chart.points
            .map(
              (entry) => FlSpot(
            entry.timestamp.toDouble(), // Index of the point
            double.tryParse(entry.values[lineIndex]) ?? 0.0,
          ),
        )
            .toList(),
        isCurved: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: colors[lineIndex % colors.length],
        barWidth: 3,
      );
    });
  }

  // Formatierung der X-Achse (z. B. Timestamps in lesbare Zeitform)
  String formatXAxisLabel(double value) {
    final int timestamp = value.toInt();
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final String hour = dateTime.hour.toString().padLeft(2, '0'); // Stunden zweistellig
    final String minute = dateTime.minute.toString().padLeft(2, '0'); // Minuten zweistellig
    return '$hour:$minute';
  }

  // Formatierung der Y-Achse (z. B. große Werte kürzen)
  String formatYAxisLabel(double value) {
    double ret_value;
    String ret_string = '';

    if (value >= 1e9) {
      ret_value =  value / 1e9;
      ret_string = 'G';
    }else if (value >= 1e6) {
      ret_value =  value / 1e6;
      ret_string = 'M';
    } else if (value >= 1e3) {
      ret_value =  value / 1e3;
      ret_string = 'k';
    }else{
      ret_value = value;
    }

    if (ret_value>100) {
      return '${ret_value.toInt().toStringAsFixed(0)}$ret_string';
    }
    if (ret_value>1) {
      return '${ret_value % 1 == 0 ? ret_value.toInt().toString() : ret_value.toStringAsFixed(1)}$ret_string';
    }
    return '${ret_value.toStringAsFixed(3)}$ret_string';
  }

  double calculateXInterval(MultiChart chart) {
    if (chart.points.isEmpty) {
      return 1; // Default-Wert, falls keine Daten vorhanden sind
    }

    List<MultiChartPoint> chartData = chart.points;

    // Determine Min- und Max-Timestamps
    int minTimestamp = chartData.first.timestamp;
    int maxTimestamp = chartData.last.timestamp;

    // Timerange as difference between max and min timestamp
    int timeRange = maxTimestamp - minTimestamp;

    if (timeRange == 0) {
      return 1; // If there is no timerange
    }

    // Interval as %% of the whole x-axis
    double interval = timeRange * 0.40;
    return interval;
  }

  double calculateVerticalInterval(MultiChart chart) {
    if (chart.points.isEmpty) {
      return 1; // Default-Wert, falls keine Daten vorhanden sind
    }

    double minY = chart.points
        .expand((point) => point.values.map((value) => double.tryParse(value) ?? double.infinity))
        .reduce((a, b) => a < b ? a : b);

    double maxY = chart.points
        .expand((point) => point.values.map((value) => double.tryParse(value) ?? double.negativeInfinity))
        .reduce((a, b) => a > b ? a : b);

    // Bereich berechnen
    double range = maxY - minY;

    if (range == 0) {
      return 1; // Default-Wert, falls nur ein Datenpunkt vorhanden ist
    }

    // Intervall als 25% des Y-Bereichs
    double interval = range * 0.4;

    // Auf einen sinnvollen Wert runden (z. B. nächste 10 Einheiten)
    return (interval / 10).ceil() * 10; // Runden auf 10er-Schritte
  }


}