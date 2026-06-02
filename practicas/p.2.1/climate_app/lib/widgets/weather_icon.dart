import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;

  const WeatherIcon({Key? key, required this.condition, this.size = 120})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;

    switch (condition.toLowerCase()) {
      case 'cloud':
      case 'nublado':
        iconData = Icons.cloud;
        break;
      case 'sunny':
      case 'soleado':
        iconData = Icons.wb_sunny;
        break;
      case 'rain':
      case 'lluvia':
        iconData = Icons.cloud_queue;
        break;
      default:
        iconData = Icons.cloud;
    }

    return Icon(iconData, size: size, color: Colors.blue);
  }
}
