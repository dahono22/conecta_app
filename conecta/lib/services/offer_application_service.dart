// lib/services/offer_application_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Servei que gestiona les aplicacions dels usuaris a les ofertes.
/// Inclou registre, comprovació i càrrega d'aplicacions des de Firestore.
class OfferApplicationService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Conjunt local d'IDs d'ofertes a les quals l'usuari ja ha aplicat.
  final Set<String> _ofertesAplicades = {};

  bool _loading = false;
  String? _error;

  // Getters per accedir a l'estat intern del servei.
  bool get loading => _loading;
  String? get error => _error;

  /// Actualitza l'estat de càrrega i notifica els listeners.
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  /// Neteja la llista local d'ofertes aplicades.
  void clear() {
    _ofertesAplicades.clear();
    notifyListeners();
  }

  /// Aplica l'usuari [userId] a una oferta [idOferta].
  /// Opcionalment, pot incloure un enllaç al CV [cvUrl] i la clau de l'avatar [usuariAvatar].
  Future<void> aplicarAOferta(
    String userId,
    String idOferta, {
    String? cvUrl,
    String? usuariAvatar,
  }) async {
    _error = null; // Reinicia qualsevol error anterior

    // El document d'aplicació té com a ID: userId-ofertaId
    final docRef = _db.collection('aplicacions').doc('$userId-$idOferta');

    try {
      // Desa la informació de l'aplicació a Firestore
      final data = {
        'usuariId': userId,
        'ofertaId': idOferta,
        'timestamp': FieldValue.serverTimestamp(), // Marca la data del servidor
        'estat': 'Nou', // Estat inicial per al procés de selecció
        if (cvUrl != null && cvUrl.isNotEmpty) 'cvUrl': cvUrl, // Només si s'ha proporcionat
        if (usuariAvatar != null && usuariAvatar.isNotEmpty) 'usuariAvatar': usuariAvatar, // Avatar de l'usuari
      };
      await docRef.set(data);

      // Afegeix l'oferta a la llista local d'aplicacions
      _ofertesAplicades.add(idOferta);
      notifyListeners(); // Actualitza la UI o components que escoltin aquest servei
    } catch (e) {
      _error = 'Error en aplicar a l’oferta.'; // Guarda un missatge d'error genèric
      rethrow; // Propaga l'excepció per poder-la capturar externament
    }
  }

  /// Carrega totes les aplicacions fetes per un usuari des de Firestore.
  Future<void> carregarAplicacions(String userId) async {
    try {
      final snapshot = await _db
          .collection('aplicacions')
          .where('usuariId', isEqualTo: userId)
          .get();

      _ofertesAplicades.clear(); // Esborra la llista anterior per evitar duplicats

      // Afegeix totes les ofertes a la llista local
      for (final doc in snapshot.docs) {
        _ofertesAplicades.add(doc['ofertaId'] as String);
      }

      notifyListeners(); // Informa la UI que s'ha carregat la informació
    } catch (e) {
      _error = 'Error en carregar les aplicacions.'; // Missatge d'error en cas de fallada
    }
  }

  /// Comprova si l'usuari ja ha aplicat a una oferta a nivell local (en memòria).
  bool jaAplicada(String idOferta) {
    return _ofertesAplicades.contains(idOferta);
  }

  /// Retorna una llista d'IDs d'ofertes a les quals s'ha aplicat (en memòria).
  List<String> get idsAplicades => _ofertesAplicades.toList();

  /// Comprova contra Firestore si l'usuari ja ha aplicat a una oferta concreta.
  /// Útil si la memòria local no està sincronitzada.
  Future<bool> jaAplicadaFirestore({
    required String usuariId,
    required String ofertaId,
  }) async {
    final snapshot = await _db
        .collection('aplicacions')
        .where('usuariId', isEqualTo: usuariId)
        .where('ofertaId', isEqualTo: ofertaId)
        .get();

    return snapshot.docs.isNotEmpty; // Retorna true si ja existeix una aplicació
  }
}
