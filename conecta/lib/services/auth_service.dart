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

  /// Guarda (o actualiza) un usuario en Firestore, incluyendo intereses y avatar.
  Future<void> desarUsuariFirestore(Usuari usuari) async {
    await _db
      .collection('usuaris')
      .doc(usuari.id)
      .set({
        'id': usuari.id,
        'nom': usuari.nom,
        'email': usuari.email,
        'rol': usuari.rol.name,
        'descripcio': usuari.descripcio ?? '',
        'cvUrl': usuari.cvUrl ?? '',
        'avatar': usuari.avatar,       // Ahora guardamos la clave del avatar
        'intereses': usuari.intereses, // Lista de intereses del usuario
      }, SetOptions(merge: true));
  }

  /// Escucha en tiempo real los cambios en el documento de usuario en Firestore
  /// y actualiza la propiedad [usuariActual], incluyendo su avatar.
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
          id: d['id'] as String,
          nom: d['nom'] as String,
          email: d['email'] as String,
          contrasenya: '', // mantenemos vacío por seguridad
          rol: d['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
          descripcio: d['descripcio'] as String?,
          cvUrl: d['cvUrl'] as String?,
          avatar: d['avatar'] as String?,               // Leemos la clave del avatar
          intereses: List<String>.from(d['intereses'] ?? <String>[]),
        );
        notifyListeners();
      });
  }

  /// Registra un nuevo usuario en Firebase Auth y guarda datos adicionales en Firestore.
  Future<UserCredential> registre({
    required String nom,
    required String email,
    required String password,
    required RolUsuari rol,
    String? descripcio,
    String? cvUrl,
  }) async {
    // 1) Crear credenciales en Firebase Auth
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2) Construir objeto de usuario para Firestore
    final usuari = Usuari(
      id: cred.user!.uid,
      nom: nom,
      email: email,
      contrasenya: '',
      rol: rol,
      descripcio: descripcio ?? '',
      cvUrl: cvUrl ?? '',
      avatar: null,       // Sin avatar inicial
      intereses: [],
    );

    // 3) Guardar perfil en Firestore
    await desarUsuariFirestore(usuari);

    // 4) Establecer usuario actual y comenzar a escuchar cambios
    _usuariActual = usuari;
    listenCanvisUsuari(usuari.id);

    return cred;
  }

  /// Inicia sesión en Firebase Auth y comienza a escuchar los datos del usuario.
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

  /// Cierra la sesión actual y detiene el listener de Firestore.
  Future<void> logout() async {
    await _auth.signOut();
    _usuariListener?.cancel();
    _usuariActual = null;
    notifyListeners();
  }

  /// Actualiza el email en Firebase Auth y en Firestore, mantiene intereses y avatar.
  Future<void> actualitzarEmail(String nouEmail) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No hi ha cap usuari autenticat',
      );
    }
    // 1) Actualiza en Auth verificando antes
    await user.verifyBeforeUpdateEmail(nouEmail);
    // 2) Actualiza en Firestore
    await _db.collection('usuaris').doc(user.uid).update({'email': nouEmail});
    // 3) Actualiza en memoria local y notifica
    if (_usuariActual != null) {
      _usuariActual = _usuariActual!.copyWith(email: nouEmail);
      notifyListeners();
    }
  }

  /// Devuelve el usuario de FirebaseAuth si hay sesión activa.
  User? get currentAuthUser => _auth.currentUser;
}
