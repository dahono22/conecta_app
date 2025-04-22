import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import 'perfil_controller.dart';
import '../../services/offer_application_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late PerfilController _controller;
  late Future<void> _carregarAplicacionsFuture;

  @override
  void initState() {
    super.initState();
    _controller = PerfilController(context);

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.usuariActual?.id;

    _carregarAplicacionsFuture = userId != null
        ? Provider.of<OfferApplicationService>(context, listen: false)
            .carregarAplicacions(userId)
        : Future.value();
  }

  Widget _buildOfertesAplicadesFirestore(BuildContext context, List<String> ofertaIds) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ofertes')
          .where(FieldPath.documentId, whereIn: ofertaIds)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text('Encara no has aplicat a cap oferta.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ofertes aplicades:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['titol'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${data['empresa'] ?? ''} - ${data['ubicacio'] ?? ''}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuari = context.watch<AuthService>().usuariActual!;
    final isEmpresa = usuari.rol == RolUsuari.empresa;

    return Scaffold(
      appBar: AppBar(title: const Text('El meu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                isEmpresa ? 'Perfil de l\'empresa' : 'Perfil de l\'estudiant',
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
                const Text('Currículum (enllaç URL):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller.cvUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Enllaç al CV (Drive, Dropbox...)',
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !Uri.tryParse(value)!.hasAbsolutePath) {
                      return 'L\'enllaç no és vàlid.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                if (usuari.cvUrl != null && usuari.cvUrl!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('Enllaç actual:'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        tooltip: 'Veure CV',
                        onPressed: () async {
                          final uri = Uri.parse(usuari.cvUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  )
                else
                  const Text('Encara no has afegit cap enllaç de currículum.'),
              ],
              if (!isEmpresa) ...[
                const SizedBox(height: 24),
                FutureBuilder(
                  future: _carregarAplicacionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      final ids = context.read<OfferApplicationService>().idsAplicades;
                      if (ids.isEmpty) {
                        return const Text('Encara no has aplicat a cap oferta.');
                      }
                      return _buildOfertesAplicadesFirestore(context, ids);
                    }
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