import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:moskito_control/utils/utils.dart';
import 'dart:io';
import '../main.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'help_page.dart';
import '../services/api_service.dart';
import '../models/mute_status.dart';


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
  void initState() {
    super.initState();
    _fetchMuteStatus();
  }

  Future<void> _fetchMuteStatus() async {
    try {
      final muteStatus = await ApiService.fetchMuteStatus();
      muteStatusGlobal.value = muteStatus;
    } catch (e) {
      // Silently fail - mute status is optional
    }
  }

  void _showMuteInfo(BuildContext context, MuteStatus? muteStatus) {
    if (muteStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mute status unavailable')),
      );
      return;
    }

    final message = muteStatus.muted
        ? 'System is muted for ${muteStatus.remainingMutingTimeAsString} minutes'
        : 'System is not muted';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showMuteToggleDialog(BuildContext context, MuteStatus? muteStatus) {
    final bool isMuted = muteStatus?.muted ?? false;

    if (isMuted) {
      // Show unmute option
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unmute System'),
          content: const Text('Do you want to unmute the system and enable notifications?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _toggleMute(context, false, 0);
              },
              child: const Text('Unmute'),
            ),
          ],
        ),
      );
    } else {
      // Show mute options with duration
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mute System'),
          content: const Text('How long do you want to mute notifications?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _toggleMute(context, true, 30);
              },
              child: const Text('30 min'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _toggleMute(context, true, 60);
              },
              child: const Text('1 hour'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _toggleMute(context, true, 120);
              },
              child: const Text('2 hours'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _toggleMute(BuildContext context, bool mute, int minutes) async {
    try {
      if (mute) {
        await ApiService.muteSystem(minutes);
      } else {
        await ApiService.unmuteSystem();
      }
      await _fetchMuteStatus();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mute ? 'System muted for $minutes minutes' : 'System unmuted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error toggling mute: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${mute ? "mute" : "unmute"} system: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppUtils.getAppBarColor(),// const Color(0xFF6C9FD7),
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
          ValueListenableBuilder<MuteStatus?>(
            valueListenable: muteStatusGlobal,
            builder: (context, muteStatus, child) {
              return GestureDetector(
                onLongPress: () {
                  _showMuteToggleDialog(context, muteStatus);
                },
                child: IconButton(
                  icon: Icon(
                    muteStatus?.muted == true
                        ? Icons.notifications_off
                        : Icons.notifications,
                  ),
                  onPressed: () {
                    _showMuteInfo(context, muteStatus);
                  },
                ),
              );
            },
          ),
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