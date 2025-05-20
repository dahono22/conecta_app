// lib/screens/home_empresa/home_empresa_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../chat/converses_empresa_screen.dart';

/// Pantalla principal de l'empresa amb estil èpic i professional
class HomeEmpresaScreen extends StatelessWidget {
  const HomeEmpresaScreen({super.key});

  void _logout(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    auth.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  Stream<Map<String, int>> _estadistiquesStream(String empresaId) {
    final ofertesRef = FirebaseFirestore.instance
        .collection('ofertes')
        .where('empresaId', isEqualTo: empresaId);

    return ofertesRef.snapshots().asyncMap((snapshot) async {
      final totalOfertes = snapshot.docs.length;
      final ofertaIds = snapshot.docs.map((d) => d.id).toList();
      int totalAplicacions = 0;
      if (ofertaIds.isNotEmpty) {
        final appsSnap = await FirebaseFirestore.instance
            .collection('aplicacions')
            .where('ofertaId', whereIn: ofertaIds)
            .get();
        totalAplicacions = appsSnap.docs.length;
      }
      return {
        'ofertes': totalOfertes,
        'aplicacions': totalAplicacions,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final empresa = authService.usuariActual!;
    final empresaId = empresa.id;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo i Benvinguda
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 120,
                              height: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Benvinguda, ${empresa.nom}!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Estadístiques
                      StreamBuilder<Map<String, int>>(
                        stream: _estadistiquesStream(empresaId),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final stats = snap.data!;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatCard(
                                label: 'Ofertes',
                                value: stats['ofertes']!,
                                icon: Icons.description,
                                color: Colors.blueAccent,
                              ),
                              _StatCard(
                                label: 'Candidatures',
                                value: stats['aplicacions']!,
                                icon: Icons.people,
                                color: Colors.indigoAccent,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 36),

                      // Botons d'acció
                      _ActionButton(
                        icon: Icons.person,
                        label: 'Veure Perfil',
                        color: Colors.teal,
                        onTap: () => _navigate(context, AppRoutes.perfil),
                      ),
                      const SizedBox(height: 16),
                      _ActionButton(
                        icon: Icons.add_business,
                        label: 'Nova Oferta',
                        color: Colors.orangeAccent,
                        onTap: () => _navigate(context, AppRoutes.crearOferta),
                      ),
                      const SizedBox(height: 16),
                      _ActionButton(
                        icon: Icons.list_alt,
                        label: 'Les Meves Ofertes',
                        color: Colors.deepPurple,
                        onTap: () => _navigate(context, AppRoutes.mevesOfertes),
                      ),
                      const SizedBox(height: 16),
                      _ActionButton(
                        icon: Icons.chat_bubble,
                        label: 'Converses Actives',
                        color: Colors.pinkAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConversesEmpresaScreen(),
                          ),
                        ),
                      ),
                      // S'ha eliminat el botó "Tancar Sessió" perquè ja es troba a la pantalla de Perfil
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

/// Widget per mostrar una estadística en un card petit
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

/// Botó d'acció estilitzat
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
      ),
    );
  }
}
