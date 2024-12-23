import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/view.dart';

class ViewItemState extends ChangeNotifier {
  List<ViewItem> _viewItems = [];
  ViewItem? _selectedViewItem;

  List<ViewItem> get viewItems => _viewItems;

  ViewItem? get selectedViewItem => _selectedViewItem;

  // Setzt die Liste der ViewItems
  void setViewItems(List<ViewItem> items) {
    print("All view items are now set to ${items.map((item) => item.name)
        .toList()}");
    _viewItems = items;
    notifyListeners();
  }

  // Sets currently selected ViewItem
  void selectViewItem(ViewItem item) {
    print("Selected ViewItem: ${item.name}");
    _selectedViewItem = item;
    notifyListeners();
  }

  void selectViewItemByName(String name) {
    _selectedViewItem =
        _viewItems.firstWhereOrNull((item) => item.name == name);
    notifyListeners();
  }

  String getSelectedViewName() {
    return _selectedViewItem?.name ?? "ALL";
  }
}