// lib/screens/perfil/perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../models/usuari.dart';
import '../../routes/app_routes.dart';
import 'perfil_controller.dart';
import '../../services/offer_application_service.dart';
import '../../utils/constants.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late PerfilController _controller;
  late Future<void> _carregarAplicacionsFuture;
  List<String> _selectedInterests = [];
  String? _interestsError;

  // --- Avatar seleccionat ---
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _controller = PerfilController(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.usuariActual!;
    _selectedInterests = List.from(user.intereses);
    // Iniciem amb l'avatar que vingui de Firestore (camp `avatar`)
    _selectedAvatar = user.avatar;

    _carregarAplicacionsFuture = user.id.isNotEmpty
        ? Provider.of<OfferApplicationService>(context, listen: false)
            .carregarAplicacions(user.id)
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

  Widget _buildOfertesAplicadesFirestore(
      BuildContext context, List<String> ofertaIds) {
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
                    aplicacio =
                        aplicacions.firstWhere((a) => a['ofertaId'] == ofertaId);
                  } catch (_) {
                    aplicacio = null;
                  }
                  final estat =
                      (aplicacio?.data() as Map<String, dynamic>?)?['estat'] ??
                          'Nou';
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['titol'] ?? '',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              '${data['empresa'] ?? ''} · ${data['ubicacio'] ?? ''}'),
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

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 3) {
        _selectedInterests.add(interest);
      }
    });
  }

  void _logout() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final applicationService =
        Provider.of<OfferApplicationService>(context, listen: false);
    authService.logout();
    applicationService.clear();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuari = context.watch<AuthService>().usuariActual!;
    final isEmpresa = usuari.rol == RolUsuari.empresa;

    // Rutes dins de /assets/avatars/
final avatarOptions = isEmpresa
    ? [
        'assets/avatars/company1.png',
        'assets/avatars/company2.png',
        'assets/avatars/company3.png',
        'assets/avatars/company4.png',
      ]
    : [
        'assets/avatars/student1.png',
        'assets/avatars/student2.png',
        'assets/avatars/student3.png',
        'assets/avatars/student4.png',
      ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          // semitransparent overlay
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Cabecera: volver & logout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.blueAccent),
                            onPressed: () {
                              final ruta = isEmpresa
                                  ? AppRoutes.homeEmpresa
                                  : AppRoutes.homeEstudiant;
                              Navigator.pushReplacementNamed(context, ruta);
                            },
                            tooltip: 'Tornar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout,
                                color: Colors.redAccent),
                            onPressed: _logout,
                            tooltip: 'Tancar sessió',
                          ),
                        ],
                      ),

                      // Títol
                      Text(
                        isEmpresa
                            ? 'Perfil de l\'empresa'
                            : 'Perfil de l\'estudiant',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // --- Avatar picker ---
                      const Text(
                        'Selecciona el teu avatar:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: avatarOptions.map((path) {
                          final selected = path == _selectedAvatar;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedAvatar = path),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              padding:
                                  selected ? const EdgeInsets.all(4) : null,
                              decoration: selected
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blueAccent,
                                          width: 2),
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(path),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Nom
                      TextFormField(
                        controller: _controller.nomController,
                        decoration: _inputDecoration('Nom complet'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Camp obligatori' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _controller.emailController,
                        decoration: _inputDecoration('Correu electrònic'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Camp obligatori' : null,
                      ),
                      const SizedBox(height: 8),

                      // Verificar email
                      ElevatedButton.icon(
                        onPressed: _controller.enviarVerificacioANouCorreu,
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

                      // Interessos (només estudiant)
                      if (!isEmpresa) ...[
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Els teus interessos (fins a 3):',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children:
                              Constants.camposDisponibles.map((campo) {
                            final sel = _selectedInterests.contains(campo);
                            return FilterChip(
                              label: Text(campo),
                              selected: sel,
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
                                  color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                      ],

                      // Descripció empresa (només empresa)
                      if (isEmpresa) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller:
                              _controller.descripcioController,
                          decoration: _inputDecoration(
                              'Descripció de l\'empresa'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Aquest text serà visible per als estudiants.',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],

                      // CV URL (només estudiant)
                      if (!isEmpresa) ...[
                        const SizedBox(height: 24),
                        const Text('Currículum (enllaç URL):',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _controller.cvUrlController,
                          decoration: _inputDecoration(
                              'Enllaç al CV (Drive, Dropbox...)'),
                          keyboardType: TextInputType.url,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final uri = Uri.tryParse(v);
                              if (uri == null || !uri.hasAbsolutePath) {
                                return 'Enllaç no vàlid.';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (usuari.cvUrl?.isNotEmpty ?? false)
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
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
                                        mode: LaunchMode
                                            .externalApplication);
                                  }
                                },
                              ),
                            ],
                          )
                        else
                          const Text(
                              'Encara no has afegit cap enllaç de currículum.'),
                      ],

                      // Ofertes aplicades (només estudiant)
                      if (!isEmpresa) ...[
                        const SizedBox(height: 24),
                        FutureBuilder(
                          future: _carregarAplicacionsFuture,
                          builder: (ctx, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child:
                                      CircularProgressIndicator());
                            }
                            final ids = context
                                .read<OfferApplicationService>()
                                .idsAplicades;
                            if (ids.isEmpty) {
                              return const Text(
                                  'Encara no has aplicat a cap oferta.');
                            }
                            return _buildOfertesAplicadesFirestore(
                                context, ids);
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Botó desar canvis
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!isEmpresa &&
                              _selectedInterests.isEmpty) {
                            setState(() => _interestsError =
                                'Selecciona fins a 1 i 3 interessos');
                            return;
                          }
                          _controller.guardarCanvis(
  _formKey,
  _selectedInterests,
  nuevoAvatar: _selectedAvatar,
);

                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Desar canvis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize:
                              const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
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
