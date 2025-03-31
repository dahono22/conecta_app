import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';
import '../screens/home_estudiant/home_estudiant_screen.dart';
import '../screens/home_empresa/home_empresa_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String homeEstudiant = '/home_estudiant';
  static const String homeEmpresa = '/home_empresa';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    homeEstudiant: (context) => const HomeEstudiantScreen(),
    homeEmpresa: (context) => const HomeEmpresaScreen(),
  };
}
