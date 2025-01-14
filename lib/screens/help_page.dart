import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';


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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    print("Open $uri");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
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
              child: Html(
                style: {
                  "p": Style(
                    fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                    fontSize: FontSize(12),
                    color: Colors.white,
                  ),
                  "h2": Style(
                    fontFamily: Theme.of(context).textTheme.headlineMedium?.fontFamily,
                    fontSize: FontSize(16),
                    color: Colors.white,
                  ),
                },
                  data: snapshot.data,
                onLinkTap: (url, attributes, element) {
                  if (url != null) {
                    _launchURL(url);
                  }
                },
                extensions: [
              TagExtension(
              tagsToExtend: {"img"},
                builder: (context) {
                  final src = context.attributes['src'] ?? '';
                  if (src.startsWith('assets/')) {
                    return Image.asset(src);
                  } else {
                    return Image.network(src);
                  }
                },
              ),
              ],
              ),
            );
          }
        },
      ),
    );
  }
}