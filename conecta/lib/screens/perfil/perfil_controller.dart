import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuari.dart';
import '../../services/auth_service.dart';

class PerfilController {
  final BuildContext context;

  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController descripcioController;
  late RolUsuari rol;

  PerfilController(this.context) {
    final usuari = Provider.of<AuthService>(context, listen: false).usuariActual!;
    nomController = TextEditingController(text: usuari.nom);
    emailController = TextEditingController(text: usuari.email);
    descripcioController = TextEditingController(); // Potser es carrega més endavant
    rol = usuari.rol;
  }

  void guardarCanvis(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final usuari = authService.usuariActual!;

    authService.usuariActual = Usuari(
      id: usuari.id,
      nom: nomController.text.trim(),
      email: emailController.text.trim(),
      contrasenya: usuari.contrasenya,
      rol: usuari.rol,
    );

    authService.notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Canvis desats correctament')),
    );
  }
}
