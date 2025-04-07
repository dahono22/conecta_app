import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import 'perfil_controller.dart';
import '../../services/offer_application_service.dart';
import '../../services/offer_service.dart';
import '../../models/oferta.dart';

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

  Widget _buildOfertesAplicades(BuildContext context) {
    final offerService = Provider.of<OfferService>(context);
    final applicationService = Provider.of<OfferApplicationService>(context);
    final ofertesAplicades = offerService.ofertes.where((oferta) {
      return applicationService.jaAplicada(oferta.id);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ofertes aplicades:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (ofertesAplicades.isEmpty)
          const Text('Encara no has aplicat a cap oferta.')
        else
          Column(
            children: ofertesAplicades.map((oferta) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      oferta.titol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${oferta.empresa} - ${oferta.ubicacio}'),
                  ],
                ),
              ),
            )).toList(),
          ),
      ],
    );
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
                    ? 'Perfil de l\'estudiant'
                    : 'Perfil de l\'empresa',
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
                    labelText: 'Descripció de l\'empresa',
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
              if (!isEmpresa) ...[
                const SizedBox(height: 24),
                Consumer<OfferApplicationService>(
                  builder: (context, applicationService, _) {
                    return _buildOfertesAplicades(context);
                  },
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
