import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  RolUsuari? _rolSeleccionat;
  String? _errorText;

  void _registrarUsuari() {
    if (!_formKey.currentState!.validate() || _rolSeleccionat == null) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = authService.registre(
      _nomController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _rolSeleccionat!,
    );

    if (success) {
      final rol = authService.usuariActual!.rol;
      final ruta = rol == RolUsuari.estudiant
          ? AppRoutes.homeEstudiant
          : AppRoutes.homeEmpresa;
      Navigator.pushReplacementNamed(context, ruta);
    } else {
      setState(() {
        _errorText = 'Aquest email ja està registrat';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorText != null)
                Text(_errorText!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correu electrònic'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contrasenya'),
                validator: (value) =>
                    value == null || value.length < 6
                        ? 'Minim 6 caràcters'
                        : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RolUsuari>(
                value: _rolSeleccionat,
                items: RolUsuari.values.map((rol) {
                  return DropdownMenuItem(
                    value: rol,
                    child: Text(
                        rol == RolUsuari.estudiant ? 'Estudiant' : 'Empresa'),
                  );
                }).toList(),
                hint: const Text('Selecciona rol'),
                onChanged: (value) => setState(() {
                  _rolSeleccionat = value;
                }),
                validator: (value) =>
                    value == null ? 'Has de seleccionar un rol' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _registrarUsuari,
                child: const Text('Registrar-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
