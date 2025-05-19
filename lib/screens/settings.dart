import 'package:flutter/material.dart';
import 'dart:async';
import '../services/selectable_system_service.dart';
import '../models/selectable_system.dart';
import 'base_page.dart';
import 'main_screen.dart';

class SettingsScreen extends BasePage {
  const SettingsScreen({Key? key})
      : super(
    key: key,
    helpFilePath: 'assets/help/settings.html',
    appBarTitle: 'Settings',
    showSystem: false,
  );

  static SettingsScreenState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<SettingsScreenState>();
    return state;
  }


  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends BasePageState<SettingsScreen> {
  final SelectableSystemService _service = SelectableSystemService();
  List<SelectableSystem> _systems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
    fetchData();
    mainScreenState?.settingsState = this;
    }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    List<SelectableSystem> systems = await _service.getSystems();
    if (systems.isEmpty) {
      await addSystem("Demo", "https://burgershop-control.demo.moskito.org/api/v2");
      systems = await _service.getSystems();
    }
    setState(() {
      _systems = systems;
      isLoading = false;
    });
  }

  Future<void> addSystem(String name, String url) async {
    final newSystem = SelectableSystem(name: name, url: url);
    await _service.addSystem(newSystem);
    await fetchData();
  }

  Future<void> updateSystem(String name, String url) async {
    await _service.updateSystem(name, url);
    await fetchData();
  }

  Future<void> deleteSystem(String name) async {
    await _service.removeSystem(name);
    await fetchData();
  }

  @override
  Widget buildPageContent(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _systems.length,
            itemBuilder: (context, index) {
              final system = _systems[index];
              return ListTile(
                title: Text(system.name),
                subtitle: Text(system.url),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: ()  => _showEditSystemDialog(context, system.name, system.url),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await deleteSystem(system.name);
                      },

                    ),

                  ],
                )
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _showAddSystemDialog(context, null, null),
            child: const Text('Add System'),
          ),
        ),
      ],
    );
  }

  void _showAddSystemDialog(BuildContext context, String? name, String? url) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        if (name != null)
          nameController.text = name;
        if (url != null)
          urlController.text = url;
        return AlertDialog(
          title: const Text('Add System'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'System Name'),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'System URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final url = urlController.text;

                if (name.isNotEmpty && url.isNotEmpty) {
                  await addSystem(name, url);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }//_showAddSystemDialog


  void _showEditSystemDialog(BuildContext context, String name, String url) {
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      nameController.text = name;
      urlController.text = url;

      return AlertDialog(
        title: const Text('Edit System'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'System Name'),
              readOnly: true,
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'System URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final url = urlController.text;

              if (name.isNotEmpty && url.isNotEmpty) {
                await updateSystem(name, url);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
  }//_showAddSystemDialog

  /// Makes the edit system dialog callable from outside, e.g. via deep link.
  void showAddSystemFromDeepLink(String name, String url) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddSystemDialog(context, name, url);
    });
  }
}//_SettingsPageState
