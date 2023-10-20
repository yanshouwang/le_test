import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:le_test/configurations.dart';
import 'package:le_test/models.dart';
import 'package:le_test/util.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'device_view_model.dart';
import 'view_model.dart';

class ConnectionsTestViewModel extends ViewModel {
  final ValueNotifier<List<DeviceViewModel>> _devices;
  final ValueNotifier<bool> _discovering;
  final GattCharacteristicWriteType _type;

  late final StreamSubscription _discoveredSubscription;
  late final StreamSubscription _peripheralStateChangedSubscription;
  final Map<DeviceViewModel, StreamSubscription>
      _characteristicValueChangedSubscriptions;

  ConnectionsTestViewModel()
      : _devices = ValueNotifier([]),
        _discovering = ValueNotifier(false),
        _type = GattCharacteristicWriteType.withResponse,
        _characteristicValueChangedSubscriptions = {} {
    _discoveredSubscription = _manager.discovered.listen(onDiscovered);
    _peripheralStateChangedSubscription =
        _manager.peripheralStateChanged.listen(onPeripheralStateChanged);
  }

  ValueListenable<List<DeviceViewModel>> get devices => _devices;
  ValueListenable<bool> get discovering => _discovering;

  CentralManager get _manager => CentralManager.instance;

  void onDiscovered(DiscoveredEventArgs eventArgs) {
    final advertiseData = eventArgs.advertiseData;
    final name = advertiseData.name;
    final manufacturerSpecificData = advertiseData.manufacturerSpecificData;
    final rssi = eventArgs.rssi;
    if (name == null ||
        name.isEmpty ||
        manufacturerSpecificData == null ||
        rssi < -70) {
      return;
    }
    final manufacturerId = manufacturerSpecificData.id;
    final manufacturerData = manufacturerSpecificData.data;
    if (manufacturerId != 0x2e19) {
      return;
    }
    final DeviceType type;
    final Uint8List macAddress;
    if (manufacturerData.length == 9) {
      final idElements = manufacturerData.sublist(0, 3);
      final idBuffer = Uint8List.fromList(idElements).buffer;
      final idData = ByteData.view(idBuffer);
      final id = idData.getUint16(0, Endian.little);
      final typeValue = deviceIdToTypes[id];
      if (typeValue == null) {
        return;
      }
      type = typeValue;
      macAddress = manufacturerData.sublist(3, 9);
    } else if (manufacturerData.length == 11) {
      final keyData = manufacturerData.sublist(0, 4);
      final key = ascii.decode(keyData);
      final typeValue = deviceKeyToTypes[key];
      if (typeValue == null) {
        return;
      }
      type = typeValue;
      macAddress = manufacturerData.sublist(4, 10);
      // final flag = manufacturerData[10];
    } else {
      return;
    }
    final peripheral = eventArgs.peripheral;
    final devices = _devices.value;
    final index = devices.indexWhere((i) => i.peripheral == peripheral);
    if (index < 0) {
      const state = ConnectionState.disconnected;
      final device = DeviceViewModel(
        type: type,
        macAddress: macAddress,
        name: name,
        peripheral: peripheral,
        rssi: rssi,
        state: state,
      );
      devices.add(device);
      _devices.value = [...devices];
    } else {
      final device = devices[index];
      device.peripheral = peripheral;
      device.rssi.value = rssi;
    }
  }

  void onPeripheralStateChanged(PeripheralStateChangedEventArgs eventArgs) {
    final peripheral = eventArgs.peripheral;
    final state = eventArgs.state;
    final devices = this.devices.value;
    final index = devices.indexWhere((i) => i.peripheral == peripheral);
    if (index < 0) {
      return;
    }
    final device = devices[index];
    if (state) {
      return;
    } else {
      device.state.value = ConnectionState.disconnected;
    }
  }

  Future<void> startDiscovery() async {
    await _manager.startDiscovery();
    _discovering.value = true;
  }

  Future<void> stopDiscovery() async {
    await _manager.stopDiscovery();
    _discovering.value = false;
  }

  Future<void> connect(DeviceViewModel device) async {
    device.state.value = ConnectionState.connecting;
    try {
      final configuration =
          deviceTypeToBluetoothLowEnergyConfigurations[device.type];
      if (configuration == null) {
        throw ArgumentError.notNull();
      }
      final peripheral = device.peripheral;
      await _manager.connect(peripheral);
      try {
        const timeLimit = Duration(seconds: 3);
        final services =
            await _manager.discoverGATT(peripheral).timeout(timeLimit);
        final service = services.firstWhere(
            (i) => i.uuid == configuration.communicationServiceUUID);
        final characteristics = service.characteristics;
        final notifyCharacteristic = characteristics.firstWhere(
            (i) => i.uuid == configuration.notifyCharacteristicUUID);
        final writeCharacteristic = characteristics
            .firstWhere((i) => i.uuid == configuration.writeCharacteristicUUID);
        device.notifyCharacteristic = notifyCharacteristic;
        device.writeCharacteristic = writeCharacteristic;
        device.maximumWriteLength = await _manager.getMaximumWriteLength(
          peripheral,
          type: _type,
        );
        log('maximumWriteLength: ${device.maximumWriteLength}');
        const lineTransformer = LineTransformer();
        _characteristicValueChangedSubscriptions[device] = _manager
            .characteristicValueChanged
            .where(
                (eventArgs) => eventArgs.characteristic == notifyCharacteristic)
            .map((eventArgs) => eventArgs.value)
            .transform(lineTransformer)
            .listen((value) async {
          try {
            final command = utf8.decode(value).toLowerCase();
            if (command == 'code?') {
              final replyValue = utf8.encode('@LE_TEST');
              final reply = Uint8List.fromList(replyValue);
              await write(device, reply);
            }
          } catch (e) {
            log('error: $e');
          }
        });
        await _manager.notifyCharacteristic(
          notifyCharacteristic,
          state: true,
        );
        device.state.value = ConnectionState.connected;
      } catch (e) {
        _manager.disconnect(peripheral).ignore();
        rethrow;
      }
    } catch (e) {
      log('$e');
      device.state.value = ConnectionState.disconnected;
    }
  }

