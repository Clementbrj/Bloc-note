import 'package:flutter/material.dart';
import 'app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // DB
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}
