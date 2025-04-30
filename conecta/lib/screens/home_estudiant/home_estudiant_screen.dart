import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/offer_application_service.dart';
import '../../routes/app_routes.dart';
import '../chat/converses_alumne_screen.dart'; // ✅ Import de la pantalla de converses per a l'estudiant

class HomeEstudiantScreen extends StatelessWidget {
  const HomeEstudiantScreen({super.key});

  // Funció per tancar sessió: neteja dades i torna a la pantalla de login
  void _logout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final applicationService =
        Provider.of<OfferApplicationService>(context, listen: false);

    authService.logout(); // Tanca sessió
    applicationService.clear(); // Elimina dades temporals de candidatures

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false, // Esborra tot l'historial de navegació
    );
  }

  // Navegació cap a la pantalla de converses de l’estudiant
  void _veureConverses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConversesAlumneScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Fons clar i neutre
      appBar: AppBar(
        title: const Text('Home Estudiant'),
        elevation: 0,
        backgroundColor: Colors.white, // Estètica minimalista
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () => _logout(context), // Tanca sessió
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
              // Missatge de benvinguda
              const Text(
                'Benvingut, Estudiant!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 32),
              // Botó per veure el perfil de l'estudiant
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
              // Botó per veure les ofertes disponibles
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.llistatOfertes),
                icon: const Icon(Icons.search),
                label: const Text('Veure Ofertes'),
              ),
              const SizedBox(height: 16),
              // Botó per accedir a les converses amb empreses
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
      ),
    );
  }
}
