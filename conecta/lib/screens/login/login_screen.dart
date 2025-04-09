import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../models/usuari.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  void _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success == true) {
      final rol = authService.usuariActual?.rol;
      final ruta = rol == RolUsuari.empresa
          ? AppRoutes.homeEmpresa
          : AppRoutes.homeEstudiant;
      Navigator.pushReplacementNamed(context, ruta);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_errorText != null)
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contrasenya'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.register);
              },
              child: const Text("No tens compte? Registra't"),
            ),
          ],
        ),
      ),
    );
  }
}
