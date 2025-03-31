import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/home_estudiant/home_estudiant_screen.dart';
import '../screens/home_empresa/home_empresa_screen.dart';
import '../screens/perfil/perfil_screen.dart'; // Assegura't d'importar el PerfilScreen

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String homeEstudiant = '/home_estudiant';
  static const String homeEmpresa = '/home_empresa';
  static const String perfil = '/perfil';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    homeEstudiant: (context) => const HomeEstudiantScreen(),
    homeEmpresa: (context) => const HomeEmpresaScreen(),
    perfil: (context) => const PerfilScreen(),
  };
}