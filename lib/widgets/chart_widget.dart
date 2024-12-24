import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_point.dart';

class MultiChartWidget extends StatelessWidget {
  final MultiChart chart;


  const MultiChartWidget({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(                    sideTitles: SideTitles(
            showTitles: true,
            //interval: xInterval, // 5 Minuten in Millisekunden
            getTitlesWidget: (value, meta) {
              return Text(
                formatXAxisLabel(value),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              //interval: xInterval, // 5 Minuten in Millisekunden
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
      ),
    );
  }

  List<LineChartBarData> _buildLineChartBars(MultiChart chart) {
    // Assuming chart.points.values is a list of strings representing numbers
    final int numLines = chart.points.first.values.length;
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
    //double xInterval = calculateDynamicInterval(chart);
    //double yInterval = calculateVerticalInterval(chart);

    return List.generate(numLines, (lineIndex) {
      return LineChartBarData(
        spots: chart.points
            .asMap()
            .entries
            .map(
              (entry) => FlSpot(
            entry.key.toDouble(), // Index of the point
            double.tryParse(entry.value.values[lineIndex]) ?? 0.0,
          ),
        )
            .toList(),
        isCurved: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: colors[lineIndex % colors.length],
        //colors: [Colors.blue], // Customize colors as needed
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

    if (value >= 1000000000) {
      ret_value =  value / 1000000000;
      ret_string = 'G';
    }else if (value >= 1000000) {
      ret_value =  value / 1000000;
      ret_string = 'M';
    } else if (value >= 1000) {
      ret_value =  value / 1000;
      ret_string = 'k';
    }else{
      ret_value = value;
    }
    if (ret_value>100) {
      return ret_value.toStringAsFixed(0)+'$ret_string';
    }
    if (ret_value>1) {
      return ret_value.toStringAsFixed(1)+'$ret_string';
    }
    return ret_value.toStringAsFixed(3)+'$ret_string';
  }

  double calculateDynamicInterval(List<FlSpot> chartData) {
    if (chartData.isEmpty) {
      return 1; // Default-Wert, falls keine Daten vorhanden sind
    }

    // Min- und Max-Timestamps ermitteln
    double minTimestamp = chartData.first.x;
    double maxTimestamp = chartData.last.x;

    // Zeitbereich berechnen
    double timeRange = maxTimestamp - minTimestamp;

    if (timeRange == 0) {
      return 1; // Default-Wert, falls nur ein Datenpunkt vorhanden ist
    }

    // Intervall als 25% des Zeitbereichs
    double interval = timeRange * 0.40;

    // Intervall auf sinnvollen Wert runden (z. B. nächste 5 Minuten)
    double roundedInterval = interval / (60 * 1000); // In Minuten
    return (roundedInterval.round() * 60 * 1000).toDouble(); // Zurück in Millisekunden
  }

  double calculateVerticalInterval(List<FlSpot> chartData) {
    if (chartData.isEmpty) {
      return 1; // Default-Wert, falls keine Daten vorhanden sind
    }

    // Min- und Max-Y-Werte ermitteln
    double minY = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    // Bereich berechnen
    double range = maxY - minY;

    if (range == 0) {
      return 1; // Default-Wert, falls nur ein Datenpunkt vorhanden ist
    }

    // Intervall als 25% des Y-Bereichs
    double interval = range * 0.33;

    // Auf einen sinnvollen Wert runden (z. B. nächste 10 Einheiten)
    return (interval / 10).ceil() * 10; // Runden auf 10er-Schritte
  }


}