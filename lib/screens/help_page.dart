import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/services.dart';

class HelpPage extends StatelessWidget {
  final String helpFilePath;

  const HelpPage({required this.helpFilePath, Key? key}) : super(key: key);

  Future<String> loadHelpContent() async {
    try {
      return await rootBundle.loadString(helpFilePath);
    } catch (e) {
      return '<h2>Error</h2><p>Could not load help content.</p>';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
        backgroundColor: const Color(0xFF6C9FD7),
      ),
      body: FutureBuilder<String>(
        future: loadHelpContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading help content."));
          } else {
            return SingleChildScrollView(
              child: Html(data: snapshot.data),
            );
          }
        },
      ),
    );
  }
}