import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

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

  @override
  Widget build(BuildContext context) {
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
      body: Center(
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
            ],
          ),
        ),
      ),
    );
  }
}
