import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sessió'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            TextField(
              decoration: InputDecoration(labelText: 'Correu electrònic'),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contrasenya'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: null, // Encara no fa res
              child: Text('Iniciar Sessió'),
            ),
          ],
        ),
      ),
    );
  }
}
