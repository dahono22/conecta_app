import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import 'perfil_controller.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late PerfilController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PerfilController(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEmpresa = _controller.rol == RolUsuari.empresa;

    return Scaffold(
      appBar: AppBar(title: const Text('El meu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                _controller.rol == RolUsuari.estudiant
                    ? 'Perfil de l’estudiant'
                    : 'Perfil de l’empresa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controller.nomController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.emailController,
                decoration: const InputDecoration(labelText: 'Correu electrònic'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              if (isEmpresa) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _controller.descripcioController,
                  decoration: const InputDecoration(
                    labelText: 'Descripció de l’empresa',
                    hintText: 'Ex: Som una startup dedicada a...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aquest text serà visible per als estudiants.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _controller.guardarCanvis(_formKey),
                child: const Text('Desar canvis'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
