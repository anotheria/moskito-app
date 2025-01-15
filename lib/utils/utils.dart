import 'package:flutter/material.dart';

class AppUtils{

  static const double circleBoxSize = 12;
  static const double smallCircleBoxSize = 8;

  static const chartColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.grey,
    Colors.blueGrey,

  ];

  static Color getChartColor(int chartIndex) {
    return chartColors[chartIndex % chartColors.length];
  }

  static Color getAppBarColor(){
    return Colors.grey.shade900;
  }


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

  static Container getSmallStatusCircle(String colorString) {
    return Container(
      width: smallCircleBoxSize,
      height: smallCircleBoxSize,
      decoration: BoxDecoration(
        color: parseColor(colorString),
        shape: BoxShape.circle,
      ),
    );
  }

  static Icon getSmallRightArrow(){
    return const Icon(Icons.arrow_forward, size: 10);
  }


}