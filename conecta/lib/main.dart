import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 Importación de Firebase

import 'app.dart';
import 'services/auth_service.dart';
import 'services/offer_service.dart';
import 'services/offer_application_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 🧩 Necesario para inicializar Firebase antes de correr la app
  await Firebase.initializeApp(); // 🚀 Inicialización de Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => OfferService()),
        ChangeNotifierProvider(create: (_) => OfferApplicationService()),
      ],
      child: const ConectaApp(),
    ),
  );
}
