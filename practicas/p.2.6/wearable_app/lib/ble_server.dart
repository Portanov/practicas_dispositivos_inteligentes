import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_constants.dart';
import 'sensor_simulator.dart';
import 'package:ble_peripheral/ble_peripheral.dart' as bp;

class BleServer {
  final SensorSimulator simulator;
  bool _advertising = false;
  BleServer(this.simulator);
  bool get isAdvertising => _advertising;

  Uint8List _intToBytes(int value) {
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
    try {
      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        throw Exception('Bluetooth desactivado. Actívalo en el emulador.');
      }

      // -------------------------
      // BLE Peripheral Init
      // -------------------------

      await bp.BlePeripheral.initialize();

      final supported = await bp.BlePeripheral.isSupported();

      print('[BLE] Supported: $supported');

      if (!supported) {
        throw Exception(
          'BLE Peripheral no soportado en este dispositivo/emulador',
        );
      }

      bp.BlePeripheral.setAdvertisingStatusUpdateCallback((advertising, error) {
        print('[BLE STATUS] advertising=$advertising error=$error');
      });

      await bp.BlePeripheral.clearServices();

      // -------------------------
      // Servicio principal
      // -------------------------

      await bp.BlePeripheral.addService(
        bp.BleService(
          uuid: BleConstants.serviceUUID,
          primary: true,
          characteristics: [
            bp.BleCharacteristic(
              uuid: BleConstants.stepsUUID,
              properties: [
                bp.CharacteristicProperties.read.index,
                bp.CharacteristicProperties.notify.index,
              ],
              permissions: [bp.AttributePermissions.readable.index],
            ),

            bp.BleCharacteristic(
              uuid: BleConstants.heartRateUUID,
              properties: [
                bp.CharacteristicProperties.read.index,
                bp.CharacteristicProperties.notify.index,
              ],
              permissions: [bp.AttributePermissions.readable.index],
            ),

            bp.BleCharacteristic(
              uuid: BleConstants.caloriesUUID,
              properties: [
                bp.CharacteristicProperties.read.index,
                bp.CharacteristicProperties.notify.index,
              ],
              permissions: [bp.AttributePermissions.readable.index],
            ),

            bp.BleCharacteristic(
              uuid: BleConstants.statusUUID,
              properties: [
                bp.CharacteristicProperties.read.index,
                bp.CharacteristicProperties.notify.index,
              ],
              permissions: [bp.AttributePermissions.readable.index],
            ),
          ],
        ),
      );

      print('[BLE] Servicio registrado');

      // -------------------------
      // Advertising
      // -------------------------

      await bp.BlePeripheral.startAdvertising(
        services: [BleConstants.serviceUUID],
      );

      _advertising = true;

      print('[BleServer] Advertising iniciado');

      simulator.stepsStream.listen((steps) {
        _notifyCharacteristic(BleConstants.stepsUUID, _intToBytes(steps));
      });
      simulator.heartRateStream.listen((bpm) {
        _notifyCharacteristic(
          BleConstants.heartRateUUID,
          Uint8List.fromList([bpm]),
        );
      });
      simulator.caloriesStream.listen((cal) {
        _notifyCharacteristic(BleConstants.caloriesUUID, _int16ToBytes(cal));
      });
      simulator.statusStream.listen((status) {
        _notifyCharacteristic(
          BleConstants.statusUUID,
          Uint8List.fromList(utf8.encode(status)),
        );
      });
    } catch (e) {
      _advertising = false;
      print('[BleServer] Error: $e');
      rethrow;
    }
  }
  
  Future<void> _notifyCharacteristic(String uuid, Uint8List data) async {
    print('[NOTIFY] $uuid -> ${data.toList()}');

    try {
      await bp.BlePeripheral.updateCharacteristic(
        characteristicId: uuid,
        value: data,
      );

      print('[NOTIFY OK] $uuid');
    } catch (e) {
      print('[NOTIFY ERROR] $e');
    }
  }
  
  Future<void> stop() async {
    _advertising = false;

    try {
      await bp.BlePeripheral.stopAdvertising();
    } catch (_) {}

    simulator.stop();

    print('[BLE] Advertising detenido');
  }

}
