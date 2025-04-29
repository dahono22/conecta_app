import 'package:flutter/material.dart';

// Importació de totes les pantalles utilitzades a les rutes
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/home_estudiant/home_estudiant_screen.dart';
import '../screens/home_empresa/home_empresa_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/ofertes/list_ofertes_screen.dart';
import '../screens/ofertes/detail_oferta_screen.dart';
import '../screens/ofertes/crear_oferta_screen.dart';
import '../screens/ofertes/meves_ofertes_screen.dart'; // ✅ Nova importació

class AppRoutes {
  // 🔐 Rutes d'autenticació
  static const String login = '/login'; // Pantalla de login
  static const String register = '/register'; // Pantalla de registre

  // 🏠 Rutes d'inici segons el tipus d'usuari
  static const String homeEstudiant = '/home_estudiant'; // Inici per a estudiants
  static const String homeEmpresa = '/home_empresa'; // Inici per a empreses

  // 👤 Perfil de l'usuari
  static const String perfil = '/perfil'; // Pantalla de perfil

  // 📄 Rutes relacionades amb les ofertes
  static const String llistatOfertes = '/ofertes'; // Llistat general d'ofertes
  static const String detallOferta = '/ofertes/detall'; // Detall d'una oferta
  static const String crearOferta = '/crear-oferta'; // Formulari per crear una nova oferta
  static const String mevesOfertes = '/meves-ofertes'; // ✅ Nova ruta: veure les pròpies ofertes publicades

  // 🗺️ Map de rutes amb els constructors de pantalles corresponents
  static final Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    homeEstudiant: (context) => HomeEstudiantScreen(),
    homeEmpresa: (context) => HomeEmpresaScreen(),
    perfil: (context) => PerfilScreen(),
    llistatOfertes: (context) => ListOfertesScreen(),
    detallOferta: (context) => DetailOfertaScreen(),
    crearOferta: (context) => CrearOfertaScreen(),
    mevesOfertes: (context) => MevesOfertesScreen(), // ✅ Associada correctament a la nova pantalla
  };
}
