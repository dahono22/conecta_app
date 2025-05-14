// lib/services/offer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/oferta.dart';

/// Servei per gestionar les ofertes creades per empreses
class OfferService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crea una nova oferta a Firestore, incloent-hi una llista de camps relacionats
  Future<void> crearOferta({
    required String titol,
    required String descripcio,
    required String requisits,
    required String ubicacio,
    required String empresaId,
    required List<String> campos, // Llista de camps relacionats
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
      'estat': 'publicada',
      'campos': campos, // Guardem els camps seleccionats
    };

    // Desa la nova oferta a Firestore
    await _db.collection('ofertes').add(novaOferta);
  }

  /// Retorna les 3 ofertes més recents que coincideixin amb algun dels camps de l'usuari
  Future<List<Oferta>> getRecommendedOffers(List<String> userCampos) async {
    // Firestore array-contains-any només pot rebre fins a 10 valors
    final slice = userCampos.length > 10
        ? userCampos.sublist(0, 10)
        : userCampos;

    final query = await _db
        .collection('ofertes')
        .where('estat', isEqualTo: 'publicada')
        .where('campos', arrayContainsAny: slice)
        .orderBy('dataPublicacio', descending: true)
        .limit(3)
        .get();

    return query.docs
        .map((doc) => Oferta.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Mètode per buscar ofertes amb filtres de camps (p.e. pantalla "Ver més")
  Future<List<Oferta>> getOffersByCampos(List<String> filtros) async {
    final slice = filtros.length > 10 ? filtros.sublist(0, 10) : filtros;
    final query = await _db
        .collection('ofertes')
        .where('estat', isEqualTo: 'publicada')
        .where('campos', arrayContainsAny: slice)
        .orderBy('dataPublicacio', descending: true)
        .get();
    return query.docs
        .map((doc) => Oferta.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}