import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  void _iniciarSessio() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authService = Provider.of<AuthService>(context, listen: false);
    final ok = authService.login(email, password);

    if (ok) {
      final rol = authService.usuariActual!.rol;
      if (rol == RolUsuari.estudiant) {
        Navigator.pushReplacementNamed(context, '/home_estudiant');
      } else {
        Navigator.pushReplacementNamed(context, '/home_empresa');
      }
    } else {
      setState(() {
        _errorText = 'Credencials incorrectes';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sessió')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorText != null)
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correu electrònic'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contrasenya'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _iniciarSessio,
              child: const Text('Iniciar Sessió'),
            ),
          ],
        ),
      ),
    );
  }
}
