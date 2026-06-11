import 'dart:async';

import 'package:climate_app/services/ble_service.dart';
import 'package:climate_app/utils/waether_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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

  final BleService _bleService = BleService();

  Future<List<int>> readBlueCarac(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    try {
      final value = await _bleService.readCharacteristicValue(
        device,
        serviceUuid,
        characteristicUuid,
      );

      return value;
    } catch (e) {
      return [];
    }
  }

  bool _isBleConnecting = false;
  bool _isBleConnected = false;
  String _bleStatus = 'Sin conexion BLE';
  List<int> _lastBleData = [];
  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothConnectionState>? _bleConnectionSub;

  bool get isBleConnecting => _isBleConnecting;
  bool get isBleConnected => _isBleConnected;
  String get bleStatus => _bleStatus;
  List<int> get lastBleData => _lastBleData;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<void> connectAndReadDevice(
    BluetoothDevice device, {
    required Guid serviceUuid,
    required Guid characteristicUuid,
  }) async {
    _isBleConnecting = true;
    _bleStatus = 'Conectando...';
    notifyListeners();

    try {
      final connected = await _bleService.connectToDevice(device);
      if (!connected) {
        _isBleConnected = false;
        _bleStatus = 'Sin conexion BLE';
        return;
      }

      _connectedDevice = device;
      _isBleConnected = true;
      _bleStatus = 'Conectado. Leyendo datos...';

      await _bleConnectionSub?.cancel();
      _bleConnectionSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isBleConnected = false;
          _connectedDevice = null;
          _bleStatus = 'Sin conexion BLE';
          notifyListeners();
        }
      });

      final data = await _bleService.readCharacteristicValue(
        device,
        serviceUuid,
        characteristicUuid,
      );

      _lastBleData = data;
      _bleStatus = 'Conectado. Datos: ${data.join(", ")}';
    } catch (_) {
      _isBleConnected = false;
      _bleStatus = 'Sin conexion BLE';
    } finally {
      _isBleConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnectBle() async {
    final device = _connectedDevice;
    if (device == null) return;

    await _bleService.disconnectDevice(device);
    await _bleConnectionSub?.cancel();
    _bleConnectionSub = null;

    _isBleConnected = false;
    _connectedDevice = null;
    _bleStatus = 'Sin conexion BLE';
    notifyListeners();
  }

  @override
  void dispose() {
    _bleConnectionSub?.cancel();
    super.dispose();
  }
}
