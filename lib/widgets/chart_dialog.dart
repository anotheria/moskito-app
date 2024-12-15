import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moskito_control/widgets/chart_dialog.dart';



class ChartDialog extends StatelessWidget {
  final String title;
  final List<FlSpot> chartData;

  const ChartDialog({
    super.key,
    required this.title,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {

    double xInterval = calculateDynamicInterval(chartData);
    double yInterval = calculateVerticalInterval(chartData);

    return Dialog(
      child: SafeArea(
       child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Check if data is available
            if (chartData.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No data available for this chart',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Flexible(
              child:
              LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval, // Dynamisches Y-Intervall
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            formatYAxisLabel(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false, // Obere Beschriftungen deaktivieren
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false, // Rechte Beschriftungen deaktivieren
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: yInterval, // Dynamisches Y-Intervall
                    verticalInterval: xInterval, // Dynamisches X-Intervall
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),

            ),
            // Close Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ));
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
    double interval = timeRange * 0.25;

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
    double interval = range * 0.25;

    // Auf einen sinnvollen Wert runden (z. B. nächste 10 Einheiten)
    return (interval / 10).ceil() * 10; // Runden auf 10er-Schritte
  }
}