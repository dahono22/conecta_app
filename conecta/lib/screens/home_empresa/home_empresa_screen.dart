import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../chat/converses_empresa_screen.dart';

class HomeEmpresaScreen extends StatelessWidget {
  const HomeEmpresaScreen({super.key});

  // Mètode per tancar sessió de l'empresa i tornar a la pantalla de login
  void _logout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  // Navegació cap a la pantalla per crear una nova oferta
  void _crearOferta(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.crearOferta);
  }

  // Navegació cap a la llista d'ofertes publicades per l'empresa
  void _veureMevesOfertes(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.mevesOfertes);
  }

  // Navegació cap a la pantalla de converses actives amb alumnes
  void _veureConverses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConversesEmpresaScreen(),
      ),
    );
  }

  // Stream que carrega estadístiques en temps real: ofertes creades i aplicacions rebudes
  Stream<Map<String, int>> _estadistiquesStream(String empresaId) {
    final ofertesRef = FirebaseFirestore.instance
        .collection('ofertes')
        .where('empresaId', isEqualTo: empresaId);

    return ofertesRef.snapshots().asyncMap((ofertesSnapshot) async {
      final totalOfertes = ofertesSnapshot.docs.length; // nombre total d'ofertes
      final ofertaIds = ofertesSnapshot.docs.map((doc) => doc.id).toList();

      int totalAplicacions = 0;
      if (ofertaIds.isNotEmpty) {
        final aplicacionsSnapshot = await FirebaseFirestore.instance
            .collection('aplicacions')
            .where('ofertaId', whereIn: ofertaIds)
            .get();
        totalAplicacions = aplicacionsSnapshot.docs.length; // total de candidatures rebudes
      }

      return {
        'totalOfertes': totalOfertes,
        'totalAplicacions': totalAplicacions,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final empresa = Provider.of<AuthService>(context).usuariActual; // Obté l'empresa actual
    final empresaId = empresa?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // color de fons suau per coherència visual
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png', // Ruta del logo
            width: 40,  // Ajusta el tamaño según sea necesario
            height: 40,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context), // tancar sessió
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Tancar sessió',
          ),
        ],
      ),
      // Mostra estadístiques en temps real amb StreamBuilder
      body: StreamBuilder<Map<String, int>>(
        stream: _estadistiquesStream(empresaId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // carregant...
          }

          final stats = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Benvinguda, Empresa!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text('📄 Ofertes publicades: ${stats['totalOfertes']}'),
                          const SizedBox(height: 8),
                          Text('👥 Candidatures rebudes: ${stats['totalAplicacions']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
                    icon: const Icon(Icons.person),
                    label: const Text('Veure perfil'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _crearOferta(context),
                    icon: const Icon(Icons.add_business),
                    label: const Text('Publicar nova oferta'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blueGrey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _veureMevesOfertes(context),
                    icon: const Icon(Icons.list),
                    label: const Text('Veure les meves ofertes'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _veureConverses(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('Converses actives'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
