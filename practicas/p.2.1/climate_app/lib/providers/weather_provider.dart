import 'package:climate_app/utils/waether_utils.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();
  Weather? _weather;
  bool _isLoading = false;
  String? _error;
  int _tempUnit = 0;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';

  double get displayedTemperature {
    if (_weather == null) return 0.0;
    final c = _weather!.temperature;
    return _tempUnit == 0 ? c.toDouble() : WeatherUtils.celsiusToFahrenheit(c);
  }

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _weather = await _service.getWeather(city);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTemperatureUnit() {
    _tempUnit = _tempUnit == 0 ? 1 : 0;
    notifyListeners();
  }

  void updateTemperature(int newTemp) {
    if (_weather != null) {
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemp,
        condition: _weather!.condition,
        description: _weather!.description,
        humidity: _weather!.humidity,
        windSpeed: _weather!.windSpeed,
      );
      notifyListeners();
    }
  }
}
