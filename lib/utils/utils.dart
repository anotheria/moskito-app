import 'package:flutter/material.dart';

class AppUtils{

  static const double circleBoxSize = 16;

  static Color parseColor(String colorString) {
    colorString = colorString.toUpperCase();
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

  static Container getStatusCircle(String colorString) {
    return Container(
      width: circleBoxSize,
      height: circleBoxSize,
      decoration: BoxDecoration(
        color: parseColor(colorString),
        shape: BoxShape.circle,
      ),
    );
  }



}