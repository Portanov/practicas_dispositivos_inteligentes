import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'ble_constants.dart';
import 'sensor_simulator.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class BleServer {
  static const MethodChannel _channel = MethodChannel(
    'com.example.wearable_app/ble_peripheral',
  );

  final SensorSimulator simulator;
  final List<StreamSubscription> _sensorSubs = [];

  bool _advertising = false;
  bool get isAdvertising => _advertising;

  BleServer(this.simulator);

  Uint8List _int32ToBytes(int value) {
    final data = ByteData(4);
    data.setInt32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  Uint8List _int16ToBytes(int value) {
    final data = ByteData(2);
    data.setInt16(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  Future<void> startAdvertising() async {
    if (_advertising) return;

    try {
      await _ensurePeripheralPermissions();
      final ok = await _channel.invokeMethod<bool>('startPeripheral');
      if (ok != true) {
        throw Exception('No se pudo iniciar el periferico BLE');
      }

      _advertising = true;
      _cancelSensorSubscriptions();

      _sensorSubs.add(
        simulator.stepsStream.listen((steps) {
          _sendValue(BleConstants.stepsUUID, _int32ToBytes(steps));
        }),
      );

      _sensorSubs.add(
        simulator.heartRateStream.listen((bpm) {
          _sendValue(BleConstants.heartRateUUID, Uint8List.fromList([bpm]));
        }),
      );

      _sensorSubs.add(
        simulator.caloriesStream.listen((cal) {
          _sendValue(BleConstants.caloriesUUID, _int16ToBytes(cal));
        }),
      );

      _sensorSubs.add(
        simulator.statusStream.listen((status) {
          _sendValue(
            BleConstants.statusUUID,
            Uint8List.fromList(utf8.encode(status)),
          );
        }),
      );

      print('[BleServer] Periferico BLE iniciado');
    } catch (e) {
      _advertising = false;
      print('[BleServer] Error iniciando periferico: $e');
      rethrow;
    }
  }

  Future<void> _sendValue(String uuid, Uint8List data) async {
    if (!_advertising) return;

    try {
      await _channel.invokeMethod('updateValue', {
        'uuid': uuid,
        'value': data.toList(growable: false),
      });
    } catch (e) {
      print('[BleServer] Error enviando $uuid: $e');
    }
  }

  void _cancelSensorSubscriptions() {
    for (final sub in _sensorSubs) {
      sub.cancel();
    }
    _sensorSubs.clear();
  }

  void stop() {
    _advertising = false;
    _cancelSensorSubscriptions();
    unawaited(_channel.invokeMethod('stopPeripheral'));
    simulator.stop();
    print('[BleServer] Periferico BLE detenido');
  }

  void dispose() {
    stop();
  }

  Future<void> _ensurePeripheralPermissions() async {
    if (!Platform.isAndroid) return;

    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    final denied = statuses.entries
        .where((e) => !e.value.isGranted)
        .map((e) => e.key.toString())
        .toList();

    if (denied.isNotEmpty) {
      throw Exception('Permisos BLE faltantes: ${denied.join(', ')}');
    }
  }
}
