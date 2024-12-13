import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/view.dart';
import '../models/history_item.dart';
import '../models/component_info.dart';


class ApiService {
  //static const String _baseUrl = 'https://burgershop-control.demo.moskito.org/api/v2';
  static const String _baseUrl = 'https://moskito-control.thecasuallounge.com/api/v2';

  static Future<List<MoSKitoView>> fetchViews() async {
    final response = await http.get(Uri.parse('$_baseUrl/control' ));

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final viewsJson = decodedJson['results']['views'] as List<dynamic>;
      return viewsJson.map((viewJson) => MoSKitoView.fromJson(viewJson)).toList();
    } else {
      throw Exception('Fehler beim Abrufen der Daten: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchThresholds(String componentName) async {
    final url = Uri.parse('$_baseUrl/component/$componentName/thresholds');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(decodedJson['results']['thresholds']);
    } else {
      throw Exception('Fehler beim Abrufen der Daten: ${response.statusCode}');
    }
  }

  static Future<List<HistoryItem>> fetchHistory(String componentName) async {
    final url = Uri.parse('$_baseUrl/component/$componentName/history'); // Update with your API base URL
    print("History URL: $url");
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
    final url = Uri.parse('$_baseUrl/component/$componentName/componentInfo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ComponentInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load component info: ${response.statusCode}');
    }
  }

  static Future<ComponentInfo> fetchConnectorInfo(String componentName) async {
    final url = Uri.parse('$_baseUrl/component/$componentName/connectorInfo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ComponentInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load connector info: ${response.statusCode}');
    }
  }
}