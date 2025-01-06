import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:io';
import '../main.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'help_page.dart';


abstract class BasePage extends StatefulWidget {
  final String helpFilePath;
  final String appBarTitle;
  final bool showSystem;

  const BasePage({required this.helpFilePath, required this.appBarTitle, Key? key, this.showSystem = true})
      : super(key: key);

  @override
  BasePageState createState();
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C9FD7),
        title: ValueListenableBuilder<String>(
          valueListenable: selectedSystemNameGlobal,
          builder: (context, value, child) {
            return widget.showSystem ?
              Text('$value :: ${widget.appBarTitle}')
              : Text(widget.appBarTitle)
            ;
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: ()  {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpPage(helpFilePath: widget.helpFilePath),
                  ),
              );
            },
          ),
        ],
      ),
      body: buildPageContent(context),
    );
  }

  // Method to be overridden by child classes to provide page-specific content
  Widget buildPageContent(BuildContext context);
  Future<void> showHelpDialog(BuildContext context, String helpFilePath) async {
    String helpContent = await rootBundle.loadString(helpFilePath);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Help"),
          content: SingleChildScrollView(
            child: Html(data: helpContent),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }}