import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  Future<void> _register() async {
    setState(() {
      _isLoading = true; // Affiche un loader lors de l'inscription
    });

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('Response: user=${response.user}, session=${response.session}');

      if (response.user != null) {
        // Inscription réussie : message de confirmation et retour à la connexion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compte créé avec succès ! Vérifie ton email.')),
        );
        Navigator.of(context).pop();
      } else if (response.session == null) {
        // Cas d'erreur sans exception spécifique
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue lors de l’inscription.')),
        );
      }
    } on AuthException catch (e) {
      // Gestion des erreurs d'authentification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      // Gestion des erreurs inattendues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inconnue : $e')),
      );
    }

    setState(() {
      _isLoading = false; // Cache le loader après tentative d'inscription
    });
  }

  @override
  void dispose() {
    _emailController.dispose(); // Libère les ressources des controllers
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'), // Titre de la page
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Padding autour du formulaire
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress, // Clavier adapté email
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true, // Cache le texte pour le mot de passe
            ),
            const SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator() // Loader quand en attente
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Créer un compte'), // Bouton inscription
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Retour à l'écran de connexion
              },
              child: const Text('Déjà inscrit ? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
