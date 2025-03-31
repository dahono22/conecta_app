import 'package:flutter/material.dart';
import '../screens/login/login_screen.dart';

class AppRoutes {
  static const String login = '/login';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    // Aquí afegirem altres pantalles: homeEstudiant, homeEmpresa, registre...
  };
}
