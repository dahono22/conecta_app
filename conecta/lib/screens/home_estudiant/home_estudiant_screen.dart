import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/offer_application_service.dart';
import '../../routes/app_routes.dart';
import '../chat/converses_alumne_screen.dart';

class HomeEstudiantScreen extends StatefulWidget {
  const HomeEstudiantScreen({super.key});

  @override
  State<HomeEstudiantScreen> createState() => _HomeEstudiantScreenState();
}

class _HomeEstudiantScreenState extends State<HomeEstudiantScreen> {
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

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.perfil);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ConversesAlumneScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          // Capa oscura
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Card central
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón de logout en la esquina superior derecha
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: _logout,
                        tooltip: 'Tancar sessió',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Logo superior
                    Image.asset(
                      'assets/images/logo4.png',
                      width: 200,
                      height: 100,
                    ),
                    const SizedBox(height: 30),
                    // Botón con imagen y sombra
                    ElevatedButton(
  onPressed: () =>
      Navigator.pushNamed(context, AppRoutes.llistatOfertes),
  style: ElevatedButton.styleFrom(
    elevation: 10,
    backgroundColor: Colors.amber, // Fondo amarillo
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    shadowColor: Colors.black.withOpacity(0.3),
  ),
  child: Image.asset(
    'assets/images/logo5.png',
    height: 50,
  ),
),

                  ],
                ),
              ),
            ),
          ),
          // FAB de Perfil (esquina inferior izquierda)
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'perfil',
              onPressed: () => _onItemTapped(0),
              backgroundColor: Colors.white,
              elevation: 8,
              child: const Icon(Icons.person, color: Colors.blueAccent),
              shape: const CircleBorder(),
              tooltip: 'Perfil',
            ),
          ),
          // FAB de Converses (esquina inferior derecha)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'converses',
              onPressed: () => _onItemTapped(1),
              backgroundColor: Colors.white,
              elevation: 8,
              child: const Icon(Icons.chat, color: Colors.blueAccent),
              shape: const CircleBorder(),
              tooltip: 'Converses',
            ),
          ),
        ],
      ),
    );
  }
}
