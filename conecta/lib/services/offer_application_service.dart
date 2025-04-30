import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OfferApplicationService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Set<String> _ofertesAplicades = {};

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void clear() {
    _ofertesAplicades.clear();
    notifyListeners();
  }

  Future<void> aplicarAOferta(
    String userId,
    String idOferta, {
    String? cvUrl,
  }) async {
    _error = null;
    final docRef = _db.collection('aplicacions').doc('$userId-$idOferta');

    try {
      await docRef.set({
        'usuariId': userId,
        'ofertaId': idOferta,
        'timestamp': FieldValue.serverTimestamp(),
        'estat': 'Nou', // ✅ Estat inicial "Nou"
        if (cvUrl != null && cvUrl.isNotEmpty) 'cvUrl': cvUrl,
      });

      _ofertesAplicades.add(idOferta);
      notifyListeners();
    } catch (e) {
      _error = 'Error en aplicar a l’oferta.';
      rethrow;
    }
  }

  Future<void> carregarAplicacions(String userId) async {
    try {
      final snapshot = await _db
          .collection('aplicacions')
          .where('usuariId', isEqualTo: userId)
          .get();

      _ofertesAplicades.clear();
      for (final doc in snapshot.docs) {
        _ofertesAplicades.add(doc['ofertaId']);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error en carregar les aplicacions.';
    }
  }

  bool jaAplicada(String idOferta) {
    return _ofertesAplicades.contains(idOferta);
  }

  List<String> get idsAplicades => _ofertesAplicades.toList();

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
