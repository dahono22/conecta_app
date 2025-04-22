import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/usuari.dart';

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
  final _cvUrlController = TextEditingController();

  RolUsuari _rol = RolUsuari.estudiant;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Registre')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correu electrònic'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contrasenya'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RolUsuari>(
                value: _rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: RolUsuari.values.map((rol) {
                  return DropdownMenuItem(
                    value: rol,
                    child: Text(rol.name),
                  );
                }).toList(),
                onChanged: (rol) {
                  setState(() {
                    _rol = rol!;
                  });
                },
              ),
              if (_rol == RolUsuari.estudiant) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cvUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Enllaç al CV (opcional)',
                    hintText: 'https://drive.google.com/...',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    final uri = Uri.tryParse(value ?? '');
                    if (value != null && value.isNotEmpty && (uri == null || !uri.hasAbsolutePath)) {
                      return 'L’enllaç no és vàlid.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final success = await authService.registre(
                    _nomController.text.trim(),
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _rol,
                    cvUrl: _rol == RolUsuari.estudiant
                        ? _cvUrlController.text.trim()
                        : null,
                  );

                  if (!mounted) return;

                  if (success) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aquest email ja està registrat')),
                    );
                  }
                },
                child: const Text('Registrar-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
