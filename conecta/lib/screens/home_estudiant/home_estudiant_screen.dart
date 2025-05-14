// lib/screens/home_estudiant/home_estudiant_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/offer_application_service.dart';
import '../../services/offer_service.dart'; // Import OfferService
import '../../models/oferta.dart'; // Import model
import '../../routes/app_routes.dart';
import '../chat/converses_alumne_screen.dart';

class HomeEstudiantScreen extends StatefulWidget {
  const HomeEstudiantScreen({super.key});

  @override
  State<HomeEstudiantScreen> createState() => _HomeEstudiantScreenState();
}

class _HomeEstudiantScreenState extends State<HomeEstudiantScreen> {
  // Estado de ofertas recomendadas
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
        setState(() {
          _recommendedOffers = offers;
        });
      } else {
        setState(() {
          _recommendedOffers = [];
        });
      }
    } catch (e, st) {
  // Log para depuración
  debugPrint('Error loading recommended offers: $e');
  debugPrint('$st');
  setState(() => _offersError = 'Error al carregar recomanacions: $e');
} finally {
  setState(() => _isLoadingOffers = false);
}

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
          // Capa oscura actualizada deprecación
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.5),
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
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botón de logout
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
                    Center(
                      child: Image.asset(
                        'assets/images/logo4.png',
                        width: 200,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Secció: Ofertes recomanades
                    const Text(
                      'Ofertes per a tu',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingOffers)
                      const Center(child: CircularProgressIndicator())
                    else if (_offersError != null)
                      Center(child: Text(_offersError!))
                    else if (_recommendedOffers.isEmpty)
                      const Text('No hi ha ofertes per als teus interessos.')
                    else ..._recommendedOffers.map((oferta) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            oferta.titol,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${oferta.empresa} - ${oferta.ubicacio}'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.detallOferta, // ajustada la ruta
                              arguments: oferta.id,
                            );
                          },
                        ),
                      );
                    }),
                    // Botó "Veure més"
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          final interests =
                              context.read<AuthService>().usuariActual!.intereses;
                          Navigator.pushNamed(
                            context,
                            AppRoutes.llistatOfertes,
                            arguments: {'campos': interests},
                          );
                        },
                        child: const Text('Veure més ›'),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Botón con imagen y sombra (lista general)
                    Center(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.llistatOfertes),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          backgroundColor: Colors.amber, // Fondo amarillo
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        child: Image.asset(
                          'assets/images/logo5.png',
                          height: 50,
                        ),
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
              shape: const CircleBorder(),
              tooltip: 'Perfil',
              child: const Icon(Icons.person, color: Colors.blueAccent),
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
