// lib/screens/register/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';

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
  String? _interestsError;
  List<String> _selectedInterests = [];

  // 👁 Controla si se muestra o no la contraseña
  bool _mostrarContrasenya = false;

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

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 3) {
        _selectedInterests.add(interest);
      }
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rol == RolUsuari.estudiant && _selectedInterests.isEmpty) {
      setState(() => _interestsError = 'Selecciona entre 1 i 3 interessos.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
      _interestsError = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nom = _nomController.text.trim();
    final cvUrl = _rol == RolUsuari.estudiant ? _cvUrlController.text.trim() : null;

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final nouUsuari = Usuari(
        id: cred.user!.uid,
        nom: nom,
        email: email,
        contrasenya: '',
        rol: _rol,
        descripcio: '',
        cvUrl: cvUrl,
        intereses: _rol == RolUsuari.estudiant ? _selectedInterests : [],
      );

      await authService.desarUsuariFirestore(nouUsuari);
      authService.usuariActual = nouUsuari;
      authService.listenCanvisUsuari(nouUsuari.id);

      if (!mounted) return;

      final ruta = nouUsuari.rol == RolUsuari.empresa
          ? AppRoutes.homeEmpresa
          : AppRoutes.homeEstudiant;

      Navigator.of(context).pushReplacementNamed(ruta);
    } on FirebaseAuthException catch (e) {
      String missatge = 'Error al registrar-se.';
      if (e.code == 'email-already-in-use') {
        missatge = 'Aquest email ja està registrat.';
      } else if (e.code == 'invalid-email') {
        missatge = 'El correu electrònic no és vàlid.';
      } else if (e.code == 'weak-password') {
        missatge = 'La contrasenya és massa dèbil (mínim 6 caràcters).';
      }

      setState(() {
        _errorText = missatge;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Error inesperat: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo3.png',
                          width: 200,
                          height: 120,
                        ),
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
                        obscureText: !_mostrarContrasenya,
                        decoration: _inputDecoration('Contrasenya').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _mostrarContrasenya
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _mostrarContrasenya = !_mostrarContrasenya;
                              });
                            },
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.length < 6
                                ? 'Mínim 6 caràcters'
                                : null,
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
                            _selectedInterests.clear();
                          });
                        },
                      ),
                      if (_rol == RolUsuari.estudiant) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Selecciona fins a 3 interessos:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: Constants.camposDisponibles.map((campo) {
                            final selected = _selectedInterests.contains(campo);
                            return FilterChip(
                              label: Text(campo),
                              selected: selected,
                              onSelected: (_) => _toggleInterest(campo),
                            );
                          }).toList(),
                        ),
                        if (_interestsError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _interestsError!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
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
                      Center(
                        child: ElevatedButton.icon(
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
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          child: const Text(
                            'Ja tens compte? Inicia sessió',
                            style: TextStyle(fontSize: 14),
                          ),
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
