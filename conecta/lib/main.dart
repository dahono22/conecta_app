import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/offer_service.dart';
import 'services/offer_application_service.dart';

void main() {
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
