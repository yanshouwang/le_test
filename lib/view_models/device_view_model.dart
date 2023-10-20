import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/foundation.dart';
import 'package:le_test/models.dart';
import 'package:le_test/util.dart';

import 'view_model.dart';

class DeviceViewModel extends ViewModel {
  final DeviceType type;
  final Uint8List macAddress;
  final String name;

  Peripheral peripheral;
  final ValueNotifier<int> rssi;
  final ValueNotifier<ConnectionState> state;

  GattCharacteristic? _notifyCharacteristic;
  GattCharacteristic get notifyCharacteristic {
    final characteristic = _notifyCharacteristic;
    if (characteristic == null) {
      throw ArgumentError.notNull();
    } else {
      return characteristic;
    }
  }

  set notifyCharacteristic(GattCharacteristic characteristic) {
    _notifyCharacteristic = characteristic;
  }

  GattCharacteristic? _writeCharacteristic;
  GattCharacteristic get writeCharacteristic {
    final characteristic = _writeCharacteristic;
    if (characteristic == null) {
      throw ArgumentError.notNull();
    } else {
      return characteristic;
    }
  }

  set writeCharacteristic(GattCharacteristic characteristic) {
    _writeCharacteristic = characteristic;
  }

  int maximumWriteLength;

  final ValueNotifier<bool> writing;
  final ValueNotifier<bool> writeContinuously;

  late CTS writeContinuouslyCTS;

  DeviceViewModel({
    required this.type,
    required this.macAddress,
    required this.name,
    required this.peripheral,
    required int rssi,
    required ConnectionState state,
  })  : rssi = ValueNotifier(rssi),
        state = ValueNotifier(state),
        maximumWriteLength = 20,
        writing = ValueNotifier(false),
        writeContinuously = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    rssi.dispose();
    state.dispose();
    writing.dispose();
    writeContinuously.dispose();
  }
}
