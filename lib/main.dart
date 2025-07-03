import 'package:flutter/material.dart';
import 'app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // DB
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

    WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gdbjqixphxgwlwnpwxbb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkYmpxaXhwaHhnd2x3bnB3eGJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTY0NTIsImV4cCI6MjA2NzAzMjQ1Mn0.CZb7OisjVAuS-iJ_0ZoVT4tz3nvUG-XQ47WEpPHFaZ4',
  );

  runApp(MyApp());
}
