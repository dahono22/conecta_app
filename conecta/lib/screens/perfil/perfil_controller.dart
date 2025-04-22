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
  late RolUsuari rol;

  PerfilController(this.context) {
    final usuari = Provider.of<AuthService>(context, listen: false).usuariActual!;
    nomController = TextEditingController(text: usuari.nom);
    emailController = TextEditingController(text: usuari.email);
    descripcioController = TextEditingController(text: usuari.descripcio ?? '');
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
        cvUrl: usuari.cvUrl,
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

  Future<void> pujarCV() async {
    if (!context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final usuari = authService.usuariActual!;
      final fileName = 'cv_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final storageRef = FirebaseStorage.instance.ref('usuaris/${usuari.id}/$fileName');

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Pujant currículum...'),
                ],
              ),
              duration: Duration(minutes: 1),
              dismissDirection: DismissDirection.none,
            ),
          );

          final snapshot = await storageRef.putFile(file);
          final downloadUrl = await snapshot.ref.getDownloadURL();

          await FirebaseFirestore.instance.collection('usuaris').doc(usuari.id).set({
            'cvUrl': downloadUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          authService.usuariActual = usuari.copyWith(cvUrl: downloadUrl);

          if (context.mounted) {
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Currículum pujat correctament')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Error al pujar CV: $e')),
            );
          }
        }
      });
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error seleccionant el fitxer: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
