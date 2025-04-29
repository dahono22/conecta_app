import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../chat/converses_empresa_screen.dart'; // ✅ Nou import

class HomeEmpresaScreen extends StatelessWidget {
  const HomeEmpresaScreen({super.key});

  void _logout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void _crearOferta(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.crearOferta);
  }

  void _veureMevesOfertes(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.mevesOfertes);
  }

  void _veureConverses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConversesEmpresaScreen(),
      ),
    );
  }

  Future<Map<String, int>> _carregarEstadistiques(String empresaId) async {
    final ofertesSnapshot = await FirebaseFirestore.instance
        .collection('ofertes')
        .where('empresaId', isEqualTo: empresaId)
        .get();

    int totalOfertes = ofertesSnapshot.docs.length;

    final ofertaIds = ofertesSnapshot.docs.map((doc) => doc.id).toList();

    int totalAplicacions = 0;
    if (ofertaIds.isNotEmpty) {
      final aplicacionsSnapshot = await FirebaseFirestore.instance
          .collection('aplicacions')
          .where('ofertaId', whereIn: ofertaIds)
          .get();
      totalAplicacions = aplicacionsSnapshot.docs.length;
    }

    return {
      'totalOfertes': totalOfertes,
      'totalAplicacions': totalAplicacions,
    };
  }

  @override
  Widget build(BuildContext context) {
    final empresa = Provider.of<AuthService>(context).usuariActual;
    final empresaId = empresa?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Home Empresa'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Tancar sessió',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _carregarEstadistiques(empresaId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
