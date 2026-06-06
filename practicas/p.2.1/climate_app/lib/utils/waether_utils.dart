import 'package:flutter/material.dart';

class WeatherUtils {
  static double celsiusToFahrenheit(int celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static int fahrenheitToCelsius(double fahrenheit) {
    return ((fahrenheit - 32) * 5 / 9).toInt();
  }

  static IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'cloudy':
      case 'nublado':
        return Icons.cloud;

      case 'sunny':
      case 'soleado':
        return Icons.wb_sunny;

      case 'rainy':
      case 'lluvia':
        return Icons.thunderstorm;

      case 'snowy':
      case 'nevado':
        return Icons.snowing;

      default:
        return Icons.cloud;
    }
  }

  static bool isValidTemperature(int temp) {
    return temp >= -50 && temp <= 60;
  }

  static Color getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Colors.deepOrangeAccent;
      case 'cloudy':
        return Colors.blue;
      case 'rainy':
        return Colors.indigo;
      case 'snowy':
        return Colors.grey;
      default:
        return Colors.deepOrangeAccent;
    }
  }
}
