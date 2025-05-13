// Importació de paquets essencials per la pantalla de perfil
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import '../../routes/app_routes.dart'; // ← Afegeix aquesta línia
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

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  Widget _buildOfertesAplicadesFirestore(BuildContext context, List<String> ofertaIds) {
    final usuariId = context.read<AuthService>().usuariActual!.id;
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('ofertes')
          .where(FieldPath.documentId, whereIn: ofertaIds)
          .get(),
      builder: (context, snapshotOfertes) {
        if (!snapshotOfertes.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docsOfertes = snapshotOfertes.data!.docs;
        if (docsOfertes.isEmpty) {
          return const Text('Encara no has aplicat a cap oferta.');
        }
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('aplicacions')
              .where('usuariId', isEqualTo: usuariId)
              .get(),
          builder: (context, snapshotAplicacions) {
            if (!snapshotAplicacions.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final aplicacions = snapshotAplicacions.data!.docs;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ofertes aplicades:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...docsOfertes.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ofertaId = doc.id;
                  QueryDocumentSnapshot? aplicacio;
                  try {
                    aplicacio = aplicacions.firstWhere((a) => a['ofertaId'] == ofertaId);
                  } catch (_) {
                    aplicacio = null;
                  }
                  final estat = (aplicacio?.data() as Map<String, dynamic>?)?['estat'] ?? 'Nou';
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['titol'] ?? '',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('${data['empresa'] ?? ''} - ${data['ubicacio'] ?? ''}'),
                          const SizedBox(height: 4),
                          Text('Estat de la candidatura: $estat',
                              style: const TextStyle(color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuari = context.watch<AuthService>().usuariActual!;
    final isEmpresa = usuari.rol == RolUsuari.empresa;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
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
                    children: [
                      // ← Botó tornar enrere, porta a home segons rol
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
                          onPressed: () {
                            final ruta = isEmpresa
                              ? AppRoutes.homeEmpresa
                              : AppRoutes.homeEstudiant;
                            Navigator.pushReplacementNamed(context, ruta);
                          },
                          tooltip: 'Tornar',
                        ),
                      ),

                      Text(
                        isEmpresa ? 'Perfil de l\'empresa' : 'Perfil de l\'estudiant',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _controller.nomController,
                        decoration: _inputDecoration('Nom complet'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Camp obligatori' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _controller.emailController,
                        decoration: _inputDecoration('Correu electrònic'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Camp obligatori' : null,
                      ),
                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        onPressed: () => _controller.enviarVerificacioANouCorreu(),
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Verificar nou correu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      if (isEmpresa) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controller.descripcioController,
                          decoration: _inputDecoration(
                            'Descripció de l\'empresa',
                            hint: 'Ex: Som una startup dedicada a...',
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
                        const Text('Currículum (enllaç URL):',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _controller.cvUrlController,
                          decoration: _inputDecoration(
                            'Enllaç al CV (Drive, Dropbox...)',
                            hint: 'https://...',
                          ),
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final uri = Uri.tryParse(value);
                              if (uri == null || !uri.hasAbsolutePath) {
                                return 'L\'enllaç no és vàlid.';
                              }
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
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
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
                            }
                            final ids =
                                context.read<OfferApplicationService>().idsAplicades;
                            if (ids.isEmpty) {
                              return const Text('Encara no has aplicat a cap oferta.');
                            }
                            return _buildOfertesAplicadesFirestore(context, ids);
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: () => _controller.guardarCanvis(_formKey),
                        icon: const Icon(Icons.save),
                        label: const Text('Desar canvis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
            ),
          ),
        ],
      ),
    );
  }
}
