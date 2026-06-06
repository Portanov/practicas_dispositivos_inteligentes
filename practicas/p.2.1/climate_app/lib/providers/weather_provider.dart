import 'package:climate_app/utils/waether_utils.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  int _tempUnit = 0;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _tempUnit == 0 ? '°C' : '°F';

  double get displayedTemperature {
    if (_weather == null) return 0.0;
    final c = _weather!.temperature;
    return _tempUnit == 0 ? c.toDouble() : WeatherUtils.celsiusToFahrenheit(c);
  }

  Future<void> loadWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _weather = Weather(
        city: city,
        temperature: 18,
        condition: 'rainy',
        humidity: 65,
      );
    } catch (e) {
      _errorMessage = 'Error loading weather: $e';
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
        humidity: _weather!.humidity,
      );
      notifyListeners();
    }
  }
}
