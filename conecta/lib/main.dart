import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ✅ ¡Este es el que faltaba!

import 'app.dart';
import 'services/auth_service.dart';
import 'services/offer_service.dart';
import 'services/offer_application_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 🧠 usa la config generada por flutterfire
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
ChangeNotifierProvider(create: (_) => OfferService()),
        ChangeNotifierProvider(create: (_) => OfferApplicationService()),
      ],
      child: const ConectaApp(),
    ),
  );
}
