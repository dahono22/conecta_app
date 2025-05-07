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
  String? _errorText;

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    final success = await authService.registre(
      _nomController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _rol,
      cvUrl: _rol == RolUsuari.estudiant ? _cvUrlController.text.trim() : null,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      setState(() {
        _errorText = 'Aquest email ja està registrat';
      });
    }
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
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo3.png',
                        width: 200,
                        height: 120,
                      ),
                      const SizedBox(height: 16),
                      if (_errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _nomController,
                        decoration: _inputDecoration('Nom complet'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Camp obligatori' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration('Correu electrònic'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Camp obligatori' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _inputDecoration('Contrasenya'),
                        obscureText: true,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Camp obligatori' : null,
                      ),
                      const SizedBox(height: 10),
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
                        const SizedBox(height: 10),
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
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitForm,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.person_add),
                        label: Text(_isSubmitting ? 'Registrant...' : 'Registrar-se'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Text(
                          'Ja tens compte? Inicia sessió',
                          style: TextStyle(fontSize: 14),
                        ),
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
