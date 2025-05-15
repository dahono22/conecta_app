// lib/services/offer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/oferta.dart';

/// Servei per gestionar les ofertes creades per empreses
class OfferService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crea una nova oferta a Firestore, incloent-hi tots els camps nous
  Future<void> crearOferta({
    required String titol,
    required String descripcio,
    required String requisits,
    required String ubicacio,
    required String empresaId,
    required List<String> campos,
    required String modalidad,
    required bool dualIntensiva,
    required bool remunerada,
    required String duracion,
    required bool experienciaRequerida,
    required String jornada,
    required List<String> cursosDestinatarios,
  }) async {
    final empresaDoc = await _db.collection('usuaris').doc(empresaId).get();
    final empresaNom = empresaDoc.data()?['nom'] ?? 'Empresa desconeguda';

    final novaOferta = {
      'titol': titol,
      'descripcio': descripcio,
      'requisits': requisits,
      'ubicacio': ubicacio,
      'empresaId': empresaId,
      'empresa': empresaNom,
      'dataPublicacio': FieldValue.serverTimestamp(),
      'estat': 'publicada',
      'tags': campos,
      'modalidad': modalidad,
      'dualIntensiva': dualIntensiva,
      'remunerada': remunerada,
      'duracion': duracion,
      'experienciaRequerida': experienciaRequerida,
      'jornada': jornada,
      'cursosDestinatarios': cursosDestinatarios,
    };

    await _db.collection('ofertes').add(novaOferta);
  }

  /// Actualitza una oferta existent amb els nous camps
  Future<void> updateOferta({
    required String ofertaId,
    required String titol,
    required String descripcio,
    required String requisits,
    required String ubicacio,
    required List<String> campos,
    required String modalidad,
    required bool dualIntensiva,
    required bool remunerada,
    required String duracion,
    required bool experienciaRequerida,
    required String jornada,
    required List<String> cursosDestinatarios,
  }) async {
    final data = {
      'titol': titol,
      'descripcio': descripcio,
      'requisits': requisits,
      'ubicacio': ubicacio,
      'tags': campos,
      'modalidad': modalidad,
      'dualIntensiva': dualIntensiva,
      'remunerada': remunerada,
      'duracion': duracion,
      'experienciaRequerida': experienciaRequerida,
      'jornada': jornada,
      'cursosDestinatarios': cursosDestinatarios,
    };

    await _db.collection('ofertes').doc(ofertaId).update(data);
  }

  /// Retorna les 3 ofertes més recents que coincideixin amb algun dels camps de l'usuari
  Future<List<Oferta>> getRecommendedOffers(List<String> userCampos) async {
    final slice = userCampos.length > 10
        ? userCampos.sublist(0, 10)
        : userCampos;

    final query = await _db
        .collection('ofertes')
        .where('estat', isEqualTo: 'publicada')
        .where('tags', arrayContainsAny: slice)
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
        .where('tags', arrayContainsAny: slice)
        .orderBy('dataPublicacio', descending: true)
        .get();
    return query.docs
        .map((doc) => Oferta.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}