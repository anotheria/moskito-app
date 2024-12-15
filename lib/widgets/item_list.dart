import 'package:flutter/material.dart';
import '../models/view.dart';
import 'dialog_tabs.dart';

class ItemList extends StatelessWidget {
  final List<MoSKitoView> data;
  const ItemList({super.key, required this.data});

  Color _parseColor(String colorString) {
    switch (colorString) {
      case 'RED':
        return Colors.red;
      case 'GREEN':
        return Colors.green;
      case 'ORANGE':
        return Colors.orange;
      case 'YELLOW':
        return Colors.yellow;
      case 'PURPLE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final myView = data[index];
        final viewColor = _parseColor(myView.color); // Farbe der MoSKitoView

        return ExpansionTile(
          leading: Icon(
            Icons.circle,
            color: viewColor,
            size: 32,
          ),
          title: Text(
            myView.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: myView.components.map((component) {
            return ListTile(
              leading: Icon(
                Icons.circle,
                color: _parseColor(component.color),
              ),
              title: Text(component.name),
              onTap: () {
                // Öffne den Dialog für diese Komponente
                showDialog(
                  context: context,
                  builder: (context) => DialogTabs(componentName: component.name),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}