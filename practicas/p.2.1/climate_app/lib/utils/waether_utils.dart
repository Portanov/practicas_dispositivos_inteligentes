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

      case 'clear':
        return Icons.wb_sunny;

      case 'clouds':
        return Icons.cloud;

      case 'rain':
      case 'drizzle':
        return Icons.thunderstorm;

      case 'thunderstorm':
        return Icons.flash_on;

      case 'snow':
        return Icons.snowing;

      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.blur_on;

      default:
        return Icons.cloud;
    }
  }

  static bool isValidTemperature(int temp) {
    return temp >= -50 && temp <= 60;
  }

  static Color getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orange;

      case 'clouds':
        return Colors.blueGrey;

      case 'rain':
      case 'drizzle':
        return Colors.indigo;

      case 'thunderstorm':
        return Colors.deepPurple;

      case 'snow':
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }
}
