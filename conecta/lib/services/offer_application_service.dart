// ✅ ARCHIVO CORREGIDO: offer_application_service.dart (Firebase real)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OfferApplicationService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Set<String> _ofertesAplicades = {};

  Future<void> aplicarAOferta(String userId, String idOferta) async {
    final docRef = _db.collection('aplicacions').doc('$userId-$idOferta');

    await docRef.set({
      'usuariId': userId,
      'ofertaId': idOferta,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _ofertesAplicades.add(idOferta);
    notifyListeners();
  }

  Future<void> carregarAplicacions(String userId) async {
    final snapshot = await _db
        .collection('aplicacions')
        .where('usuariId', isEqualTo: userId)
        .get();

    _ofertesAplicades.clear();
    for (final doc in snapshot.docs) {
      _ofertesAplicades.add(doc['ofertaId']);
    }

    notifyListeners();
  }

  bool jaAplicada(String idOferta) {
    return _ofertesAplicades.contains(idOferta);
  }

  List<String> get idsAplicades => _ofertesAplicades.toList();

  // ✅ Mètode afegit per a validació a Firestore
  Future<bool> jaAplicadaFirestore({
    required String usuariId,
    required String ofertaId,
  }) async {
    final snapshot = await _db
        .collection('aplicacions')
        .where('usuariId', isEqualTo: usuariId)
        .where('ofertaId', isEqualTo: ofertaId)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}

// ✅ IMPORTANTE: Actualiza el nombre de la colección a 'aplicacions' (no 'applications')
// ✅ Usa los campos correctos: 'usuariId' y 'ofertaId'
// ✅ Ya está listo para usar en production/test si has configurado Firestore correctamente