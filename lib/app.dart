import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

// Point d'entrée principal de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Thème global de l'application
      theme: ThemeData(primarySwatch: Colors.teal),
      // Écran affiché par défaut (peut être surchargé par initialRoute)
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // Cache le bandeau debug
      // Route initiale selon l'état de connexion de l'utilisateur
      initialRoute: Supabase.instance.client.auth.currentUser == null
          ? '/login'  // Non connecté -> écran de login
          : '/home',  // Connecté -> écran d'accueil
      // Définition des routes nommées pour la navigation
      routes: {
        '/login': (_) => const LoginScreen(),      // Écran de connexion
        '/register': (_) => const RegisterScreen(),// Écran d'inscription
        '/home': (_) => const HomeScreen(),        // Écran d'accueil principal
      },
    );
  }
}
