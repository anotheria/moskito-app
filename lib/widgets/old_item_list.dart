import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/view.dart';
import '../states/view_state.dart';
import '../utils/utils.dart';
import 'dialog_tabs.dart';

class ItemList extends StatelessWidget {
  final List<MoSKitoView> data;
  const ItemList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final viewItemState = Provider.of<ViewItemState>(context, listen: false);

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final MoSKitoView myView = data[index];
        final viewColor = AppUtils.parseColor(myView.color); // Farbe der MoSKitoView

        return ExpansionTile(
          leading: Icon(
            Icons.circle,
            color: viewColor,
            size: 18,
          ),
          title: Text(
            myView.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: myView.components.map((component) {
            return ListTile(
              leading: AppUtils.getStatusCircle(component.color),
              title: Text(component.name),
              visualDensity: VisualDensity.compact,
              onTap: () {
                // Open the info dialog (accumulators, thresholds, info etc)
                showDialog(
                  context: context,
                  builder: (context) => DialogTabs(componentName: component.name),
                );
              },
            );
          }).toList(),
          onExpansionChanged: (isExpanded) {
              // Select the view in ViewItemState
              viewItemState.selectViewItem(ViewItem(name: myView.name));
          },
        );
      },
    );
  }



  Widget build2(BuildContext context) {
    final viewItemState = Provider.of<ViewItemState>(context, listen: false);

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final MoSKitoView myView = data[index];
        final viewColor = AppUtils.parseColor(myView.color); // Farbe der MoSKitoView

        return ExpansionTile(
          leading: Icon(
            Icons.circle,
            color: viewColor,
            size: 18,
          ),
          title: Text(
            myView.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: myView.components.map((component) {
            return ListTile(
              leading: AppUtils.getStatusCircle(component.color),
              title: Text(component.name),
              visualDensity: VisualDensity.compact,
              onTap: () {
                // Open the info dialog (accumulators, thresholds, info etc)
                showDialog(
                  context: context,
                  builder: (context) => DialogTabs(componentName: component.name),
                );
              },
            );
          }).toList(),
          onExpansionChanged: (isExpanded) {
            // Select the view in ViewItemState
            viewItemState.selectViewItem(ViewItem(name: myView.name));
          },
        );
      },
    );
  }
}