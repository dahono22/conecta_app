import 'package:flutter/material.dart';
import '../models/usuari.dart';

class AuthService with ChangeNotifier {
  final List<Usuari> _usuaris = []; // Simulació de base de dades
  Usuari? _usuariActual;

  Usuari? get usuariActual => _usuariActual;

  set usuariActual(Usuari? usuari) {
    _usuariActual = usuari;
    notifyListeners(); // Opcional: actualitza UI quan es modifica
  }

  bool login(String email, String contrasenya) {
    try {
      final usuari = _usuaris.firstWhere(
        (u) => u.email == email && u.contrasenya == contrasenya,
      );
      _usuariActual = usuari;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool registre(String nom, String email, String contrasenya, RolUsuari rol) {
    final existent = _usuaris.any((u) => u.email == email);
    if (existent) return false;

    final nouUsuari = Usuari(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: nom,
      email: email,
      contrasenya: contrasenya,
      rol: rol,
    );

    _usuaris.add(nouUsuari);
    _usuariActual = nouUsuari;
    notifyListeners();
    return true;
  }

  void logout() {
    _usuariActual = null;
    notifyListeners();
  }
}
