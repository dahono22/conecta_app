// lib/services/auth_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuari.dart';

/// Servicio de autenticación y gestión de usuarios con Firebase Auth y Firestore.
/// Extiende ChangeNotifier para notificar cambios a la UI.
class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Usuari? _usuariActual;
  StreamSubscription<DocumentSnapshot>? _usuariListener;

  Usuari? get usuariActual => _usuariActual;
  set usuariActual(Usuari? u) {
    _usuariActual = u;
    notifyListeners();
  }

  Future<void> desarUsuariFirestore(Usuari usuari) async {
    await _db.collection('usuaris').doc(usuari.id).set({
      'id': usuari.id,
      'nom': usuari.nom,
      'email': usuari.email,
      'rol': usuari.rol.name,
      'descripcio': usuari.descripcio ?? '',
      'cvUrl': usuari.cvUrl ?? '',
    }, SetOptions(merge: true));
  }

  void listenCanvisUsuari(String userId) {
    _usuariListener?.cancel();
    _usuariListener = _db
        .collection('usuaris')
        .doc(userId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) return;
      final d = snap.data()!;
      _usuariActual = Usuari(
        id: d['id'],
        nom: d['nom'],
        email: d['email'],
        contrasenya: '',
        rol: d['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
        descripcio: d['descripcio'],
        cvUrl: d['cvUrl'],
      );
      notifyListeners();
    });
  }

  Future<UserCredential> registre({
    required String nom,
    required String email,
    required String password,
    required RolUsuari rol,
    String? descripcio,
    String? cvUrl,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final usuari = Usuari(
      id: cred.user!.uid,
      nom: nom,
      email: email,
      contrasenya: '',
      rol: rol,
      descripcio: descripcio ?? '',
      cvUrl: cvUrl ?? '',
    );
    await desarUsuariFirestore(usuari);
    _usuariActual = usuari;
    listenCanvisUsuari(usuari.id);
    notifyListeners();
    return cred;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    listenCanvisUsuari(cred.user!.uid);
    return cred;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _usuariListener?.cancel();
    _usuariActual = null;
    notifyListeners();
  }

  /// **NUEVO**: actualiza el email en Firebase Auth y en Firestore
  Future<void> actualitzarEmail(String nouEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No hi ha cap usuari autenticat',
      );
    }
    // 1) actualiza en Auth
    await user.updateEmail(nouEmail);
    // 2) actualiza en Firestore
    await _db.collection('usuaris').doc(user.uid).update({'email': nouEmail});
    // 3) actualiza en memoria local y notifica
    if (_usuariActual != null) {
      _usuariActual = Usuari(
        id: _usuariActual!.id,
        nom: _usuariActual!.nom,
        email: nouEmail,
        contrasenya: _usuariActual!.contrasenya,
        rol: _usuariActual!.rol,
        descripcio: _usuariActual!.descripcio,
        cvUrl: _usuariActual!.cvUrl,
      );
      notifyListeners();
    }
  }

  User? get currentAuthUser => _auth.currentUser;
}
