import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/view.dart';
import '../models/history_item.dart';
import '../models/component_info.dart';
import '../models/threshold.dart';
import '../models/accumulator.dart';
import '../models/chart_point.dart';

class ApiService {
  //static const String _baseUrl = 'https://burgershop-control.demo.moskito.org/api/v2';

  static const _urlKey = 'baseUrl';

  static String baseUrl = 'https://moskito-control.thecasuallounge.com/api/v2'; //default


  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ?? baseUrl;
  }

  static Future<void> setBaseUrl(String newUrl) async {
    baseUrl = newUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, newUrl);
  }

  static Future<List<MultiChart>> fetchChartsForView(String viewName) async{
    final url = Uri.parse('$baseUrl/charts/points/$viewName');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final chartsList = data['charts'] as List<dynamic>;
      return chartsList.map((json) => MultiChart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load charts: ${response.statusCode}');
    }
  }


  static Future<List<HistoryItem>> fetchGlobalHistory() async {
    final url = Uri.parse('$baseUrl/history');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final historyList = data['results']['history'] as List<dynamic>;
      return historyList.map((json) => HistoryItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load history: ${response.statusCode}');
    }
  }

  static Future<List<HistoryItem>> fetchViewHistory(String viewName) async {
    final url = Uri.parse('$baseUrl/history/$viewName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final historyList = data['results']['history'] as List<dynamic>;
      return historyList.map((json) => HistoryItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load history: ${response.statusCode}');
    }
  }


  static Future<List<MoSKitoView>> fetchViews() async {
    final response = await http.get(Uri.parse('$baseUrl/control' ));

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final viewsJson = decodedJson['results']['views'] as List<dynamic>;
      return viewsJson.map((viewJson) => MoSKitoView.fromJson(viewJson)).toList();
    } else {
      throw Exception('Error getting the data: ${response.statusCode}');
    }
  }

  static Future<List<MoSKitoThreshold>> fetchThresholds(String componentName) async {
    final url = Uri.parse('$baseUrl/component/$componentName/thresholds');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final thresholdsList = decodedJson['results']['thresholds'] as List<dynamic>;
      return thresholdsList.map((json) => MoSKitoThreshold.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Abrufen der Daten: ${response.statusCode}');
    }
  }

  static Future<List<MoSKitoAccumulator>> fetchAccumulators(String componentName) async {
    final url = Uri.parse('$baseUrl/component/$componentName/accumulators');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accumulatorList = data['results']['accumulators'] as List<dynamic>;
      return accumulatorList.map((acc) => MoSKitoAccumulator.fromJson(acc as String)).toList();
    } else {
      throw Exception('Failed to load accumulators: ${response.statusCode}');
    }
  }

  static Future<List<HistoryItem>> fetchHistory(String componentName) async {
    final url = Uri.parse('$baseUrl/component/$componentName/history');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final historyList = data['results']['history'] as List<dynamic>;
      return historyList.map((json) => HistoryItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load history: ${response.statusCode}');
    }
  }

  static Future<ComponentInfo> fetchComponentInfo(String componentName) async {
    final url = Uri.parse('$baseUrl/component/$componentName/componentInfo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ComponentInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load component info: ${response.statusCode}');
    }
  }

  static Future<ComponentInfo> fetchConnectorInfo(String componentName) async {
    final url = Uri.parse('$baseUrl/component/$componentName/connectorInfo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ComponentInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load connector info: ${response.statusCode}');
    }
  }

  static Future<List<ChartPoint>> fetchChart(String componentName, String accumulatorName) async {
    final url = Uri.parse("$baseUrl/component/charts");
    final body = jsonEncode({
      "component": componentName,
      "accumulators": [accumulatorName],
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final points = data['results']['charts'][0]['points'] as List;
      return points.map((point) => ChartPoint.fromJson(point)).toList();
    } else {
      throw Exception("Failed to fetch chart data: ${response.reasonPhrase}");
    }
  }
}