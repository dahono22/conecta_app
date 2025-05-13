// lib/services/offer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/oferta.dart';

/// Servei per gestionar les ofertes creades per empreses
class OfferService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crea una nova oferta a Firestore, incloent-hi una llista d'interessos predefinits
  Future<void> crearOferta({
    required String titol,
    required String descripcio,
    required String requisits,
    required String ubicacio,
    required String empresaId,
    required List<String> interessos, // Afegim llista d'interessos
  }) async {
    // Obtenim el nom de l'empresa a partir del seu ID
    final empresaDoc = await _db.collection('usuaris').doc(empresaId).get();
    final empresaNom = empresaDoc.data()?['nom'] ?? 'Empresa desconeguda';

    // Definim l'objecte de la nova oferta
    final novaOferta = {
      'titol': titol,
      'descripcio': descripcio,
      'requisits': requisits,
      'ubicacio': ubicacio,
      'empresaId': empresaId,
      'empresa': empresaNom,
      'dataPublicacio': FieldValue.serverTimestamp(),
      'estat': 'pendent',
      'interessos': interessos, // Guardem el camp
    };

    // Desa la nova oferta a Firestore
    await _db.collection('ofertes').add(novaOferta);
  }

  /// Retorna les 3 ofertes més recents que coincideixin amb algun dels interessos de l'usuari
  Future<List<Oferta>> getRecommendedOffers(List<String> userInterests) async {
    // Firestore array-contains-any només pot rebre fins a 10 valors
    final slice = userInterests.length > 10
        ? userInterests.sublist(0, 10)
        : userInterests;

    final query = await _db
        .collection('ofertes')
        .where('estat', isEqualTo: 'publicada')
        .where('interessos', arrayContainsAny: slice)
        .orderBy('dataPublicacio', descending: true)
        .limit(3)
        .get();

    return query.docs
        .map((doc) => Oferta.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
