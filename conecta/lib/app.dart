import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

// Widget principal de l'aplicació Conecta
class ConectaApp extends StatelessWidget {
  const ConectaApp({super.key}); // Constructor de la classe, amb key opcional

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conecta', // Títol de l'aplicació (pot aparèixer en multitask)
      debugShowCheckedModeBanner: false, // Elimina el banner de debug
      initialRoute: AppRoutes.login, // Ruta inicial quan s'engega l'app
      routes: AppRoutes.routes, // Map de rutes definides a l'app
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Color principal de l'aplicació
        scaffoldBackgroundColor: Colors.white, // Color de fons per defecte
      ),
    );
  }
}
