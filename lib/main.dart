// Pour les dépendances voir pubspec.yaml

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init DB
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Init Window Manager
  await windowManager.ensureInitialized();

  // Start app
  runApp(const MyApp());

  // Rename Window
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('Noted');
    await windowManager.show();
  });
}
