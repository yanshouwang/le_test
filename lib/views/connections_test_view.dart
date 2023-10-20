import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:le_test/models.dart';
import 'package:le_test/util.dart';
import 'package:le_test/view_models.dart';
import 'package:le_test/widgets.dart';

class ConnectionsTestView extends StatefulWidget {
  const ConnectionsTestView({super.key});

  @override
  State<ConnectionsTestView> createState() => _ConnectionsTestViewState();
}

class _ConnectionsTestViewState extends State<ConnectionsTestView> {
  late final ConnectionsTestViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ConnectionsTestViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections Test'),
        actions: [
          ValueListenableBuilder(
            valueListenable: viewModel.discovering,
            builder: (context, discovering, child) {
              return TextButton(
                onPressed: () {
                  if (discovering) {
                    viewModel.stopDiscovery();
                  } else {
                    viewModel.startDiscovery();
                  }
                },
                child: Text(discovering ? 'END' : 'BEGIN'),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: viewModel.devices,
        builder: (context, devices, child) {
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              final device = devices[i];
              final macAddress = device.macAddress.toStringAsMAC();
              final rssi = device.rssi;
              final name = device.name;
              final state = device.state;
              final writing = device.writing;
              final writeContinuously = device.writeContinuously;
              return Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name),
                                  const SizedBox(width: 8.0),
                                  ValueListenableBuilder(
                                    valueListenable: state,
                                    builder: (context, state, child) {
                                      return ValueListenableBuilder(
                                        valueListenable: writing,
                                        builder: (context, writing, child) {
                                          return CommunicationStateIndicator(
                                            state: state,
                                            writing: writing,
                                            size: const Size.square(16.0),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Text(macAddress),
                            ],
                          ),
                          ValueListenableBuilder(
                            valueListenable: rssi,
                            builder: (context, rssi, child) {
                              return Text('$rssi');
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 0,
                      thickness: 0.5,
                    ),
                    SizedBox(
                      height: 40.0,
                      child: Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: state,
                              builder: (context, state, child) {
                                final text =
                                    state == ConnectionState.disconnected
                                        ? 'CONNECT'
                                        : 'DISCONNECT';
                                return TextButton(
                                  onPressed: state == ConnectionState.connecting
                                      ? null
                                      : () {
                                          if (state ==
                                              ConnectionState.disconnected) {
                                            viewModel.connect(device);
                                          } else {
                                            viewModel.disconnect(device);
                                          }
                                        },
                                  style: TextButton.styleFrom(
                                    shape: const LinearBorder(),
                                  ),
                                  child: Text(text),
                                );
                              },
                            ),
                          ),
                          const VerticalDivider(
                            width: 0,
                            thickness: 0.5,
                          ),
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: state,
                              builder: (context, state, child) {
                                return ValueListenableBuilder(
                                  valueListenable: writeContinuously,
                                  builder: (context, writeContinuously, child) {
                                    final text =
                                        writeContinuously ? 'END' : 'BEGIN';
                                    return TextButton(
                                      onPressed: state !=
                                              ConnectionState.connected
                                          ? null
                                          : () {
                                              if (writeContinuously) {
                                                viewModel.endWriteContinuously(
                                                    device);
                                              } else {
                                                viewModel
                                                    .beginWriteContinuously(
                                                        device);
                                              }
                                            },
                                      style: TextButton.styleFrom(
                                        shape: const LinearBorder(),
                                      ),
                                      child: Text(text),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, i) {
              return const SizedBox(
                height: 16.0,
              );
            },
            itemCount: devices.length,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }
}

extension on Uint8List {
  String toStringAsMAC() {
    final value = hex.encode(this);
    return StringFormatter.formatMAC(value);
  }
}
