import 'package:flutter/material.dart';
import 'app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

// Pour les dépendances voir pubspec.yaml

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
    url: 'https://gdbjqixphxgwlwnpwxbb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkYmpxaXhwaHhnd2x3bnB3eGJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTY0NTIsImV4cCI6MjA2NzAzMjQ1Mn0.CZb7OisjVAuS-iJ_0ZoVT4tz3nvUG-XQ47WEpPHFaZ4',
  );

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
