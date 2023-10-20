import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

class BluetoothLowEnergyConfiguration {
  final UUID communicationServiceUUID;
  final UUID notifyCharacteristicUUID;
  final UUID writeCharacteristicUUID;

  BluetoothLowEnergyConfiguration({
    required this.communicationServiceUUID,
    required this.notifyCharacteristicUUID,
    required this.writeCharacteristicUUID,
  });

  static final bgm111 = BluetoothLowEnergyConfiguration(
    communicationServiceUUID:
        UUID.fromString('af661820-d14a-4b21-90f8-54d58f8614f0'),
    notifyCharacteristicUUID:
        UUID.fromString('1b6b9415-ff0d-47c2-9444-a5032f727b2d'),
    writeCharacteristicUUID:
        UUID.fromString('1b6b9415-ff0d-47c2-9444-a5032f727b2d'),
  );

  static final stm32WB5MMG = BluetoothLowEnergyConfiguration(
    communicationServiceUUID:
        UUID.fromString('0000ffe1-0000-1000-8000-00805f9b34fb'),
    notifyCharacteristicUUID:
        UUID.fromString('00002ae2-0000-1000-8000-00805f9b34fb'),
    writeCharacteristicUUID:
        UUID.fromString('00002ae1-0000-1000-8000-00805f9b34fb'),
  );
}
