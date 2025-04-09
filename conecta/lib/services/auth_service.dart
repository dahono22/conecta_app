import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/usuari.dart';

class AuthService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Usuari? _usuariActual;

  Usuari? get usuariActual => _usuariActual;

  set usuariActual(Usuari? usuari) {
    _usuariActual = usuari;
    notifyListeners();
  }

  Future<void> desarUsuariFirestore(Usuari usuari) async {
    await _db.collection('usuaris').doc(usuari.id).set({
      'id': usuari.id,
      'nom': usuari.nom,
      'email': usuari.email,
      'rol': usuari.rol.name,
      'descripcio': usuari.descripcio ?? '',
    });
  }

  Future<Usuari?> carregarUsuariFirestore(String id) async {
    final doc = await _db.collection('usuaris').doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return Usuari(
      id: data['id'],
      nom: data['nom'],
      email: data['email'],
      contrasenya: '',
      rol: data['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
      descripcio: data['descripcio'],
    );
  }

  Future<bool> registre(String nom, String email, String contrasenya, RolUsuari rol) async {
    final query = await _db
        .collection('usuaris')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) return false;

    final nouUsuari = Usuari(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: nom,
      email: email,
      contrasenya: contrasenya,
      rol: rol,
      descripcio: '',
    );

    await desarUsuariFirestore(nouUsuari);
    _usuariActual = nouUsuari;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String contrasenya) async {
    final query = await _db
        .collection('usuaris')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final data = query.docs.first.data();
    final usuari = Usuari(
      id: data['id'],
      nom: data['nom'],
      email: data['email'],
      contrasenya: contrasenya,
      rol: data['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
      descripcio: data['descripcio'],
    );

    _usuariActual = usuari;
    notifyListeners();
    return true;
  }

  void logout() {
    _usuariActual = null;
    notifyListeners();
  }
}
