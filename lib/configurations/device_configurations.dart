import 'package:le_test/models.dart';

final deviceConfigurations = {
  DeviceConfiguration(
    type: DeviceType.additel273Ex,
    key: 'P15a',
    id: 0x2821,
    bluetoothLowEnergyConfiguration: BluetoothLowEnergyConfiguration.bgm111,
  ),
  DeviceConfiguration(
    type: DeviceType.additel260Ex,
    key: 'P15b',
    id: 0x9D44,
    bluetoothLowEnergyConfiguration: BluetoothLowEnergyConfiguration.bgm111,
  ),
  DeviceConfiguration(
    type: DeviceType.additel227Ex,
    key: 'P15c',
    id: 0x7612,
    bluetoothLowEnergyConfiguration: BluetoothLowEnergyConfiguration.bgm111,
  ),
  DeviceConfiguration(
    type: DeviceType.additel282,
    key: 'P15d',
    id: 0x02A0,
    bluetoothLowEnergyConfiguration: BluetoothLowEnergyConfiguration.bgm111,
  ),
  DeviceConfiguration(
    type: DeviceType.additel284,
    key: 'P15e',
    id: 0x02A0,
    bluetoothLowEnergyConfiguration: BluetoothLowEnergyConfiguration.bgm111,
  ),
  DeviceConfiguration(
    type: DeviceType.additel227,
    key: 'P15f',
    id: 0X02A0,
    bluetoothLowEnergyConfiguration: BluetoothLowEnergyConfiguration.bgm111,
  ),
  DeviceConfiguration(
    type: DeviceType.additel601,
    key: 'P26b',
    bluetoothLowEnergyConfiguration:
        BluetoothLowEnergyConfiguration.stm32WB5MMG,
  ),
  DeviceConfiguration(
    type: DeviceType.additel680A,
    key: 'P26c',
    bluetoothLowEnergyConfiguration:
        BluetoothLowEnergyConfiguration.stm32WB5MMG,
  ),
  DeviceConfiguration(
    type: DeviceType.additel680P,
    key: 'P26d',
    bluetoothLowEnergyConfiguration:
        BluetoothLowEnergyConfiguration.stm32WB5MMG,
  ),
  DeviceConfiguration(
    type: DeviceType.additel681A,
    key: 'P26e',
    bluetoothLowEnergyConfiguration: BluetoothLowEnergyConfiguration.bgm111,
  ),
};

Map<String, DeviceType> get deviceKeyToTypes {
  return {
    for (var configuration in deviceConfigurations)
      configuration.key: configuration.type
  };
}

Map<int, DeviceType> get deviceIdToTypes {
  final configurations =
      deviceConfigurations.where((configuration) => configuration.id != null);
  return {
    for (var configuration in configurations)
      configuration.id!: configuration.type
  };
}

Map<DeviceType, BluetoothLowEnergyConfiguration>
    get deviceTypeToBluetoothLowEnergyConfigurations {
  return {
    for (var configuration in deviceConfigurations)
      configuration.type: configuration.bluetoothLowEnergyConfiguration
  };
}
