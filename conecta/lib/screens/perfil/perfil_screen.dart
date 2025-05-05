// Importació de paquets essencials per la pantalla de perfil
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importació de serveis i models personalitzats del projecte
import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import 'perfil_controller.dart';
import '../../services/offer_application_service.dart';

// Widget principal de la pantalla de perfil (tant per empresa com per estudiant)
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Clau global per al formulari, per poder validar i desar
  final _formKey = GlobalKey<FormState>();

  // Controlador que gestiona l'estat i la lògica del perfil
  late PerfilController _controller;

  // Futur per carregar les aplicacions del perfil (usuaris estudiants)
  late Future<void> _carregarAplicacionsFuture;

  @override
  void initState() {
    super.initState();

    // Inicialitza el controlador amb el context per accedir a serveis i dades
    _controller = PerfilController(context);

    // Obté l'identificador de l'usuari actual a través del servei d'autenticació
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.usuariActual?.id;

    // Si hi ha un usuari autenticat, es carreguen les seves aplicacions (estudiant)
    _carregarAplicacionsFuture = userId != null
        ? Provider.of<OfferApplicationService>(context, listen: false)
            .carregarAplicacions(userId)
        : Future.value(); // Si no hi ha usuari, retorna un futur buit
  }

  // Mètode per generar decoració coherent per als camps de formulari
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

  // Construeix la secció visual de les ofertes aplicades per l'estudiant
  Widget _buildOfertesAplicadesFirestore(BuildContext context, List<String> ofertaIds) {
    // Obté l'identificador de l'usuari per consultar les seves aplicacions
    final usuariId = context.read<AuthService>().usuariActual!.id;

    // Primer es carreguen les ofertes corresponents als identificadors passats
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

        // Ara es carreguen les aplicacions de l'usuari per mostrar estat
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

            // Mostra la llista d'ofertes aplicades amb l'estat de cada aplicació
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

                  // Troba l'aplicació que correspon a aquesta oferta concreta
                  QueryDocumentSnapshot? aplicacio;
                  try {
                    aplicacio = aplicacions.firstWhere((a) => a['ofertaId'] == ofertaId);
                  } catch (_) {
                    aplicacio = null;
                  }

                  // Si no es troba estat, es mostra com a "Nou"
                  final estat = (aplicacio?.data() as Map<String, dynamic>?)?['estat'] ?? 'Nou';

                  // Targeta visual amb la informació de l'oferta i l'estat de l'aplicació
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
    // Obté les dades de l'usuari i determina si és empresa o estudiant
    final usuari = context.watch<AuthService>().usuariActual!;
    final isEmpresa = usuari.rol == RolUsuari.empresa;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('El meu perfil'),
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
              // Títol segons el rol d'usuari
              Text(
                isEmpresa ? 'Perfil de l\'empresa' : 'Perfil de l\'estudiant',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              // Camp de text per al nom complet
              TextFormField(
                controller: _controller.nomController,
                decoration: _inputDecoration('Nom complet'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),
              const SizedBox(height: 16),

              // Camp de text per al correu electrònic
              TextFormField(
                controller: _controller.emailController,
                decoration: _inputDecoration('Correu electrònic'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Camp obligatori' : null,
              ),

              // Camps addicionals només visibles per empreses
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

              // Camps per a estudiants: URL del currículum
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

                // Mostra una icona de confirmació si ja hi ha un CV penjat
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

              // Bloc de llistat d'ofertes aplicades per l'estudiant
              if (!isEmpresa) ...[
                const SizedBox(height: 24),
                FutureBuilder(
                  future: _carregarAplicacionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      final ids =
                          context.read<OfferApplicationService>().idsAplicades;
                      if (ids.isEmpty) {
                        return const Text('Encara no has aplicat a cap oferta.');
                      }
                      return _buildOfertesAplicadesFirestore(context, ids);
                    }
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Botó per desar els canvis realitzats al perfil
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
    );
  }
}