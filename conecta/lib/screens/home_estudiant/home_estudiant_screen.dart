// lib/screens/home_estudiant/home_estudiant_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../services/offer_service.dart';
import '../../services/offer_application_service.dart';
import '../../models/oferta.dart';
import '../../routes/app_routes.dart';
import '../chat/converses_alumne_screen.dart';

class HomeEstudiantScreen extends StatefulWidget {
  const HomeEstudiantScreen({super.key});

  @override
  State<HomeEstudiantScreen> createState() => _HomeEstudiantScreenState();
}

class _HomeEstudiantScreenState extends State<HomeEstudiantScreen> {
  List<Oferta> _recommendedOffers = [];
  bool _isLoadingOffers = true;
  String? _offersError;

  @override
  void initState() {
    super.initState();
    _loadRecommendedOffers();
  }

  Future<void> _loadRecommendedOffers() async {
    setState(() {
      _isLoadingOffers = true;
      _offersError = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final interests = authService.usuariActual?.intereses ?? [];
      if (interests.isNotEmpty) {
        final offerService = Provider.of<OfferService>(context, listen: false);
        final offers = await offerService.getRecommendedOffers(interests);
        setState(() => _recommendedOffers = offers);
      } else {
        setState(() => _recommendedOffers = []);
      }
    } catch (e, st) {
      debugPrint('Error loading recommended offers: $e\n$st');
      setState(() => _offersError = 'No s’han pogut carregar les recomanacions');
    } finally {
      setState(() => _isLoadingOffers = false);
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.perfil);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConversesAlumneScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.usuariActual!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/logo4.png',
                          width: 200,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Ofertes recomanades
                      const Text(
                        'Ofertes per a tu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingOffers)
                        const Center(child: CircularProgressIndicator())
                      else if (_offersError != null)
                        Center(
                          child: Text(
                            _offersError!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        )
                      else if (_recommendedOffers.isEmpty)
                        const Center(
                          child: Text('No hi ha ofertes per als teus interessos.'),
                        )
                      else
                        Column(
                          children: _recommendedOffers.map((oferta) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.orangeAccent, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('•  ',
                                      style: TextStyle(fontSize: 24, height: 1.1)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          oferta.titol,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${oferta.empresa} · ${oferta.ubicacio}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54),
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: GestureDetector(
                                            onTap: () =>
                                                Navigator.pushNamed(
                                              context,
                                              AppRoutes.detallOferta,
                                              arguments: oferta.id,
                                            ),
                                            child: const Text(
                                              'Veure detall ›',
                                              style: TextStyle(
                                                  color: Colors.orangeAccent,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 20),

                      // Botó "Veure totes les ofertes"
                      Center(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.llistatOfertes),
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor: Colors.orangeAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Image.asset(
                            'assets/images/veure_totes_les_ofertes.png',
                            height: 40,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Ofertes aplicades
                      const Text(
                        'Ofertes aplicades',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // 1) Stream de les aplicacions de l'usuari
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('aplicacions')
                            .where('usuariId', isEqualTo: user.id)
                            .snapshots(),
                        builder: (context, snapApps) {
                          if (snapApps.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final apps = snapApps.data!.docs;
                          if (apps.isEmpty) {
                            return const Center(
                              child:
                                  Text('Encara no has aplicat a cap oferta.'),
                            );
                          }
                          // Map d'estats per ofertaId
                          final Map<String, String> estados = {
                            for (var a in apps)
                              (a.get('ofertaId') as String):
                                  (a.get('estat') as String)
                          };
                          final ofertaIds = estados.keys.toList();

                          // 2) Stream de les ofertes corresponents
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('ofertes')
                                .where(FieldPath.documentId,
                                    whereIn: ofertaIds)
                                .snapshots(),
                            builder: (context, snapOff) {
                              if (snapOff.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final offerDocs = snapOff.data!.docs;
                              return Column(
                                children: offerDocs.map((offerDoc) {
                                  final data = offerDoc.data()
                                      as Map<String, dynamic>;
                                  final id = offerDoc.id;
                                  final estat = estados[id] ?? 'Nou';

                                  Color estatColor;
                                  switch (estat) {
                                    case 'Acceptada':
                                      estatColor = Colors.green;
                                      break;
                                    case 'Rebutjada':
                                      estatColor = Colors.red;
                                      break;
                                    default:
                                      estatColor = Colors.orange;
                                  }

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(
                                        data['titol'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                          '${data['empresa'] ?? ''} · ${data['ubicacio'] ?? ''}'),
                                      trailing: Text(
                                        estat,
                                        style: TextStyle(color: estatColor),
                                      ),
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.detallOferta,
                                        arguments: id,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // FAB Perfil
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'perfil',
              onPressed: () => _onItemTapped(0),
              backgroundColor: Colors.white,
              elevation: 8,
              shape: const CircleBorder(),
              tooltip: 'Perfil',
              child: const Icon(Icons.person, color: Colors.blueAccent),
            ),
          ),
          // FAB Converses
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'converses',
              onPressed: () => _onItemTapped(1),
              backgroundColor: Colors.white,
              elevation: 8,
              shape: const CircleBorder(),
              tooltip: 'Converses',
              child: const Icon(Icons.chat, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
