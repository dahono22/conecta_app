import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../models/usuari.dart';

// Widget d'estat per controlar els canvis durant el procés de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Clau per validar el formulari
  final _emailController = TextEditingController(); // Controlador per al camp email
  final _passwordController = TextEditingController(); // Controlador per al camp contrasenya
  bool _isLoading = false; // Indica si s'està fent login
  String? _authError; // Missatge d'error en cas de credencials incorrectes

  // Funció per gestionar l'autenticació de l'usuari
  void _login() async {
    if (!_formKey.currentState!.validate()) return; // Valida el formulari

    setState(() {
      _authError = null;
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false); // Para l'indicador de càrrega

    if (success == true) {
      // Redirecciona segons el rol de l'usuari
      final rol = authService.usuariActual?.rol;
      final ruta = rol == RolUsuari.empresa
          ? AppRoutes.homeEmpresa
          : AppRoutes.homeEstudiant;
      Navigator.pushReplacementNamed(context, ruta); // Canvia a la pantalla principal
    } else {
      setState(() {
        _authError = 'Credencials incorrectes'; // Mostra error si el login ha fallat
      });
    }
  }

  // Decoració reutilitzable per als camps de text
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Fons suau
      appBar: AppBar(
        title: const Text('Iniciar Sessió'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Mostra error si les credencials són incorrectes
              if (_authError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_authError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              // Camp de correu electrònic
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              // Camp de contrasenya
              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration('Contrasenya'),
                obscureText: true, // Amaga el text introduït
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 24),
              // Botó de login amb indicador de càrrega
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _login,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(_isLoading ? 'Entrant...' : 'Entrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Enllaç per anar a la pantalla de registre
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: const Text("No tens compte? Registra't"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
