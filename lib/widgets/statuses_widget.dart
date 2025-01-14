import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dialog_tabs.dart';
import '../models/view.dart';
import '../utils/utils.dart';
import '../states/view_state.dart';

class StatusesWidget extends StatelessWidget {
  final List<MoSKitoView> data;

  const StatusesWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final viewItemState = Provider.of<ViewItemState>(context, listen: false);

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final MoSKitoView myView = data[index];
        final viewColor = AppUtils.parseColor(myView.color);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // View Name mit Statuspunkt
              Row(
                children: [
                  Icon(Icons.circle, color: viewColor, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    myView.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Komponenten als zusammenhängende Liste
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: myView.components.map((component) {
                  final componentColor = AppUtils.parseColor(component.color);

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => DialogTabs(componentName: component.name),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: componentColor, size: 8),
                        const SizedBox(width: 4),
                        Text(
                          component.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}