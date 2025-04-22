import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OfferService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> crearOferta({
    required String titol,
    required String descripcio,
    required String requisits,
    required String ubicacio,
    required String empresaId,
  }) async {
    final novaOferta = {
      'titol': titol,
      'descripcio': descripcio,
      'requisits': requisits,
      'ubicacio': ubicacio,
      'empresaId': empresaId,
      'dataPublicacio': FieldValue.serverTimestamp(),
      'estat': 'pendent',
    };

    await _db.collection('ofertes').add(novaOferta);
  }
}
