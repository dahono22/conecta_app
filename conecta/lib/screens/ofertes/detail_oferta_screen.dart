// lib/screens/ofertes/detail_oferta_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/offer_application_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class DetailOfertaScreen extends StatefulWidget {
  const DetailOfertaScreen({super.key});

  @override
  State<DetailOfertaScreen> createState() => _DetailOfertaScreenState();
}

class _DetailOfertaScreenState extends State<DetailOfertaScreen> {
  late Future<void> _loadAppsFuture;
  late String _ofertaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ofertaId = ModalRoute.of(context)!.settings.arguments as String;
    final authService = Provider.of<AuthService>(context, listen: false);
    _loadAppsFuture = Provider.of<OfferApplicationService>(
      context,
      listen: false,
    ).carregarAplicacions(authService.usuariActual!.id);
  }

  Future<void> _mostrarDialogAplicacio(
    BuildContext context,
    String idOferta,
    String titolOferta,
  ) async {
    final applicationService =
        Provider.of<OfferApplicationService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final usuari = authService.usuariActual!;
    final jaAplicada = await applicationService.jaAplicadaFirestore(
      usuariId: usuari.id,
      ofertaId: idOferta,
    );
    if (jaAplicada) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ja has aplicat a aquesta oferta.")),
        );
      }
      return;
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<OfferApplicationService>(
          builder: (context, applicationService, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Confirmar aplicació'),
              content: Text('Vols aplicar a l\'oferta "$titolOferta"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel·lar'),
                ),
                ElevatedButton(
                  onPressed: applicationService.loading
                      ? null
                      : () async {
                          try {
                            applicationService.setLoading(true);
                            await applicationService.aplicarAOferta(
                              usuari.id,
                              idOferta,
                              cvUrl: usuari.cvUrl,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Has aplicat correctament.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop(true);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(applicationService.error ??
                                      'Error inesperat.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            applicationService.setLoading(false);
                          }
                        },
                  child: applicationService.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadAppsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4F7FA),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Fons
              Image.asset('assets/background.png', fit: BoxFit.cover),
              Container(color: Colors.black.withOpacity(0.5)),
              SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ofertes')
                          .doc(_ofertaId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: Text('Oferta no trobada.'));
                        }
                        final data =
                            snapshot.data!.data()! as Map<String, dynamic>;

                        // Extreiem camps de l'oferta
                        final String titol = data['titol'] as String? ?? '';
                        final String empresa =
                            data['empresa'] as String? ?? '';
                        final String ubicacio =
                            data['ubicacio'] as String? ?? '';
                        final String descripcio =
                            data['descripcio'] as String? ?? '';
                        final String modalidad =
                            _capitalize(data['modalidad'] as String? ?? '');
                        final bool dual = data['dualIntensiva'] as bool? ?? false;
                        final bool remunerada =
                            data['remunerada'] as bool? ?? false;
                        final String durRaw =
                            data['duracion'] as String? ?? 'meses0_3';
                        final String duracion = durRaw == 'meses0_3'
                            ? '0-3 mesos'
                            : durRaw == 'meses3_6'
                                ? '3-6 mesos'
                                : '6-12 mesos';
                        final bool expReq =
                            data['experienciaRequerida'] as bool? ?? false;
                        final String jornada =
                            _capitalize(data['jornada'] as String? ?? '');
                        final List<String> cursos = List<String>.from(
                            data['cursosDestinatarios'] as List<dynamic>? ?? []);
                        final List<String> tags = List<String>.from(
                            data['tags'] as List<dynamic>? ?? []);

                        // Clau de l'avatar emmagatzemada al document de l'oferta
                        final String? empresaAvatar =
                            data['empresaAvatar'] as String?;

                        // 1) Definim un fallback per defecte
                        String assetAvatar = 'assets/avatars/default.png';
                        // 2) Si hi ha clau, la netegem de ruta o ".png" extra
                        if (empresaAvatar != null && empresaAvatar.isNotEmpty) {
                          var raw = empresaAvatar;
                          if (raw.contains('/')) raw = raw.split('/').last;
                          raw = raw.replaceAll(
                            RegExp(r'\.png$', caseSensitive: false),
                            '',
                          );
                          assetAvatar = 'assets/avatars/$raw.png';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Capçalera amb tornar i títol
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.blueAccent),
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                          context, AppRoutes.homeEstudiant),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    titol,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Avatar de l'empresa amb la ruta normalitzada
                            Center(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(assetAvatar),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Detalls de l'oferta
                            _buildDetailRow('Empresa', empresa),
                            _buildDetailRow('Ubicació', ubicacio),
                            const Divider(),
                            _buildDetailRow('Modalitat', modalidad),
                            _buildDetailRow(
                                'Dual intensiva', dual ? 'Sí' : 'No'),
                            _buildDetailRow(
                                'Remunerada', remunerada ? 'Sí' : 'No'),
                            _buildDetailRow('Duració', duracion),
                            _buildDetailRow('Experiència requerida',
                                expReq ? 'Sí' : 'No'),
                            _buildDetailRow('Jornada', jornada),
                            if (cursos.isNotEmpty) _buildChips('Cursos', cursos),
                            if (tags.isNotEmpty) _buildChips('Interessos', tags),
                            const SizedBox(height: 16),
                            const Text(
                              'Descripció:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              descripcio,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 24),

                            // Botó d'aplicació
                            Center(
                              child: Consumer<OfferApplicationService>(
                                builder: (context, applicationService, _) {
                                  final aplicada =
                                      applicationService.jaAplicada(_ofertaId);
                                  return aplicada
                                      ? const Column(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.green, size: 48),
                                            SizedBox(height: 8),
                                            Text(
                                              'Ja has aplicat a aquesta oferta',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      : ElevatedButton.icon(
                                          icon: const Icon(Icons.send),
                                          label: const Text('Aplicar'),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize:
                                                const Size.fromHeight(50),
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                          onPressed: () => _mostrarDialogAplicacio(
                                            context,
                                            _ofertaId,
                                            titol,
                                          ),
                                        );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChips(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: items
                .map((item) => Chip(
                      label: Text(item, style: const TextStyle(fontSize: 13)),
                      backgroundColor: Colors.orange.shade100,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';
}
