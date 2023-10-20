import 'bluetooth_low_energy_configuration.dart';
import 'device_type.dart';

class DeviceConfiguration {
  final DeviceType type;
  final String key;
  final int? id;
  final BluetoothLowEnergyConfiguration bluetoothLowEnergyConfiguration;

  DeviceConfiguration({
    required this.type,
    required this.key,
    this.id,
    required this.bluetoothLowEnergyConfiguration,
  });

  @override
  operator ==(Object other) {
    return other is DeviceConfiguration && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}
