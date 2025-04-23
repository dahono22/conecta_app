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
  bool _isSubmitting = false;

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Registre'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: _inputDecoration('Nom complet'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Correu electrònic'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration('Contrasenya'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RolUsuari>(
                value: _rol,
                decoration: _inputDecoration('Rol'),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cvUrlController,
                  decoration: _inputDecoration(
                    'Enllaç al CV (opcional)',
                    hint: 'https://drive.google.com/...',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasAbsolutePath) {
                        return 'L’enllaç no és vàlid.';
                      }
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() => _isSubmitting = true);

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
                        setState(() => _isSubmitting = false);

                        if (success) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aquest email ja està registrat')),
                          );
                        }
                      },
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.person_add),
                label: Text(_isSubmitting ? 'Registrant...' : 'Registrar-se'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
