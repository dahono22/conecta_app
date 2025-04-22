import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/usuari.dart';

class AuthService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Usuari? _usuariActual;
  StreamSubscription<DocumentSnapshot>? _usuariListener;

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
    }, SetOptions(merge: true));
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

  void listenCanvisUsuari(String userId) {
    _usuariListener?.cancel(); // cancel·lem el listener anterior si hi era

    _usuariListener = _db.collection('usuaris').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _usuariActual = Usuari(
          id: data['id'],
          nom: data['nom'],
          email: data['email'],
          contrasenya: '',
          rol: data['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
          descripcio: data['descripcio'],
        );
        notifyListeners();
      }
    });
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
    listenCanvisUsuari(nouUsuari.id);
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
    listenCanvisUsuari(usuari.id);
    notifyListeners();
    return true;
  }

  void logout() {
    _usuariListener?.cancel();
    _usuariActual = null;
    notifyListeners();
  }
}
