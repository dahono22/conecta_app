// lib/services/offer_service.dart
import '../models/oferta.dart';

class OfferService {
  final List<Oferta> _ofertes = [
    Oferta(
      id: '1',
      titol: 'Pràctiques Flutter Developer',
      descripcio: 'Treballaràs en una app amb Flutter i Firebase.',
      ubicacio: 'Barcelona',
      empresa: 'TechNova',
    ),
    Oferta(
      id: '2',
      titol: 'Backend amb Node.js',
      descripcio: 'Desenvolupament d’APIs RESTful.',
      ubicacio: 'València',
      empresa: 'CodeFactory',
    ),
  ];

  List<Oferta> get ofertes => _ofertes;

  Oferta? getOfertaPerId(String id) {
  try {
    return _ofertes.firstWhere((o) => o.id == id);
  } catch (e) {
    return null;
  }
}

}
