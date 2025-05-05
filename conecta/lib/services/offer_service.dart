import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Servei per gestionar les ofertes creades per empreses
class OfferService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crea una nova oferta a la col·lecció "ofertes"
  Future<void> crearOferta({
    required String titol,
    required String descripcio,
    required String requisits,
    required String ubicacio,
    required String empresaId,
  }) async {
    // Obtenim el nom de l'empresa a partir del seu ID
    final empresaDoc = await _db.collection('usuaris').doc(empresaId).get();
    final empresaNom = empresaDoc.data()?['nom'] ?? 'Empresa desconeguda'; // Si no té nom, assigna per defecte

    // Definim l'objecte de la nova oferta
    final novaOferta = {
      'titol': titol, // Títol de l'oferta
      'descripcio': descripcio, // Descripció general
      'requisits': requisits, // Requisits necessaris
      'ubicacio': ubicacio, // Localització de la feina
      'empresaId': empresaId, // ID de l'empresa que crea l'oferta
      'empresa': empresaNom, // Nom visible de l'empresa
      'dataPublicacio': FieldValue.serverTimestamp(), // Data automàtica del servidor
      'estat': 'pendent', // Estat inicial de l'oferta (pendent d'aprovació o revisió)
    };

    // Desa la nova oferta a Firestore
    await _db.collection('ofertes').add(novaOferta);
  }
}
