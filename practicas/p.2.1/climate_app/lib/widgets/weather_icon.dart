import 'package:climate_app/utils/waether_utils.dart';
import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;
  final Color iconColor;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 120,
    this.iconColor = Colors.deepOrangeAccent,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = WeatherUtils.getWeatherIcon(condition);
    return Icon(iconData, size: size, color: iconColor);
  }
}
