import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:climate_app/services/ble_service.dart';

class BleProvider extends ChangeNotifier {
  final BleService _bleService = BleService();

  List<ScanResult> _devices = [];
  bool _isScanning = false;

  List<ScanResult> get devices => _devices;
  bool get isScanning => _isScanning;

  Future<void> scanDevices() async {
    _isScanning = true;
    notifyListeners();

    try {
      final results = await _bleService.scanDevices();
      _devices = results;
    } catch (e) {
      _devices = [];
    }

    _isScanning = false;
    notifyListeners();
  }

  bool _isConnecting = false;
  bool _isConnected = false;
  String _status = "Sin conexión BLE";

  BluetoothDevice? _device;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;

  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String get status => _status;
  BluetoothDevice? get device => _device;

  List<int> _lastData = [];
  List<int> get lastData => _lastData;

  Future<void> connectAndRead(
    BluetoothDevice device, {
    required Guid serviceUuid,
    required Guid characteristicUuid,
  }) async {
    _isConnecting = true;
    _status = "Conectando...";
    notifyListeners();

    try {
      final connected = await _bleService.connectToDevice(device);

      if (!connected) {
        _status = "No se pudo conectar";
        _isConnected = false;
        return;
      }

      _device = device;
      _isConnected = true;
      _status = "Conectado. Leyendo...";

      await _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _device = null;
          _status = "Sin conexión BLE";
          notifyListeners();
        }
      });

      final data = await _bleService.readCharacteristicValue(
        device,
        serviceUuid,
        characteristicUuid,
      );

      if (data.isEmpty) {
        _status = "Datos vacíos o inválidos";
      } else {
        _lastData = data;
        _status = "Datos: ${data.join(", ")}";
      }
    } catch (e) {
      _status = "Error BLE";
      _isConnected = false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (_device == null) return;

    await _bleService.disconnectDevice(_device!);
    await _connectionSub?.cancel();

    _connectionSub = null;
    _device = null;
    _isConnected = false;
    _status = "Sin conexión BLE";

    notifyListeners();
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }
}
