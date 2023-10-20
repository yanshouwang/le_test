import 'dart:async';
import 'dart:developer';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'views.dart';

void main() {
  runZonedGuarded(onStartUp, onUnhandledError);
}

void onStartUp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CentralManager.instance.setUp();
  await WakelockPlus.enable();
  runApp(const MyApp());
}

void onUnhandledError(Object error, StackTrace stackTrace) {
  log(
    'An unhandled error occured.',
    error: error,
    stackTrace: stackTrace,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LE Test',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const HomeView(),
    );
  }
}
