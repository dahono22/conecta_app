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
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Empresa'),
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
            const Text('Benvinguda, Empresa!'),
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