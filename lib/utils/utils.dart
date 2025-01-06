import 'package:flutter/material.dart';

class AppUtils{
  static Color parseColor(String colorString) {
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

}