  Future<void> disconnect(DeviceViewModel device) async {
    final subscription =
        _characteristicValueChangedSubscriptions.remove(device);
    if (subscription == null) {
      throw ArgumentError.notNull();
    }
    subscription.cancel();
    final peripheral = device.peripheral;
    await _manager.disconnect(peripheral);
    device.state.value = ConnectionState.disconnected;
  }

  void beginWriteContinuously(DeviceViewModel device) async {
    final writeContinuously = device.writeContinuously.value;
    if (writeContinuously) {
      throw ArgumentError();
    }
    device.writeContinuously.value = true;
    final Directory dir;
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw UnimplementedError();
      }
      dir = externalDir;
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    final type = device.type.name;
    final macAddress = hex.encode(device.macAddress);
    final now = DateTime.now();
    final time = DateFormat('yyyyMMddHHmmss').format(now);
    final path = join(
      dir.path,
      '$type-$macAddress-$time.csv',
    );
    final csv = CSV(path);
    await csv.write(['时间', '连接状态', '大小/Byte', '耗时/ms']);
    final watch = Stopwatch();
    final cts = CTS();
    device.writeContinuouslyCTS = cts;
    while (!cts.cancelled) {
      try {
        watch.start();
        const timeLimit = Duration(seconds: 3);
        final replyArgs = await execute(
          device: device,
          commandName: 'DATA:LIVe:ECHO?',
        ).timeout(timeLimit);
        final elapsed = watch.elapsed.inMilliseconds;
        final time = DateTime.now().toIso8601String();
        final state = device.state.value;
        final data = replyArgs[1];
        final length = data.length;
        await csv.write([time, '$state', '$length', '$elapsed']);
      } catch (e) {
        final state = device.state.value;
        final elapsed = watch.elapsed.inMilliseconds;
        final time = DateTime.now().toIso8601String();
        await csv.write([time, '$state', '$e', '$elapsed']);
        if (state != ConnectionState.connected) {
          try {
            await connect(device);
            continue;
          } catch (e) {
            log('$e');
          }
          break;
        }
      } finally {
        watch.stop();
        watch.reset();
      }
    }
    device.writeContinuously.value = false;
  }

  void endWriteContinuously(DeviceViewModel device) {
    final writeContinuously = device.writeContinuously.value;
    if (!writeContinuously) {
      throw ArgumentError();
    }
    device.writeContinuouslyCTS.cancel();
  }

  Future<List<String>> execute({
    required DeviceViewModel device,
    required String commandName,
    List<String> commandArgs = const [],
  }) async {
    final command = commandArgs.isEmpty
        ? commandName
        : '$commandName ${commandArgs.join(',')}';
    final elements = utf8.encode(command);
    final value = Uint8List.fromList(elements);
    final completer = Completer<List<String>>();
    onStateChanged() {
      final state = device.state.value;
      if (state == ConnectionState.connected || completer.isCompleted) {
        return;
      }
      final error = StateError('$state');
      completer.completeError(error);
    }

    device.state.addListener(onStateChanged);
    const lineTransformer = LineTransformer();
    const replyTransformer = ScpiReplyTransformer();
    final subscription = _manager.characteristicValueChanged
        .where((eventArgs) =>
            eventArgs.characteristic == device.notifyCharacteristic)
        .map((eventArgs) => eventArgs.value)
        .transform(lineTransformer)
        .transform(replyTransformer)
        .listen((reply) {
      if (completer.isCompleted) {
        return;
      }
      if (reply.name != commandName) {
        return;
      }
      if (reply.ok) {
        completer.complete(reply.args);
      } else {
        final message = reply.args.length < 2
            ? '$commandName failed without description.'
            : reply.args[1];
        final error = ArgumentError(message);
        completer.completeError(error);
      }
    });
    write(device, value).onError<Object>((error, stackTrace) {
      if (completer.isCompleted) {
        return;
      }
      completer.completeError(error, stackTrace);
    });
    try {
      final replyArgs = await completer.future;
      return replyArgs;
    } finally {
      device.state.removeListener(onStateChanged);
      subscription.cancel();
    }
  }

  Future<void> write(DeviceViewModel device, Uint8List data) async {
    device.writing.value = true;
    final characteristic = device.writeCharacteristic;
    final maximumWriteLength = device.maximumWriteLength;
    final value = Uint8List.fromList([...data, 0x0A]);
    var start = 0;
    while (start < value.length) {
      final end = start + maximumWriteLength;
      final trimmedValue =
          end < value.length ? value.sublist(start, end) : value.sublist(start);
      await _manager.writeCharacteristic(
        characteristic,
        value: trimmedValue,
        type: _type,
      );
      start = end;
    }
    device.writing.value = false;
    // final text = ascii.decode(data);
    // log('written: $text');
  }

  @override
  void dispose() {
    super.dispose();
    if (discovering.value) {
      _manager.stopDiscovery().ignore();
    }
    _discoveredSubscription.cancel();
    _peripheralStateChangedSubscription.cancel();
    for (var subscription in _characteristicValueChangedSubscriptions.values) {
      subscription.cancel();
    }
    for (var device in devices.value) {
      device.dispose();
    }
    _devices.dispose();
    _discovering.dispose();
  }
}
