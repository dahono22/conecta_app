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
      descripcio: 'Desenvolupament d\'APIs RESTful.',
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

  List<Oferta> filtrarOfertes({
    String? paraulaClau,
    String? ubicacio,
    String? empresa,
  }) {
    return _ofertes.where((oferta) {
      // Filtro por palabra clave (busca en título y descripción)
      final matchText = paraulaClau == null || paraulaClau.isEmpty ||
          oferta.titol.toLowerCase().contains(paraulaClau.toLowerCase()) ||
          oferta.descripcio.toLowerCase().contains(paraulaClau.toLowerCase());

      // Filtro por ubicación
      final matchUbicacio = ubicacio == null || ubicacio.isEmpty || ubicacio == 'Totes' ||
          oferta.ubicacio.toLowerCase() == ubicacio.toLowerCase();

      // Filtro por empresa
      final matchEmpresa = empresa == null || empresa.isEmpty ||
          oferta.empresa.toLowerCase().contains(empresa.toLowerCase());

      return matchText && matchUbicacio && matchEmpresa;
    }).toList();
  }
}