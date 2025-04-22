import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/home_estudiant/home_estudiant_screen.dart';
import '../screens/home_empresa/home_empresa_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/ofertes/list_ofertes_screen.dart';
import '../screens/ofertes/detail_oferta_screen.dart';
import '../screens/ofertes/crear_oferta_screen.dart'; // ✅ Importa la pantalla de creació

class AppRoutes {
  // Rutes existents
  static const String login = '/login';
  static const String register = '/register';
  static const String homeEstudiant = '/home_estudiant';
  static const String homeEmpresa = '/home_empresa';
  static const String perfil = '/perfil';

  // Rutes d'ofertes
  static const String llistatOfertes = '/ofertes';
  static const String detallOferta = '/ofertes/detall';
  static const String crearOferta = '/crear-oferta'; // ✅ Nova ruta

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
    homeEstudiant: (context) => HomeEstudiantScreen(),
    homeEmpresa: (context) => HomeEmpresaScreen(),
    perfil: (context) => PerfilScreen(),

    llistatOfertes: (context) => ListOfertesScreen(),
    detallOferta: (context) => DetailOfertaScreen(),
    crearOferta: (context) => CrearOfertaScreen(), // ✅ Associem la ruta
  };
}
