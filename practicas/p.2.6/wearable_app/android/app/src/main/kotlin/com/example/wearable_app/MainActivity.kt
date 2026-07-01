package com.example.wearable_app

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.pm.PackageManager
import android.os.Build
import android.os.ParcelUuid
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

class MainActivity : FlutterActivity() {
     private val channelName = "com.example.wearable_app/ble_peripheral"

 private val serviceUuid = UUID.fromString("12345678-1234-1234-1234-123456789abc")
 private val stepsUuid = UUID.fromString("aaaaaaaa-0001-1234-1234-123456789abc")
 private val hrUuid = UUID.fromString("aaaaaaaa-0002-1234-1234-123456789abc")
 private val calUuid = UUID.fromString("aaaaaaaa-0003-1234-1234-123456789abc")
 private val statusUuid = UUID.fromString("aaaaaaaa-0004-1234-1234-123456789abc")
 private val cccUuid = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

 private var gattServer: BluetoothGattServer? = null
 private var advertiser: BluetoothLeAdvertiser? = null
 private val subscribers = ConcurrentHashMap.newKeySet<BluetoothDevice>()
 private val characteristics = mutableMapOf<UUID, BluetoothGattCharacteristic>()

 override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
     super.configureFlutterEngine(flutterEngine)

     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
         .setMethodCallHandler { call, result ->
             when (call.method) {
                 "startPeripheral" -> startPeripheral(result)
                 "stopPeripheral" -> {
                     stopPeripheral()
                     result.success(true)
                 }
                 "updateValue" -> updateValue(call, result)
                 else -> result.notImplemented()
             }
         }
 }

 private fun hasPermission(permission: String): Boolean {
     return ActivityCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
 }

 private fun hasBleRuntimePermissions(): Boolean {
     return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
         hasPermission(Manifest.permission.BLUETOOTH_CONNECT) &&
         hasPermission(Manifest.permission.BLUETOOTH_ADVERTISE)
     } else {
         hasPermission(Manifest.permission.BLUETOOTH) &&
         hasPermission(Manifest.permission.BLUETOOTH_ADMIN)
     }
 }

 private fun startPeripheral(result: MethodChannel.Result) {
     try {
         if (!hasBleRuntimePermissions()) {
             result.error("PERMISSION", "Faltan permisos BLE en runtime", null)
             return
         }

         val btManager = getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
         val adapter: BluetoothAdapter = btManager.adapter
             ?: run {
                 result.error("BT_UNAVAILABLE", "Bluetooth no disponible", null)
                 return
             }

         if (!adapter.isEnabled) {
             result.error("BT_OFF", "Bluetooth desactivado", null)
             return
         }

         advertiser = adapter.bluetoothLeAdvertiser
         if (advertiser == null) {
             result.error("NO_ADVERTISER", "Este dispositivo no soporta BLE peripheral", null)
             return
         }

         if (gattServer == null) {
             gattServer = btManager.openGattServer(this, gattCallback)
             val service = BluetoothGattService(serviceUuid, BluetoothGattService.SERVICE_TYPE_PRIMARY)

             fun makeNotifyChar(uuid: UUID): BluetoothGattCharacteristic {
                 val ch = BluetoothGattCharacteristic(
                     uuid,
                     BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PROPERTY_READ,
                     BluetoothGattCharacteristic.PERMISSION_READ
                 )
                 val ccc = BluetoothGattDescriptor(
                     cccUuid,
                     BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
                 )
                 ch.addDescriptor(ccc)
                 characteristics[uuid] = ch
                 return ch
             }

             service.addCharacteristic(makeNotifyChar(stepsUuid))
             service.addCharacteristic(makeNotifyChar(hrUuid))
             service.addCharacteristic(makeNotifyChar(calUuid))
             service.addCharacteristic(makeNotifyChar(statusUuid))

             gattServer?.addService(service)
         }

         val settings = AdvertiseSettings.Builder()
             .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
             .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
             .setConnectable(true)
             .build()

         val data = AdvertiseData.Builder()
             .setIncludeDeviceName(true)
             .addServiceUuid(ParcelUuid(serviceUuid))
             .build()

         advertiser?.startAdvertising(settings, data, advertiseCallback)
         result.success(true)
     } catch (e: Exception) {
         result.error("START_FAIL", e.message, null)
     }
 }

 private fun updateValue(call: MethodCall, result: MethodChannel.Result) {
     try {
         val uuidString = call.argument<String>("uuid")
         val valueList = call.argument<List<Int>>("value")

         if (uuidString == null || valueList == null) {
             result.error("BAD_ARGS", "uuid/value requeridos", null)
             return
         }

         val uuid = UUID.fromString(uuidString)
         val ch = characteristics[uuid]
         if (ch == null) {
             result.error("CHAR_NOT_FOUND", "Caracteristica no encontrada: $uuidString", null)
             return
         }

         val payload = ByteArray(valueList.size) { i -> valueList[i].toByte() }
         ch.value = payload

         val server = gattServer
         if (server != null) {
             subscribers.forEach { device ->
                 server.notifyCharacteristicChanged(device, ch, false)
             }
         }

         result.success(true)
     } catch (e: Exception) {
         result.error("UPDATE_FAIL", e.message, null)
     }
 }

 private fun stopPeripheral() {
     try {
         advertiser?.stopAdvertising(advertiseCallback)
     } catch (_: Exception) {}
     advertiser = null

     subscribers.clear()
     characteristics.clear()

     gattServer?.close()
     gattServer = null
 }

 private val gattCallback = object : BluetoothGattServerCallback() {
     override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
         if (newState != BluetoothGatt.STATE_CONNECTED) {
             subscribers.remove(device)
         }
     }

     override fun onDescriptorWriteRequest(
         device: BluetoothDevice,
         requestId: Int,
         descriptor: BluetoothGattDescriptor,
         preparedWrite: Boolean,
         responseNeeded: Boolean,
         offset: Int,
         value: ByteArray
     ) {
         if (descriptor.uuid == cccUuid) {
             val enabled = value.contentEquals(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)
             if (enabled) subscribers.add(device) else subscribers.remove(device)
             descriptor.value = value
             if (responseNeeded) {
                 gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, value)
             }
         } else if (responseNeeded) {
             gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_FAILURE, 0, null)
         }
     }

     override fun onCharacteristicReadRequest(
         device: BluetoothDevice,
         requestId: Int,
         offset: Int,
         characteristic: BluetoothGattCharacteristic
     ) {
         val value = characteristic.value ?: byteArrayOf()
         gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value)
     }
 }


 private val advertiseCallback = object : AdvertiseCallback() {}
}