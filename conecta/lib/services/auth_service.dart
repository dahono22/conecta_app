import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/usuari.dart';

/// Servei d'autenticació i gestió d'usuaris amb Firebase Firestore.
/// Utilitza [ChangeNotifier] per permetre actualització reactiva a la UI.
class AuthService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Usuari? _usuariActual; // Usuari actualment autenticat (pot ser null si no hi ha cap).
  StreamSubscription<DocumentSnapshot>? _usuariListener; // Subscripció per escoltar canvis en temps real.

  // Getter per accedir a l’usuari actual.
  Usuari? get usuariActual => _usuariActual;

  // Setter que notifica als listeners quan s’assigna un nou usuari.
  set usuariActual(Usuari? usuari) {
    _usuariActual = usuari;
    notifyListeners(); // Notifica a la UI (o qualsevol listener) que l’usuari ha canviat.
  }

  /// Desa (o actualitza) un usuari a la col·lecció 'usuaris' de Firestore.
  Future<void> desarUsuariFirestore(Usuari usuari) async {
    await _db.collection('usuaris').doc(usuari.id).set({
      'id': usuari.id,
      'nom': usuari.nom,
      'email': usuari.email,
      'rol': usuari.rol.name,
      'descripcio': usuari.descripcio ?? '',
      'cvUrl': usuari.cvUrl ?? '',
    }, SetOptions(merge: true)); // Merge evita sobreescriure camps no especificats.
  }

  /// Carrega un usuari de Firestore mitjançant el seu ID.
  Future<Usuari?> carregarUsuariFirestore(String id) async {
    final doc = await _db.collection('usuaris').doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return Usuari(
      id: data['id'],
      nom: data['nom'],
      email: data['email'],
      contrasenya: '', // No es desa la contrasenya per seguretat.
      rol: data['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
      descripcio: data['descripcio'],
      cvUrl: data['cvUrl'],
    );
  }

  /// Escolta els canvis en temps real de l’usuari identificat per [userId].
  void listenCanvisUsuari(String userId) {
    // Cancel·la qualsevol subscripció prèvia.
    _usuariListener?.cancel();

    _usuariListener = _db.collection('usuaris').doc(userId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _usuariActual = Usuari(
          id: data['id'],
          nom: data['nom'],
          email: data['email'],
          contrasenya: '', // No es recupera per seguretat.
          rol: data['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
          descripcio: data['descripcio'],
          cvUrl: data['cvUrl'],
        );
        notifyListeners(); // Actualitza la UI o qualsevol subscrit.
      }
    });
  }

  /// Registra un nou usuari si l’email encara no està registrat.
  Future<bool> registre(String nom, String email, String contrasenya, RolUsuari rol, {String? cvUrl}) async {
    // Comprova si ja existeix un usuari amb aquest correu.
    final query = await _db
        .collection('usuaris')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) return false; // Ja existeix

    // Crea un nou objecte Usuari.
    final nouUsuari = Usuari(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal basat en el temps.
      nom: nom,
      email: email,
      contrasenya: contrasenya,
      rol: rol,
      descripcio: '',
      cvUrl: cvUrl,
    );

    // Desa a Firestore i activa l’escolta en temps real.
    await desarUsuariFirestore(nouUsuari);
    _usuariActual = nouUsuari;
    listenCanvisUsuari(nouUsuari.id);
    notifyListeners();

    return true;
  }

  /// Inicia sessió amb correu i contrasenya. Retorna true si és correcte.
  Future<bool> login(String email, String contrasenya) async {
    final query = await _db
        .collection('usuaris')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false; // No trobat

    final data = query.docs.first.data();

    // NOTA: No es comprova la contrasenya realment. Caldria millorar-ho amb Firebase Auth.
    final usuari = Usuari(
      id: data['id'],
      nom: data['nom'],
      email: data['email'],
      contrasenya: contrasenya,
      rol: data['rol'] == 'empresa' ? RolUsuari.empresa : RolUsuari.estudiant,
      descripcio: data['descripcio'],
      cvUrl: data['cvUrl'],
    );

    _usuariActual = usuari;
    listenCanvisUsuari(usuari.id);
    notifyListeners();

    return true;
  }

  /// Tanca la sessió actual.
  void logout() {
    _usuariListener?.cancel(); // Atura l’escolta de canvis.
    _usuariActual = null;
    notifyListeners(); // Notifica el canvi d’estat.
  }
}
