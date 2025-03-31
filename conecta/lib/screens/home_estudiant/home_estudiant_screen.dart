import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class HomeEstudiantScreen extends StatelessWidget {
  const HomeEstudiantScreen({super.key});

  void _logout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRoutes.login, 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Estudiant'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Tancar sessió',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Benvingut, Estudiant!'),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
              child: const Text('Veure perfil'),
            ),
          ],
        ),
      ),
    );
  }
}