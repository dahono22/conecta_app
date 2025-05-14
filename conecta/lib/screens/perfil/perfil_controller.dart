// lib/screens/perfil/perfil_controller.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/usuari.dart';
import '../../services/auth_service.dart';

class PerfilController {
  final BuildContext context;
  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController descripcioController;
  late TextEditingController cvUrlController;
  late RolUsuari rol;

  PerfilController(this.context) {
    final u = Provider.of<AuthService>(context, listen: false).usuariActual!;
    nomController = TextEditingController(text: u.nom);
    emailController = TextEditingController(text: u.email);
    descripcioController = TextEditingController(text: u.descripcio ?? '');
    cvUrlController = TextEditingController(text: u.cvUrl ?? '');
    rol = u.rol;
  }

  /// Envía un correo de verificación al nuevo email antes de actualizar
  Future<void> enviarVerificacioANouCorreu() async {
    final nouEmail = emailController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentEmail = currentUser?.email;

    if (nouEmail.isEmpty || nouEmail == currentEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introdueix un correu nou vàlid.')),
      );
      return;
    }

    try {
      await currentUser?.verifyBeforeUpdateEmail(nouEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'T’hem enviat un correu per verificar el nou email. Revisa’l.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en enviar verificació: ${e.toString()}')),
      );
    }
  }

  /// Guarda los cambios del formulario si el email ya ha sido verificado
  Future<void> guardarCanvis(GlobalKey<FormState> formKey, List<String> intereses) async {
    if (!formKey.currentState!.validate()) return;
    if (!context.mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final usuari = authService.usuariActual!;
    final nouEmail = emailController.text.trim();
    final campNom = nomController.text.trim();
    final campDesc = descripcioController.text.trim();
    final campCv = cvUrlController.text.trim();

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      // Actualiza el email en Auth si ha cambiado y ya verificado
      if (nouEmail != usuari.email) {
        if (user?.email != nouEmail) {
          throw Exception('Has de verificar el nou correu abans de desar.');
        } else {
          await authService.actualitzarEmail(nouEmail);
        }
      }

      // Construye el objeto usuario con los datos actualizados e intereses
      final nouUsuari = Usuari(
        id: usuari.id,
        nom: campNom,
        email: nouEmail,
        contrasenya: usuari.contrasenya,
        rol: rol,
        descripcio: campDesc,
        cvUrl: campCv,
        intereses: rol == RolUsuari.estudiant ? intereses : [],
      );

      // Guarda en Firestore y actualiza estado local
      await authService.desarUsuariFirestore(nouUsuari);
      authService.usuariActual = nouUsuari;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Canvis desats correctament')),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $msg')),
      );
    }
  }

  /// Funcionalidad de subida de CV (actualmente deshabilitada)
  Future<void> pujarCV() async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalitat deshabilitada')),
    );
  }
}
