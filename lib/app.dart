import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
