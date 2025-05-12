import 'package:cloud_firestore/cloud_firestore.dart';

class OfertesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTopTwoOfertes() async {
    // Obtener todas las aplicaciones
    final aplicacionsSnapshot = await _db.collection('aplicacions').get();

    // Contar cuántas veces aparece cada ofertaId
    final Map<String, int> counts = {};
    for (var doc in aplicacionsSnapshot.docs) {
      final ofertaId = doc['ofertaId'];
      counts[ofertaId] = (counts[ofertaId] ?? 0) + 1;
    }
//hola
    // Ordenar por número de aplicaciones (descendente) y coger los 2 primeros
    final topTwoIds = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topIds = topTwoIds.take(2).map((e) => e.key).toList();

    // Obtener los documentos de las ofertas
    List<Map<String, dynamic>> topOfertes = [];
    for (String id in topIds) {
      final query = await _db.collection('ofertes').where(FieldPath.documentId, isEqualTo: id).get();
      if (query.docs.isNotEmpty) {
        topOfertes.add(query.docs.first.data());
      }
    }

    return topOfertes;
  }
}
