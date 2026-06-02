import 'package:climate_app/widgets/weather_icon.dart';
import 'package:flutter/material.dart';

class TemperatureCard extends StatelessWidget {
  final String city;
  final double temperature;
  final String condition;
  final Color iconColor;

  const TemperatureCard({
    Key? key,
    required this.city,
    required this.temperature,
    required this.condition,
    this.iconColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIcon(condition: condition),
            Text(
              '${temperature.toStringAsFixed(0)}°C',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              city,
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
