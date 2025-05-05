// Importacions necessàries per gestionar fitxers, interfície, Firebase i el model d'usuari
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/usuari.dart';
import '../../services/auth_service.dart';

// Controlador per gestionar el perfil d'un usuari
class PerfilController {
  final BuildContext context;

  // Controladors de text per cada camp del formulari
  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController descripcioController;
  late TextEditingController cvUrlController;
  late RolUsuari rol;

  // Constructor del controlador, inicialitza els camps amb dades de l'usuari actual
  PerfilController(this.context) {
    final usuari = Provider.of<AuthService>(context, listen: false).usuariActual!;
    nomController = TextEditingController(text: usuari.nom);
    emailController = TextEditingController(text: usuari.email);
    descripcioController = TextEditingController(text: usuari.descripcio ?? '');
    cvUrlController = TextEditingController(text: usuari.cvUrl ?? '');
    rol = usuari.rol;
  }

  // Guarda els canvis del formulari a Firebase si la validació és correcta
  Future<void> guardarCanvis(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return; // Si el formulari no és vàlid, s'aborta
    if (!context.mounted) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final usuari = authService.usuariActual!;

      // Es crea un nou objecte usuari amb les dades modificades
      final nouUsuari = Usuari(
        id: usuari.id,
        nom: nomController.text.trim(),
        email: emailController.text.trim(),
        contrasenya: usuari.contrasenya,
        rol: usuari.rol,
        descripcio: descripcioController.text.trim(),
        cvUrl: cvUrlController.text.trim(),
      );

      // Es guarda l'usuari nou tant a la sessió com a Firestore
      authService.usuariActual = nouUsuari;
      await authService.desarUsuariFirestore(nouUsuari);

      if (!context.mounted) return;

      // Notificació d'èxit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Canvis desats correctament')),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Notificació d'error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  }

  // Funció de pujada de CV (actualment deshabilitada)
  Future<void> pujarCV() async {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Notificació que la funcionalitat està deshabilitada
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Esta funcionalidad ha sido deshabilitada')),
    );
  }
}
