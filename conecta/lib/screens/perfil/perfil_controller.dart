import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final usuari = Provider.of<AuthService>(context, listen: false).usuariActual!;
    nomController = TextEditingController(text: usuari.nom);
    emailController = TextEditingController(text: usuari.email);
    descripcioController = TextEditingController(text: usuari.descripcio ?? '');
    cvUrlController = TextEditingController(text: usuari.cvUrl ?? '');
    rol = usuari.rol;
  }

  Future<void> guardarCanvis(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    if (!context.mounted) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final usuari = authService.usuariActual!;

      final nouUsuari = Usuari(
        id: usuari.id,
        nom: nomController.text.trim(),
        email: emailController.text.trim(),
        contrasenya: usuari.contrasenya,
        rol: usuari.rol,
        descripcio: descripcioController.text.trim(),
        cvUrl: cvUrlController.text.trim(),
      );

      authService.usuariActual = nouUsuari;
      await authService.desarUsuariFirestore(nouUsuari);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Canvis desats correctament')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  }

  // Método opcional - se puede eliminar si no se usa
  Future<void> pujarCV() async {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Esta funcionalidad ha sido deshabilitada')),
    );
  }
}