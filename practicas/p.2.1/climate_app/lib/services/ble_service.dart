import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  Future<List<ScanResult>> scanDevices({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final List<ScanResult> results = [];

    var subscription = FlutterBluePlus.onScanResults.listen((scanResults) {
      if (scanResults.isNotEmpty) {
        for (ScanResult r in scanResults) {
          results.add(r);
        }
      }
    }, onError: (e) => print(e));
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;
    await FlutterBluePlus.startScan(
      withServices: [Guid("180D")],
      withNames: ["CandyVint"],
      timeout: timeout,
    );

    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    subscription.cancel();

    return results;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      return true;
    } catch (e) {
      print('Error al conectar con el dispositivo');
      return false;
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      device.disconnect();
    } catch (e) {
      print('Error al desconectar');
    }
  }

  Future<List<BluetoothService>> discoverDeviceServices(
    BluetoothDevice device,
  ) async {
    await device.connect();
    final services = await device.discoverServices();
    return services;
  }

  Future<List<int>> readCharacteristicValue(
    BluetoothDevice device,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    final services = await device.discoverServices();

    final service = services.firstWhere((s) => s.uuid == serviceUuid);
    final characteristic = service.characteristics.firstWhere(
      (c) => c.uuid == characteristicUuid,
    );

    return await characteristic.read();
  }
}
