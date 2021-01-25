import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:awesome_board/models/ble_device.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  PermissionStatus _locationPermissionStatus = PermissionStatus.unknown;
  BleDevice currentDevice;
  StreamSubscription scanSubscribtion;
  BleManager bleManager;
  final _controllerRead = StreamController<String>();
  final _controllerInformation = StreamController<BleInformationType>();

  final String _bleName = "moonboard :)";
  final String _serviceUUID = "4fb8a9be-c293-4459-a39f-ccf92a532eb5";
  final String _characteristicsReadUUID = "fe1fce17-fa71-407c-b831-a3b6da3e1deb";
  final String _characteristicsWriteUUID = "fe1fce17-fa71-407c-b831-a3b6da3e1deb";

  String currentReadValue = "";
  bool shouldListen = false;
  bool finishedScanAndFoundDevice = false;
  bool _isReading = false;
  Timer t;
  bool isWriting = false;

  Stream<String> get streamRead => _controllerRead.stream;
  Stream<BleInformationType> get streamInformation => _controllerInformation.stream;
  Stream<CharacteristicWithValue> get monitor => currentDevice.peripheral.monitorCharacteristic(_serviceUUID, _characteristicsReadUUID);

  BleService() {
    initData();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      var permissionStatus = await PermissionHandler().requestPermissions([PermissionGroup.location]);

      _locationPermissionStatus = permissionStatus[PermissionGroup.location];

      if (_locationPermissionStatus != PermissionStatus.granted) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }

  Future<void> cleanup() async {
    stopReading();
    await bleManager.stopPeripheralScan();
    await scanSubscribtion.cancel();
    await bleManager.destroyClient();
    await _controllerRead.close();
    await _controllerInformation.close();
  }

  void startReading() {
    shouldListen = true;
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (!shouldListen)
        timer.cancel();
      else if (finishedScanAndFoundDevice && !_isReading) {
        _isReading = true;
        var val = await readData();
        _isReading = false;
        _controllerRead.sink.add(val);
      }
    });
  }

  void stopReading() {
    shouldListen = false;
  }

  void startStopRading() {
    shouldListen ? stopReading() : startReading();
  }

  Future<void> connect() async {
    if (currentDevice == null) return;
    bool cnctd = await currentDevice.peripheral.isConnected();
    if (!cnctd) {
      await currentDevice.peripheral.connect(requestMtu: 500);
    }
  }

  void initData() async {
    await _checkPermissions();
    bleManager = BleManager();
    await bleManager.createClient();

    scanSubscribtion = bleManager.observeBluetoothState().listen(
      (btState) {
        if (btState == BluetoothState.POWERED_ON) {
          bleManager.startPeripheralScan().listen((scanResult) async {
            var bleDevice = BleDevice(scanResult);
            if (bleDevice.name.contains(this._bleName) && currentDevice == null) {
              currentDevice = bleDevice;
              await bleManager.stopPeripheralScan();
              scanSubscribtion.cancel();
              await connect();
              await currentDevice.peripheral.discoverAllServicesAndCharacteristics(transactionId: "discSC_1");
              finishedScanAndFoundDevice = true;
              _controllerInformation.sink.add(BleInformationType.deviceReady);
            }
          });
        }
      },
    );
  }

  Future<String> readData() async {
    if (currentDevice == null) return currentReadValue;

    var val = await currentDevice.peripheral.readCharacteristic(_serviceUUID, _characteristicsReadUUID);
    currentReadValue = utf8.decode(val.value);
    return currentReadValue;
  }

  void writeData(String data) async {
    if (currentDevice == null || isWriting) return;
    var val = utf8.encode(data);

    await currentDevice.peripheral.writeCharacteristic(
      _serviceUUID,
      _characteristicsWriteUUID,
      val,
      false,
    );
  }
}

enum BleInformationType {
  deviceReady,
}
