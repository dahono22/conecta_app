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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _authError;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _authError = null;
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success == true) {
      final rol = authService.usuariActual?.rol;
      final ruta = rol == RolUsuari.empresa
          ? AppRoutes.homeEmpresa
          : AppRoutes.homeEstudiant;
      Navigator.pushReplacementNamed(context, ruta);
    } else {
      setState(() {
        _authError = 'Credencials incorrectes';
      });
    }
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent),
    labelStyle: const TextStyle(color: Colors.grey),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Capa de oscurecimiento
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo2.png',
                        width: 250,
                        height: 150,
                      ),
                      const SizedBox(height: 30),
                      if (_authError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _authError!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration('Email'),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Camp obligatori'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _inputDecoration('Contrasenya'),
                        obscureText: true,
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Camp obligatori'
                                : null,
                      ),
                      const SizedBox(height: 24),
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
            ),
          ),
        ],
      ),
    );
  }
}
