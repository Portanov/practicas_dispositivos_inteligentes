import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  Future<List<ScanResult>> scanDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final Map<String, ScanResult> devicesMap = {};

    final subscription = FlutterBluePlus.onScanResults.listen((results) {
      for (var r in results) {
        devicesMap[r.device.remoteId.str] = r;
      }
    });

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState
        .where((state) => state == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(timeout: timeout);

    await FlutterBluePlus.isScanning.where((s) => s == false).first;

    await subscription.cancel();

    return devicesMap.values.toList();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      return true;
    } catch (e) {
      print('Error al conectar: $e');
      return false;
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      print('Error al desconectar: $e');
    }
  }

  Future<List<BluetoothService>> discoverDeviceServices(
    BluetoothDevice device,
  ) async {
    try {
      return await device.discoverServices();
    } catch (e) {
      print('Error al descubrir servicios: $e');
      return [];
    }
  }

  Future<List<int>> readCharacteristicValue(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    try {
      final services = await device.discoverServices();

      final service = services.firstWhere(
        (s) => s.uuid == serviceUuid,
        orElse: () => throw Exception("Servicio no encontrado"),
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid == characteristicUuid,
        orElse: () => throw Exception("Característica no encontrada"),
      );

      final data = await characteristic.read();

      if (data.isEmpty || data.length > 50) {
        throw Exception("Datos inválidos");
      }

      return data;
    } catch (e) {
      print('Error al leer característica: $e');
      return [];
    }
  }
}
